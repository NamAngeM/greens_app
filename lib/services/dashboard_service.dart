import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats_model.dart';
import '../models/quick_impact_action_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Récupérer les statistiques du tableau de bord
  Future<DashboardStatsModel> getUserStats(String userId) async {
    try {
      // Récupérer les statistiques de l'utilisateur
      final userStatsDoc = await _firestore.collection('user_stats').doc(userId).get();
      
      if (userStatsDoc.exists) {
        // Si un document existe déjà, le convertir en modèle
        return DashboardStatsModel.fromJson({
          'userId': userId,
          ...userStatsDoc.data() as Map<String, dynamic>,
        });
      } else {
        // Créer un document par défaut si l'utilisateur n'a pas encore de statistiques
        final defaultStats = DashboardStatsModel(
          userId: userId,
          lastUpdated: DateTime.now(),
          carbonFootprint: 0,
          carbonSaved: 0,
          carbonTrend: 0,
          productsScanCount: 0,
          avgProductEcoScore: 0,
          ecoFriendlyProductCount: 0,
          activeGoalsCount: 0,
          completedGoalsCount: 0,
          goalCompletionRate: 0,
          participatedChallenges: 0,
          totalCommunityImpact: 0,
          appEnergyUsage: 0,
          energySavingRate: 0,
          totalBadges: 0,
          totalPoints: 0,
          currentLevel: 'Débutant',
          actionsCompleted: 0,
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
        
        // Sauvegarder les statistiques par défaut dans Firestore
        await _firestore.collection('user_stats').doc(userId).set(defaultStats.toJson());
        
        return defaultStats;
      }
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      // Retourner un modèle par défaut en cas d'erreur
      return DashboardStatsModel(
        userId: userId,
        lastUpdated: DateTime.now(),
        carbonFootprint: 0,
        carbonSaved: 0,
        carbonTrend: 0,
        productsScanCount: 0,
        avgProductEcoScore: 0,
        ecoFriendlyProductCount: 0,
        activeGoalsCount: 0,
        completedGoalsCount: 0,
        goalCompletionRate: 0,
        participatedChallenges: 0,
        totalCommunityImpact: 0,
        appEnergyUsage: 0,
        energySavingRate: 0,
        totalBadges: 0,
        totalPoints: 0,
        currentLevel: 'Débutant',
        actionsCompleted: 0,
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
    }
  }
  
  // Mettre à jour les statistiques de l'utilisateur
  Future<void> updateUserStats(DashboardStatsModel stats) async {
    try {
      await _firestore.collection('user_stats').doc(stats.userId).update(stats.toJson());
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques: $e');
      throw Exception('Impossible de mettre à jour les statistiques: $e');
    }
  }
  
  // Ajouter des points après avoir complété une action
  Future<DashboardStatsModel> addActionCompletionStats(
    String userId, 
    int pointsEarned, 
    double carbonSaved,
    ActionCategory category
  ) async {
    try {
      // Récupérer les statistiques actuelles
      final currentStats = await getUserStats(userId);
      
      // Mettre à jour les valeurs
      final updatedStats = currentStats.copyWith(
        totalPoints: currentStats.totalPoints + pointsEarned,
        carbonSaved: currentStats.carbonSaved + carbonSaved,
        actionsCompleted: currentStats.actionsCompleted + 1,
        lastUpdated: DateTime.now(),
      );
      
      // Calculer le nouveau niveau
      final newLevel = updatedStats.calculateLevel();
      final finalStats = updatedStats.copyWith(currentLevel: newLevel);
      
      // Mettre à jour Firestore
      await updateUserStats(finalStats);
      
      return finalStats;
    } catch (e) {
      print('Erreur lors de l\'ajout des statistiques d\'action: $e');
      throw Exception('Impossible de mettre à jour les statistiques d\'action: $e');
    }
  }
  
  // Ajouter un produit scanné aux statistiques
  Future<DashboardStatsModel> addScannedProduct(String userId, String carbonCategory, double ecoScore) async {
    try {
      // Récupérer les statistiques actuelles
      final currentStats = await getUserStats(userId);
      
      // Valeurs par défaut pour la mise à jour
      int highCount = currentStats.highCarbonProductsCount;
      int mediumCount = currentStats.mediumCarbonProductsCount;
      int lowCount = currentStats.lowCarbonProductsCount;
      int ecoFriendlyCount = currentStats.ecoFriendlyProductCount;
      
      // Mettre à jour le compteur approprié selon la catégorie
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
      }
      
      // Mettre à jour le compteur de produits écologiques si le score dépasse un seuil
      if (ecoScore >= 70) {
        ecoFriendlyCount++;
      }
      
      // Calculer la nouvelle moyenne des scores éco
      final newTotalScore = (currentStats.avgProductEcoScore * currentStats.productsScanCount) + ecoScore;
      final newCount = currentStats.productsScanCount + 1;
      final newAvgScore = newTotalScore / newCount;
      
      // Mettre à jour les statistiques
      final updatedStats = currentStats.copyWith(
        productsScanCount: newCount,
        avgProductEcoScore: newAvgScore,
        ecoFriendlyProductCount: ecoFriendlyCount,
        highCarbonProductsCount: highCount,
        mediumCarbonProductsCount: mediumCount,
        lowCarbonProductsCount: lowCount,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour Firestore
      await updateUserStats(updatedStats);
      
      return updatedStats;
    } catch (e) {
      print('Erreur lors de l\'ajout du produit scanné: $e');
      throw Exception('Impossible de mettre à jour les statistiques du produit scanné: $e');
    }
  }
  
  // Récupérer les débloquer un nouvel accomplissement
  Future<DashboardStatsModel> unlockAchievement(
    String userId, 
    String achievementId, 
    String title, 
    String description, 
    int pointsAwarded
  ) async {
    try {
      // Récupérer les statistiques actuelles
      final currentStats = await getUserStats(userId);
      
      // Vérifier si le succès existe déjà
      final existingAchievements = List<Map<String, dynamic>>.from(currentStats.achievements);
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
        final updatedStats = currentStats.copyWith(
          achievements: existingAchievements,
          totalPoints: currentStats.totalPoints + pointsAwarded,
          totalBadges: currentStats.totalBadges + 1,
          lastUpdated: DateTime.now(),
        );
        
        // Recalculer le niveau
        final newLevel = updatedStats.calculateLevel();
        final finalStats = updatedStats.copyWith(currentLevel: newLevel);
        
        // Mettre à jour Firestore
        await updateUserStats(finalStats);
        
        return finalStats;
      }
      
      return currentStats;
    } catch (e) {
      print('Erreur lors du déverrouillage de l\'accomplissement: $e');
      throw Exception('Impossible de déverrouiller l\'accomplissement: $e');
    }
  }
} 