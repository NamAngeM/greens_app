import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:uuid/uuid.dart';

class CommunityController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CommunityChallenge> _challenges = [];
  bool _isLoading = false;
  
  List<CommunityChallenge> get challenges => _challenges;
  bool get isLoading => _isLoading;
  
  Future<void> getChallenges() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('community_challenges')
          .orderBy('startDate', descending: false)
          .get();
      
      _challenges.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        _challenges.add(CommunityChallenge.fromJson(data));
      }
    } catch (e) {
      print('Error fetching challenges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> joinChallenge(String challengeId, String userId) async {
    try {
      final index = _challenges.indexWhere((challenge) => challenge.id == challengeId);
      if (index == -1) return false;
      
      final challenge = _challenges[index];
      
      if (challenge.participants.contains(userId)) {
        return false; // User already joined
      }
      
      final newParticipants = List<String>.from(challenge.participants)..add(userId);
      final updatedChallenge = challenge.copyWith(
        participants: newParticipants,
        participantsCount: challenge.participantsCount + 1,
      );
      
      await _firestore.collection('community_challenges').doc(challengeId).update({
        'participants': newParticipants,
        'participantsCount': FieldValue.increment(1),
      });
      
      _challenges[index] = updatedChallenge;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error joining challenge: $e');
      return false;
    }
  }
  
  Future<bool> leaveChallenge(String challengeId, String userId) async {
    try {
      final index = _challenges.indexWhere((challenge) => challenge.id == challengeId);
      if (index == -1) return false;
      
      final challenge = _challenges[index];
      
      if (!challenge.participants.contains(userId)) {
        return false; // User not in challenge
      }
      
      final newParticipants = List<String>.from(challenge.participants)..remove(userId);
      final updatedChallenge = challenge.copyWith(
        participants: newParticipants,
        participantsCount: challenge.participantsCount - 1,
      );
      
      await _firestore.collection('community_challenges').doc(challengeId).update({
        'participants': newParticipants,
        'participantsCount': FieldValue.increment(-1),
      });
      
      _challenges[index] = updatedChallenge;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error leaving challenge: $e');
      return false;
    }
  }
  
  List<CommunityChallenge> getUpcomingChallenges() {
    return _challenges.where((challenge) => challenge.status == ChallengeStatus.upcoming).toList();
  }
  
  List<CommunityChallenge> getActiveChallenges() {
    return _challenges.where((challenge) => challenge.status == ChallengeStatus.active).toList();
  }
  
  List<CommunityChallenge> getCompletedChallenges() {
    return _challenges.where((challenge) => challenge.status == ChallengeStatus.completed).toList();
  }
  
  List<CommunityChallenge> getUserChallenges(String userId) {
    return _challenges.where((challenge) => challenge.participants.contains(userId)).toList();
  }
}