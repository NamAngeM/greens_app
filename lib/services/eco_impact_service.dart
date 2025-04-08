// File: lib/services/eco_impact_service.dart
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/models/goal_type.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';
import 'package:greens_app/services/storage_service.dart';

/// Service pour calculer et gérer l'impact écologique des actions utilisateur
class EcoImpactService {
  final StorageService _storageService = StorageService();
  
  // Facteurs de conversion pour les différents types d'objectifs
  static const Map<GoalType, double> _co2FactorsByType = {
    GoalType.water: 0.5,     // kg CO2 par litre économisé
    GoalType.energy: 0.8,    // kg CO2 par kWh économisé
    GoalType.waste: 2.5,     // kg CO2 par kg de déchets évités
    GoalType.transport: 0.2, // kg CO2 par km en transport durable
    GoalType.food: 1.5,      // kg CO2 par repas végétarien
    GoalType.community: 1.0, // kg CO2 par action communautaire
    GoalType.other: 0.3,     // kg CO2 par action générique
  };
  
  /// Calcule la réduction de CO2 pour un objectif écologique
  double calculateCO2Reduction(EcoGoal goal) {
    final factor = _co2FactorsByType[goal.type] ?? 0.3;
    final progress = goal.currentProgress / goal.target;
    return factor * goal.currentProgress * progress;
  }
  
  /// Calcule l'impact communautaire pour un défi
  double calculateCommunityImpact(CommunityChallenge challenge) {
    // Facteur de base pour le type de défi
    double baseFactor = 1.0;
    
    // Bonus pour le nombre de participants
    double participantBonus = challenge.participants.length * 0.1;
    
    // Bonus pour la durée du défi (en jours)
    int durationDays = challenge.endDate.difference(challenge.startDate).inDays;
    double durationBonus = durationDays * 0.05;
    
    return (baseFactor + participantBonus + durationBonus) * 10; // kg CO2
  }
  
  /// Vérifie si un utilisateur mérite un badge basé sur ses objectifs
  Future<List<EcoBadge>> checkEligibleBadges(String userId, List<EcoGoal> goals) async {
    List<EcoBadge> eligibleBadges = [];
    
    // Vérifier les badges pour chaque type d'objectif
    for (GoalType type in GoalType.values) {
      final typeGoals = goals.where((g) => g.type == type).toList();
      if (typeGoals.isEmpty) continue;
      
      // Calculer le progrès total pour ce type d'objectif
      double totalProgress = typeGoals.fold(0, (sum, goal) => 
          sum + (goal.currentProgress / goal.target));
      
      // Déterminer le niveau de badge en fonction du progrès
      BadgeLevel level;
      if (totalProgress >= 5) {
        level = BadgeLevel.platinum;
      } else if (totalProgress >= 3) {
        level = BadgeLevel.gold;
      } else if (totalProgress >= 2) {
        level = BadgeLevel.silver;
      } else {
        level = BadgeLevel.bronze;
      }
      
      // Calculer l'impact CO2 total
      double totalCO2Impact = typeGoals.fold(0, (sum, goal) => 
          sum + calculateCO2Reduction(goal));
      
      // Créer un badge si l'impact est significatif
      if (totalCO2Impact > 0) {
        String title = _getBadgeTitle(type, level);
        String description = _getBadgeDescription(type, totalCO2Impact);
        
        EcoBadge badge = EcoBadge(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          title: title,
          description: description,
          imageUrl: _getBadgeImageUrl(type, level),
          category: _mapGoalTypeToBadgeCategory(type),
          level: level,
          pointsAwarded: _calculatePoints(level, totalCO2Impact),
          dateAwarded: DateTime.now(),
          earnedDate: DateTime.now(),
          createdAt: DateTime.now(),
          isUnlocked: true,
          criteria: {'co2Reduction': totalCO2Impact},
          badgeColor: _getBadgeColor(level),
        );
        
        eligibleBadges.add(badge);
      }
    }
    
    return eligibleBadges;
  }
  
