// lib/services/eco_journey_service.dart
import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';

/// Service qui guide l'utilisateur à travers un parcours écologique cohérent
/// Connecte les différentes fonctionnalités de l'application
class EcoJourneyService {
  final EcoGoalController _goalController;
  final EcoBadgeController _badgeController;
  final CommunityController _communityController;
  
  EcoJourneyService(
    this._goalController,
    this._badgeController,
    this._communityController,
  );
  
  /// Niveau écologique de l'utilisateur basé sur ses activités
  Future<int> getUserEcoLevel(String userId) async {
    // Charger les données d'abord
    await _goalController.getUserGoals(userId);
    await _badgeController.getUserBadges(userId);
    
    // Accéder aux données via les getters des contrôleurs
    final goals = _goalController.userGoals;
    final badges = _badgeController.userBadges;
    final challenges = await _communityController.getUserChallenges(userId);
    
    // Calcul du niveau basé sur le nombre d'objectifs, badges et défis
    final goalPoints = goals.length * 5;
    final badgePoints = badges.length * 10;
    final challengePoints = challenges.length * 15;
    
    final totalPoints = goalPoints + badgePoints + challengePoints;
    
    // Niveau = points totaux / 25 (arrondi à l'entier inférieur)
    return (totalPoints / 25).floor();
  }
  
  /// Titre du niveau écologique
  String getLevelTitle(int level) {
    if (level <= 1) return "Éco-débutant";
    if (level <= 3) return "Éco-conscient";
    if (level <= 5) return "Éco-engagé";
    if (level <= 8) return "Éco-champion";
    if (level <= 12) return "Éco-expert";
    return "Éco-visionnaire";
  }
  
  /// Suggère la prochaine action écologique à l'utilisateur
  Future<Map<String, dynamic>> suggestNextAction(String userId) async {
    // Charger les données d'abord
    await _goalController.getUserGoals(userId);
    await _badgeController.getUserBadges(userId);
    
    // Accéder aux données via les getters des contrôleurs
    final goals = _goalController.userGoals;
    final badges = _badgeController.userBadges;
    final challenges = await _communityController.getUserChallenges(userId);
    
    // Si l'utilisateur n'a pas d'objectifs, suggérer d'en créer un
    if (goals.isEmpty) {
      return {
        'type': 'goal',
        'action': 'create',
        'message': 'Commencez votre parcours écologique en créant votre premier objectif !',
        'icon': Icons.add_circle,
        'route': '/goals/create',
      };
    }
    
    // Si l'utilisateur a des objectifs mais pas de défis, suggérer d'en rejoindre un
    if (challenges.isEmpty) {
      return {
        'type': 'challenge',
        'action': 'join',
        'message': 'Rejoignez un défi communautaire pour amplifier votre impact !',
        'icon': Icons.people,
        'route': '/community',
      };
    }
    
    // Si l'utilisateur a des objectifs avec peu de progrès, suggérer de les avancer
    final lowProgressGoals = goals.where((goal) => 
      goal.currentProgress / goal.target < 0.3).toList();
    
    if (lowProgressGoals.isNotEmpty) {
      final goal = lowProgressGoals.first;
      return {
        'type': 'goal',
        'action': 'progress',
        'goalId': goal.id,
        'message': 'Continuez à progresser sur votre objectif "${goal.title}" !',
        'icon': Icons.trending_up,
        'route': '/goals/${goal.id}',
      };
    }
    
    // Suggérer d'explorer les produits écologiques
    return {
      'type': 'product',
      'action': 'explore',
      'message': 'Découvrez des produits écologiques qui correspondent à vos objectifs !',
      'icon': Icons.shopping_bag,
      'route': '/products',
    };
  }
  
  /// Génère un arbre de progression visuel pour l'utilisateur
  Map<String, dynamic> generateProgressTree(List goals, List badges) {
    // Structure de l'arbre de progression
    final tree = {
      'level': goals.length + badges.length,
      'growthPercentage': _calculateOverallProgress(goals) / 100,
      'totalLeaves': goals.where((goal) => goal.isCompleted).length,
      'totalBranches': goals.length,
      'milestones': _generateMilestones(goals, badges),
    };
    return tree;
  }
  
  /// Calcule la progression globale de l'utilisateur
  double _calculateOverallProgress(List goals) {
    if (goals.isEmpty) return 0.0;
    
    double totalProgress = 0;
    for (final goal in goals) {
      totalProgress += goal.currentProgress / goal.target;
    }
    
    return (totalProgress / goals.length) * 100;
  }
  
  /// Génère les jalons de progression
  List<Map<String, dynamic>> _generateMilestones(List goals, List badges) {
    final milestones = <Map<String, dynamic>>[];
    
    // Ajouter les objectifs comme jalons
    for (final goal in goals) {
      milestones.add({
        'type': 'goal',
        'id': goal.id,
        'title': goal.title,
        'progress': goal.currentProgress / goal.target,
        'isCompleted': goal.isCompleted,
        'date': goal.createdAt,
      });
    }
    
    // Ajouter les badges comme jalons
    badges.forEach((badge) {
      milestones.add({
        'type': 'badge',
        'id': badge.id,
        'title': badge.title,
        'date': badge.earnedDate,
        'isCompleted': badge.isUnlocked,
      });
    });
    
    // Trier par date
    milestones.sort((a, b) => a['date'].compareTo(b['date']));
    
    return milestones;
  }
}