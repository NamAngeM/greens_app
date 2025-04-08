import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:greens_app/services/eco_metrics_service.dart'; // Importation correcte du service EcoMetricsService

class EcoBadgeController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Garder pour la compatibilité
  final List<EcoBadge> _userBadges = [];
  bool _isLoading = false;
  
  // Métriques d'impact écologique pour les badges
  double _totalCO2Reduction = 0.0;
  int _totalActionsCompleted = 0;
  
  List<EcoBadge> get userBadges => _userBadges;
  bool get isLoading => _isLoading;
  
  // Getters pour les métriques d'impact
  double get totalCO2Reduction => _totalCO2Reduction;
  int get totalActionsCompleted => _totalActionsCompleted;
  
  Future<void> getUserBadges(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _storageService.getCollection(
          'eco_badges',
          field: 'userId',
          isEqualTo: userId,
          orderBy: 'earnedDate',
          descending: true);
      
      _userBadges.clear();
      _totalCO2Reduction = 0.0;
      _totalActionsCompleted = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final badge = EcoBadge.fromJson(data);
        _userBadges.add(badge);
        
        // Calculer les métriques d'impact
        if (data.containsKey('co2Reduction')) {
          _totalCO2Reduction += (data['co2Reduction'] as num).toDouble();
        }
        _totalActionsCompleted++;
      }
    } catch (e) {
      print('Error fetching user badges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<String?> createBadge({
    required String userId,
    required String title,
    required String description,
    required BadgeCategory category,
    required BadgeLevel level,
    required String imageUrl,
    required int pointsAwarded,
    Map<String, dynamic>? criteria,
    String? badgeColor,
  }) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      
      final newBadge = EcoBadge(
        id: uuid,
        userId: userId,
        title: title,
        description: description,
        category: category,
        level: level,
        imageUrl: imageUrl,
        pointsAwarded: pointsAwarded,
        dateAwarded: now,
        earnedDate: now,
        criteria: criteria,
        createdAt: now,
        badgeColor: badgeColor ?? _getBadgeColorForCategory(category),
      );
      
      await _firestore.collection('eco_badges').doc(uuid).set(newBadge.toJson());
      
      _userBadges.insert(0, newBadge);
      notifyListeners();
      
      return uuid;
    } catch (e) {
      print('Error creating badge: $e');
      rethrow;
    }
  }

  String _getBadgeColorForCategory(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.conservation:
        return '#4CAF50'; // Green
      case BadgeCategory.recycling:
        return '#2196F3'; // Blue
      case BadgeCategory.energy:
        return '#FFC107'; // Amber
      case BadgeCategory.transportation:
        return '#9C27B0'; // Purple
      case BadgeCategory.community:
        return '#FF5722'; // Deep Orange
      case BadgeCategory.special:
        return '#E91E63'; // Pink
      case BadgeCategory.generalEcology:
        return '#8BC34A'; // Light Green
      case BadgeCategory.wasteReduction:
        return '#00BCD4'; // Cyan
      case BadgeCategory.waterSaving:
        return '#03A9F4'; // Light Blue
      case BadgeCategory.energySaving:
        return '#FFEB3B'; // Yellow
      case BadgeCategory.sustainableShopping:
        return '#FF9800'; // Orange
      default:
        return '#4CAF50'; // Default Green
    }
  }
  
  Future<bool> toggleBadgeDisplay(String badgeId, bool isDisplayed) async {
    try {
      final index = _userBadges.indexWhere((badge) => badge.id == badgeId);
      if (index == -1) return false;
      
      await _firestore.collection('eco_badges').doc(badgeId).update({
        'isDisplayedOnProfile': isDisplayed,
      });
      
      final updatedBadge = EcoBadge(
        id: _userBadges[index].id,
        userId: _userBadges[index].userId,
        title: _userBadges[index].title,
        description: _userBadges[index].description,
        category: _userBadges[index].category,
        level: _userBadges[index].level,
        imageUrl: _userBadges[index].imageUrl,
        pointsAwarded: _userBadges[index].pointsAwarded,
        dateAwarded: _userBadges[index].dateAwarded,
        earnedDate: _userBadges[index].earnedDate,
        criteria: _userBadges[index].criteria,
        isDisplayedOnProfile: isDisplayed,
        createdAt: _userBadges[index].createdAt,
      );
      
      _userBadges[index] = updatedBadge;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error toggling badge display: $e');
      return false;
    }
  }
  
  List<EcoBadge> getBadgesByCategory(BadgeCategory category) {
    return _userBadges.where((badge) => badge.category == category).toList();
  }
  
  List<EcoBadge> getBadgesByLevel(BadgeLevel level) {
    return _userBadges.where((badge) => badge.level == level).toList();
  }
  
  // Check if user has earned a specific badge
  bool hasEarnedBadge(String badgeTitle) {
    return _userBadges.any((badge) => badge.title == badgeTitle);
  }
  
  // Get total points from badges
  int getTotalBadgePoints() {
    return _userBadges.fold(0, (sum, badge) => sum + badge.pointsAwarded);
  }
  
  // Check if user qualifies for new badges based on completed goals
  Future<List<EcoBadge>> checkForNewBadges(
    String userId, 
    int completedGoalsCount,
    Map<String, int> goalsByCategory,
  ) async {
    List<EcoBadge> newBadges = [];
    
    // Example badge criteria
    if (completedGoalsCount >= 5 && !hasEarnedBadge('Eco Starter')) {
      final badge = await createBadge(
        userId: userId,
        title: 'Eco Starter',
        description: 'Completed 5 ecological goals',
        category: BadgeCategory.generalEcology,
        level: BadgeLevel.bronze,
        imageUrl: 'assets/badges/eco_starter.png',
        pointsAwarded: 50,
        criteria: {'completedGoals': 5},
      );
      
      if (badge != null) {
        newBadges.add(EcoBadge.fromJson({
          'id': badge,
          'userId': userId,
          'title': 'Eco Starter',
          'description': 'Completed 5 ecological goals',
          'category': BadgeCategory.generalEcology,
          'level': BadgeLevel.bronze,
          'imageUrl': 'assets/badges/eco_starter.png',
          'pointsAwarded': 50,
          'dateAwarded': DateTime.now(),
          'earnedDate': DateTime.now(),
          'criteria': {'completedGoals': 5},
          'createdAt': DateTime.now(),
          'badgeColor': _getBadgeColorForCategory(BadgeCategory.generalEcology),
        }));
      }
    }
    
    if (completedGoalsCount >= 15 && !hasEarnedBadge('Eco Enthusiast')) {
      final badge = await createBadge(
        userId: userId,
        title: 'Eco Enthusiast',
        description: 'Completed 15 ecological goals',
        category: BadgeCategory.generalEcology,
        level: BadgeLevel.silver,
        imageUrl: 'assets/badges/eco_enthusiast.png',
        pointsAwarded: 100,
        criteria: {'completedGoals': 15},
      );
      
      if (badge != null) {
        newBadges.add(EcoBadge.fromJson({
          'id': badge,
          'userId': userId,
          'title': 'Eco Enthusiast',
          'description': 'Completed 15 ecological goals',
          'category': BadgeCategory.generalEcology,
          'level': BadgeLevel.silver,
          'imageUrl': 'assets/badges/eco_enthusiast.png',
          'pointsAwarded': 100,
          'dateAwarded': DateTime.now(),
          'earnedDate': DateTime.now(),
          'criteria': {'completedGoals': 15},
          'createdAt': DateTime.now(),
          'badgeColor': _getBadgeColorForCategory(BadgeCategory.generalEcology),
        }));
      }
    }
    
    // Category-specific badges
    for (var entry in goalsByCategory.entries) {
      String category = entry.key;
      int count = entry.value;
      
      BadgeCategory badgeCategory;
      switch (category) {
        case 'wasteReduction':
          badgeCategory = BadgeCategory.wasteReduction;
          break;
        case 'waterSaving':
          badgeCategory = BadgeCategory.waterSaving;
          break;
        case 'energySaving':
          badgeCategory = BadgeCategory.energySaving;
          break;
        case 'sustainableShopping':
          badgeCategory = BadgeCategory.sustainableShopping;
          break;
        case 'transportation':
          badgeCategory = BadgeCategory.transportation;
          break;
        default:
          badgeCategory = BadgeCategory.generalEcology;
      }
      
      if (count >= 3 && !hasEarnedBadge('$category Beginner')) {
        final badge = await createBadge(
          userId: userId,
          title: '$category Beginner',
          description: 'Completed 3 $category goals',
          category: badgeCategory,
          level: BadgeLevel.bronze,
          imageUrl: 'assets/badges/${category.toLowerCase()}_beginner.png',
          pointsAwarded: 30,
          criteria: {category: 3},
        );
        
        if (badge != null) {
          newBadges.add(EcoBadge.fromJson({
            'id': badge,
            'userId': userId,
            'title': '$category Beginner',
            'description': 'Completed 3 $category goals',
            'category': badgeCategory,
            'level': BadgeLevel.bronze,
            'imageUrl': 'assets/badges/${category.toLowerCase()}_beginner.png',
            'pointsAwarded': 30,
            'dateAwarded': DateTime.now(),
            'earnedDate': DateTime.now(),
            'criteria': {category: 3},
            'createdAt': DateTime.now(),
            'badgeColor': _getBadgeColorForCategory(badgeCategory),
          }));
        }
      }
    }
    
    return newBadges;
  }
  
  // Nouvelle méthode pour lier les badges aux objectifs écologiques
  Future<void> checkAndAwardBadgesForGoals(String userId, List<EcoGoal> goals) async {
    if (goals.isEmpty) return;
    
    try {
      // Utiliser le service d'impact écologique pour calculer les badges éligibles
      final ecoMetricsService = EcoMetricsService(); // Importation correcte du service EcoMetricsService
      final eligibleBadges = await ecoMetricsService.checkEligibleBadges(userId, goals);
      
      // Attribuer les nouveaux badges
      for (final badge in eligibleBadges) {
        await createBadge(
          userId: userId,
          title: badge.title,
          description: badge.description,
          category: badge.category,
          level: badge.level,
          imageUrl: badge.imageUrl,
          pointsAwarded: badge.pointsAwarded,
          criteria: badge.criteria,
          badgeColor: badge.badgeColor,
        );
      }
      
      // Mettre à jour la liste des badges
      await getUserBadges(userId);
    } catch (e) {
      print('Error awarding badges for goals: $e');
    }
  }
}