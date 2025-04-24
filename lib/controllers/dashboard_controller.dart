import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/dashboard_stats_model.dart';

class DashboardController extends ChangeNotifier {
  DashboardStatsModel? _stats;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  DashboardStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Charge les statistiques de l'utilisateur depuis Firestore
  Future<void> loadUserStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final docRef = FirebaseFirestore.instance.collection('user_stats').doc(userId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Convertir le document en modèle DashboardStatsModel
        final data = docSnapshot.data() as Map<String, dynamic>;
        _stats = DashboardStatsModel.fromJson(data);
      } else {
        // Si l'utilisateur n'a pas encore de statistiques, créer un modèle par défaut
        _stats = DashboardStatsModel(
          userId: userId,
          lastUpdated: DateTime.now(),
          carbonSaved: 0,
          totalPoints: 0,
          actionsCompleted: 0,
          productsScanCount: 0,
          ecoFriendlyProductCount: 0,
          highCarbonProductsCount: 0,
          mediumCarbonProductsCount: 0,
          lowCarbonProductsCount: 0,
          currentGoal: null,
          goalsCompleted: 0,
          communityRanking: 0,
          communityContribution: 0,
          deviceUsageHours: 0,
          deviceEnergyUsage: 0,
          achievements: [],
        );
        
        // Enregistrer les statistiques par défaut dans Firestore
        await docRef.set(_stats!.toJson());
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors du chargement des statistiques: $e";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Met à jour les statistiques de l'utilisateur
  Future<void> updateStats(DashboardStatsModel? updatedStats) async {
    if (updatedStats == null) return;
    
    try {
      // Mettre à jour le modèle local
      _stats = updatedStats.copyWith(lastUpdated: DateTime.now());
      notifyListeners();
      
      // Mettre à jour Firestore
      await FirebaseFirestore.instance
          .collection('user_stats')
          .doc(_stats!.userId)
          .update(_stats!.toJson());
    } catch (e) {
      _error = "Erreur lors de la mise à jour des statistiques: $e";
      notifyListeners();
      rethrow;
    }
  }
  
  // Ajoute des points aux statistiques de l'utilisateur
  Future<void> addPoints(int points, {double carbonSaved = 0, bool isAction = false}) async {
    if (_stats == null) return;
    
    try {
      // Mettre à jour le modèle local avec les nouveaux points
      final updatedStats = _stats!.copyWith(
        totalPoints: _stats!.totalPoints + points,
        carbonSaved: _stats!.carbonSaved + carbonSaved,
        actionsCompleted: isAction ? _stats!.actionsCompleted + 1 : _stats!.actionsCompleted,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour les statistiques
      await updateStats(updatedStats);
    } catch (e) {
      _error = "Erreur lors de l'ajout de points: $e";
      notifyListeners();
      rethrow;
    }
  }
  
  // Ajoute un produit scanné aux statistiques
  Future<void> addScannedProduct(String carbonCategory) async {
    if (_stats == null) return;
    
    try {
      var highCount = _stats!.highCarbonProductsCount;
      var mediumCount = _stats!.mediumCarbonProductsCount;
      var lowCount = _stats!.lowCarbonProductsCount;
      var ecoCount = _stats!.ecoFriendlyProductCount;
      
      // Incrémenter le compteur approprié selon la catégorie
      switch (carbonCategory.toLowerCase()) {
        case 'high':
          highCount++;
          break;
        case 'medium':
          mediumCount++;
          break;
        case 'low':
          lowCount++;
          break;
        case 'eco':
          ecoCount++;
          break;
      }
      
      // Mettre à jour le modèle
      final updatedStats = _stats!.copyWith(
        productsScanCount: _stats!.productsScanCount + 1,
        highCarbonProductsCount: highCount,
        mediumCarbonProductsCount: mediumCount,
        lowCarbonProductsCount: lowCount,
        ecoFriendlyProductCount: ecoCount,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour les statistiques
      await updateStats(updatedStats);
    } catch (e) {
      _error = "Erreur lors de l'ajout du produit scanné: $e";
      notifyListeners();
      rethrow;
    }
  }
  
  // Ajoute un succès aux statistiques de l'utilisateur
  Future<void> addAchievement(String achievementId, String title, String description, int pointsAwarded) async {
    if (_stats == null) return;
    
    try {
      // Vérifier si le succès existe déjà
      final existingAchievements = _stats!.achievements.toList();
      final achievementExists = existingAchievements.any((a) => a['id'] == achievementId);
      
      if (!achievementExists) {
        // Ajouter le nouveau succès
        existingAchievements.add({
          'id': achievementId,
          'title': title,
          'description': description,
          'dateUnlocked': DateTime.now().toIso8601String(),
          'pointsAwarded': pointsAwarded,
        });
        
        // Mettre à jour le modèle avec le nouveau succès et les points associés
        final updatedStats = _stats!.copyWith(
          achievements: existingAchievements,
          totalPoints: _stats!.totalPoints + pointsAwarded,
          lastUpdated: DateTime.now(),
        );
        
        // Mettre à jour les statistiques
        await updateStats(updatedStats);
      }
    } catch (e) {
      _error = "Erreur lors de l'ajout du succès: $e";
      notifyListeners();
      rethrow;
    }
  }
} 