import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:uuid/uuid.dart';

class EcoGoalController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<EcoGoal> _userGoals = [];
  bool _isLoading = false;
  
  List<EcoGoal> get userGoals => _userGoals;
  bool get isLoading => _isLoading;
  
  Future<void> getUserGoals(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('eco_goals')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _userGoals.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        _userGoals.add(EcoGoal.fromJson(data));
      }
    } catch (e) {
      print('Error fetching user goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<EcoGoal?> createGoal({
    required String userId,
    required String title,
    required String description,
    required GoalType type,
    required GoalFrequency frequency,
    required int target,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      
      final newGoal = EcoGoal(
        id: uuid,
        userId: userId,
        title: title,
        description: description,
        type: type,
        frequency: frequency,
        target: target,
        startDate: startDate,
        endDate: endDate,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestore.collection('eco_goals').doc(uuid).set(newGoal.toJson());
      
      _userGoals.insert(0, newGoal);
      notifyListeners();
      
      return newGoal;
    } catch (e) {
      print('Error creating goal: $e');
      return null;
    }
  }
  
  Future<bool> updateGoalProgress(String goalId, int progress) async {
    try {
      final index = _userGoals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) return false;
      
      final goal = _userGoals[index];
      final newProgress = goal.currentProgress + progress;
      final isCompleted = newProgress >= goal.target;
      
      final updatedGoal = goal.copyWith(
        currentProgress: newProgress,
        isCompleted: isCompleted,
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('eco_goals').doc(goalId).update({
        'currentProgress': newProgress,
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _userGoals[index] = updatedGoal;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error updating goal progress: $e');
      return false;
    }
  }
  
  Future<bool> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('eco_goals').doc(goalId).delete();
      
      _userGoals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error deleting goal: $e');
      return false;
    }
  }
  
  List<EcoGoal> getGoalsByType(GoalType type) {
    return _userGoals.where((goal) => goal.type == type).toList();
  }
  
  List<EcoGoal> getGoalsByFrequency(GoalFrequency frequency) {
    return _userGoals.where((goal) => goal.frequency == frequency).toList();
  }
  
  List<EcoGoal> getCompletedGoals() {
    return _userGoals.where((goal) => goal.isCompleted).toList();
  }
  
  List<EcoGoal> getActiveGoals() {
    return _userGoals.where((goal) => !goal.isCompleted).toList();
  }
}