  /// Attribue des badges basés sur l'impact communautaire
  Future<List<EcoBadge>> awardCommunityBadges(String userId, List<CommunityChallenge> challenges) async {
    List<EcoBadge> awardedBadges = [];
    
    // Calculer l'impact total des défis
    double totalImpact = challenges.fold(0, (sum, challenge) => 
        sum + calculateCommunityImpact(challenge));
    
    // Attribuer un badge si l'impact est significatif
    if (totalImpact > 10) {
      BadgeLevel level = _determineLevelFromImpact(totalImpact);
      
      EcoBadge badge = EcoBadge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: 'Champion Communautaire',
        description: 'Pour avoir contribué à réduire ${totalImpact.toStringAsFixed(1)} kg de CO2 via des défis communautaires',
        imageUrl: 'assets/images/badges/community_${level.toString().split('.').last}.png',
        category: BadgeCategory.community,
        level: level,
        pointsAwarded: _calculatePoints(level, totalImpact),
        dateAwarded: DateTime.now(),
        earnedDate: DateTime.now(),
        createdAt: DateTime.now(),
        isUnlocked: true,
        criteria: {'co2Reduction': totalImpact},
        badgeColor: _getBadgeColor(level),
      );
      
      awardedBadges.add(badge);
    }
    
    return awardedBadges;
  }
  
  // Méthodes utilitaires privées
  BadgeCategory _mapGoalTypeToBadgeCategory(GoalType type) {
    switch (type) {
      case GoalType.water:
        return BadgeCategory.waterSaving;
      case GoalType.energy:
        return BadgeCategory.energySaving;
      case GoalType.waste:
        return BadgeCategory.wasteReduction;
      case GoalType.transport:
        return BadgeCategory.transportation;
      case GoalType.food:
        return BadgeCategory.sustainableShopping;
      case GoalType.community:
        return BadgeCategory.community;
      default:
        return BadgeCategory.generalEcology;
    }
  }
  
  String _getBadgeTitle(GoalType type, BadgeLevel level) {
    String typeStr = '';
    switch (type) {
      case GoalType.water:
        typeStr = 'Économie d\'Eau';
        break;
      case GoalType.energy:
        typeStr = 'Économie d\'Énergie';
        break;
      case GoalType.waste:
        typeStr = 'Réduction des Déchets';
        break;
      case GoalType.transport:
        typeStr = 'Transport Durable';
        break;
      case GoalType.food:
        typeStr = 'Alimentation Durable';
        break;
      case GoalType.community:
        typeStr = 'Action Communautaire';
        break;
      default:
        typeStr = 'Écologie';
    }
    
    String levelStr = '';
    switch (level) {
      case BadgeLevel.bronze:
        levelStr = 'Débutant';
        break;
      case BadgeLevel.silver:
        levelStr = 'Intermédiaire';
        break;
      case BadgeLevel.gold:
        levelStr = 'Expert';
        break;
      case BadgeLevel.platinum:
        levelStr = 'Maître';
        break;
    }
    
    return '$typeStr - $levelStr';
  }
  
  String _getBadgeDescription(GoalType type, double co2Impact) {
    return 'Vous avez contribué à réduire ${co2Impact.toStringAsFixed(1)} kg de CO2 grâce à vos actions de ${_getTypeString(type)}.';
  }
  
  String _getTypeString(GoalType type) {
    switch (type) {
      case GoalType.water:
        return 'conservation d\'eau';
      case GoalType.energy:
        return 'économie d\'énergie';
      case GoalType.waste:
        return 'réduction des déchets';
      case GoalType.transport:
        return 'transport durable';
      case GoalType.food:
        return 'alimentation durable';
      case GoalType.community:
        return 'participation communautaire';
      default:
        return 'actions écologiques';
    }
  }
  
  String _getBadgeImageUrl(GoalType type, BadgeLevel level) {
    String typeStr = type.toString().split('.').last;
    String levelStr = level.toString().split('.').last;
    return 'assets/images/badges/${typeStr}_${levelStr}.png';
  }
  
  String _getBadgeColor(BadgeLevel level) {
    switch (level) {
      case BadgeLevel.bronze:
        return '#CD7F32';
      case BadgeLevel.silver:
        return '#C0C0C0';
      case BadgeLevel.gold:
        return '#FFD700';
      case BadgeLevel.platinum:
        return '#E5E4E2';
    }
  }
  
  int _calculatePoints(BadgeLevel level, double impact) {
    int basePoints;
    switch (level) {
      case BadgeLevel.bronze:
        basePoints = 50;
        break;
      case BadgeLevel.silver:
        basePoints = 100;
        break;
      case BadgeLevel.gold:
        basePoints = 200;
        break;
      case BadgeLevel.platinum:
        basePoints = 500;
        break;
    }
    
    return basePoints + (impact * 2).round();
  }
  
  BadgeLevel _determineLevelFromImpact(double impact) {
    if (impact > 100) {
      return BadgeLevel.platinum;
    } else if (impact > 50) {
      return BadgeLevel.gold;
    } else if (impact > 25) {
      return BadgeLevel.silver;
    } else {
      return BadgeLevel.bronze;
    }
  }
}
