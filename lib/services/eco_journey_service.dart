// lib/services/eco_journey_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/models/eco_journey_step.dart';
import 'package:greens_app/models/user_eco_level.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service qui guide l'utilisateur à travers un parcours écologique cohérent
/// Connecte les différentes fonctionnalités de l'application
class EcoJourneyService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EcoGoalController _goalController;
  final EcoBadgeController _badgeController;
  final CommunityController _communityController;
  
  EcoJourneyService({
    required EcoGoalController goalController,
    required EcoBadgeController badgeController,
    required CommunityController communityController,
  }) : 
    _goalController = goalController,
    _badgeController = badgeController,
    _communityController = communityController;
  
  // Niveaux écologiques
  final List<UserEcoLevel> _levels = [
    UserEcoLevel(
      level: 1,
      title: 'Débutant écologique',
      description: 'Vous commencez votre voyage vers un mode de vie plus durable.',
      pointsRequired: 0,
      badgeUrl: 'assets/images/badges/level_1.png',
    ),
    UserEcoLevel(
      level: 2,
      title: 'Apprenti vert',
      description: 'Vous avez fait vos premiers pas vers un mode de vie plus écologique.',
      pointsRequired: 100,
      badgeUrl: 'assets/images/badges/level_2.png',
    ),
    UserEcoLevel(
      level: 3,
      title: 'Éco-conscient',
      description: 'Vous prenez régulièrement des décisions respectueuses de l\'environnement.',
      pointsRequired: 250,
      badgeUrl: 'assets/images/badges/level_3.png',
    ),
    UserEcoLevel(
      level: 4,
      title: 'Écologiste en herbe',
      description: 'Votre engagement pour l\'environnement est visible dans votre quotidien.',
      pointsRequired: 500,
      badgeUrl: 'assets/images/badges/level_4.png',
    ),
    UserEcoLevel(
      level: 5,
      title: 'Défenseur de la planète',
      description: 'Vous êtes un modèle pour les autres dans votre engagement écologique.',
      pointsRequired: 1000,
      badgeUrl: 'assets/images/badges/level_5.png',
    ),
    UserEcoLevel(
      level: 6,
      title: 'Éco-guerrier',
      description: 'Votre mode de vie est un exemple de durabilité et de conscience environnementale.',
      pointsRequired: 2000,
      badgeUrl: 'assets/images/badges/level_6.png',
    ),
    UserEcoLevel(
      level: 7,
      title: 'Maître écologique',
      description: 'Vous avez atteint un niveau exceptionnel de durabilité dans votre vie quotidienne.',
      pointsRequired: 3500,
      badgeUrl: 'assets/images/badges/level_7.png',
    ),
    UserEcoLevel(
      level: 8,
      title: 'Gardien de la Terre',
      description: 'Votre engagement pour la planète est total et inspire les autres.',
      pointsRequired: 5000,
      badgeUrl: 'assets/images/badges/level_8.png',
    ),
    UserEcoLevel(
      level: 9,
      title: 'Visionnaire écologique',
      description: 'Vous êtes à l\'avant-garde du mouvement pour un monde plus durable.',
      pointsRequired: 7500,
      badgeUrl: 'assets/images/badges/level_9.png',
    ),
    UserEcoLevel(
      level: 10,
      title: 'Légende verte',
      description: 'Vous avez atteint le plus haut niveau d\'engagement écologique. Félicitations !',
      pointsRequired: 10000,
      badgeUrl: 'assets/images/badges/level_10.png',
    ),
  ];
  
  // Étapes du parcours écologique
  final List<EcoJourneyStep> _journeySteps = [
    EcoJourneyStep(
      id: 'step_1',
      title: 'Premiers pas écologiques',
      description: 'Commencez votre voyage vers un mode de vie plus durable.',
      tasks: [
        'Complétez votre profil écologique',
        'Calculez votre empreinte carbone',
        'Complétez votre premier défi quotidien'
      ],
    ),
    EcoJourneyStep(
      id: 'step_2',
      title: 'Réduire les déchets',
      description: 'Apprenez à réduire vos déchets au quotidien.',
      tasks: [
        'Utilisez un sac réutilisable pour vos courses',
        'Évitez les produits à usage unique pendant une semaine',
        'Créez votre propre compost'
      ],
    ),
    EcoJourneyStep(
      id: 'step_3',
      title: 'Mobilité durable',
      description: 'Adoptez des moyens de transport plus écologiques.',
      tasks: [
        'Utilisez les transports en commun pendant une semaine',
        'Essayez le vélo pour vos déplacements courts',
        'Participez à un covoiturage'
      ],
    ),
    EcoJourneyStep(
      id: 'step_4',
      title: 'Alimentation responsable',
      description: 'Découvrez comment votre alimentation impacte la planète.',
      tasks: [
        'Mangez végétarien pendant trois jours',
        'Achetez des produits locaux et de saison',
        'Réduisez le gaspillage alimentaire pendant une semaine'
      ],
    ),
    EcoJourneyStep(
      id: 'step_5',
      title: 'Économie d\'énergie',
      description: 'Apprenez à réduire votre consommation énergétique.',
      tasks: [
        'Remplacez vos ampoules par des LED',
        'Réduisez votre consommation d\'électricité de 10%',
        'Débranchez les appareils en veille pendant une semaine'
      ],
    ),
    EcoJourneyStep(
      id: 'step_6',
      title: 'Consommation responsable',
      description: 'Adoptez des habitudes d\'achat plus durables.',
      tasks: [
        'Achetez un produit d\'occasion au lieu de neuf',
        'Réparez un objet au lieu de le remplacer',
        'Évitez les achats impulsifs pendant un mois'
      ],
    ),
    EcoJourneyStep(
      id: 'step_7',
      title: 'Empreinte numérique',
      description: 'Réduisez l\'impact environnemental de vos activités numériques.',
      tasks: [
        'Nettoyez votre boîte mail',
        'Réduisez votre temps d\'écran quotidien',
        'Utilisez des moteurs de recherche écologiques'
      ],
    ),
    EcoJourneyStep(
      id: 'step_8',
      title: 'Engagement communautaire',
      description: 'Participez à des actions collectives pour l\'environnement.',
      tasks: [
        'Rejoignez un défi écologique communautaire',
        'Participez à un nettoyage de la nature',
        'Partagez vos connaissances écologiques avec votre entourage'
      ],
    ),
    EcoJourneyStep(
      id: 'step_9',
      title: 'Mode de vie minimaliste',
      description: 'Adoptez un mode de vie plus simple et moins consommateur.',
      tasks: [
        'Désencombrez votre espace de vie',
        'Adoptez la règle "un objet entre, un objet sort"',
        'Créez une capsule vestimentaire durable'
      ],
    ),
    EcoJourneyStep(
      id: 'step_10',
      title: 'Maître de l\'écologie',
      description: 'Devenez un ambassadeur de la durabilité.',
      tasks: [
        'Créez votre propre défi écologique',
        'Mentorez un ami dans son parcours écologique',
        'Atteignez le niveau 10 dans l\'application'
      ],
    ),
  ];
  
  // Getters
  List<UserEcoLevel> get levels => _levels;
  List<EcoJourneyStep> get journeySteps => _journeySteps;
  
  /// Niveau écologique de l'utilisateur basé sur ses activités
  Future<int> getUserEcoLevel(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists && userDoc.data()!.containsKey('ecoPoints')) {
        final ecoPoints = userDoc.data()!['ecoPoints'] as int;
        return _calculateLevel(ecoPoints);
      }
      
      return 1; // Niveau par défaut
    } catch (e) {
      print('Erreur lors de la récupération du niveau écologique: $e');
      return 1; // Niveau par défaut en cas d'erreur
    }
  }
  
  // Calculer le niveau en fonction des points
  int _calculateLevel(int points) {
    for (int i = _levels.length - 1; i >= 0; i--) {
      if (points >= _levels[i].pointsRequired) {
        return _levels[i].level;
      }
    }
    return 1; // Niveau minimum
  }
  
  /// Titre du niveau écologique
  String getLevelTitle(int level) {
    final ecoLevel = _levels.firstWhere(
      (l) => l.level == level,
      orElse: () => _levels.first,
    );
    return ecoLevel.title;
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
  
  // Obtenir les informations complètes du niveau
  UserEcoLevel getLevelInfo(int level) {
    return _levels.firstWhere(
      (l) => l.level == level,
      orElse: () => _levels.first,
    );
  }
  
  // Obtenir les étapes du parcours écologique de l'utilisateur
  Future<List<Map<String, dynamic>>> getUserJourneyProgress(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final completedSteps = userDoc.data()?['completedJourneySteps'] as List<dynamic>? ?? [];
      
      return _journeySteps.map((step) {
        final isCompleted = completedSteps.contains(step.id);
        return {
          'step': step,
          'isCompleted': isCompleted,
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération du parcours écologique: $e');
      return _journeySteps.map((step) => {
        'step': step,
        'isCompleted': false,
      }).toList();
    }
  }
  
  // Marquer une étape comme complétée
  Future<void> completeJourneyStep(String userId, String stepId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'completedJourneySteps': FieldValue.arrayUnion([stepId]),
      });
      
      // Ajouter des points pour l'étape complétée
      await _addEcoPoints(userId, 50); // 50 points par étape complétée
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la complétion de l\'étape: $e');
    }
  }
  
  // Ajouter des points écologiques à l'utilisateur
  Future<void> _addEcoPoints(String userId, int points) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'ecoPoints': FieldValue.increment(points),
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de points: $e');
    }
  }
  
  // Obtenir les points écologiques de l'utilisateur
  Future<int> getUserEcoPoints(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists && userDoc.data()!.containsKey('ecoPoints')) {
        return userDoc.data()!['ecoPoints'] as int;
      }
      
      return 0; // Valeur par défaut
    } catch (e) {
      print('Erreur lors de la récupération des points écologiques: $e');
      return 0; // Valeur par défaut en cas d'erreur
    }
  }
  
  // Obtenir la prochaine étape recommandée pour l'utilisateur
  Future<EcoJourneyStep?> getNextRecommendedStep(String userId) async {
    try {
      final progress = await getUserJourneyProgress(userId);
      
      // Trouver la première étape non complétée
      final nextStep = progress.firstWhere(
        (stepData) => stepData['isCompleted'] == false,
        orElse: () => {'step': null, 'isCompleted': true},
      );
      
      return nextStep['step'] as EcoJourneyStep?;
    } catch (e) {
      print('Erreur lors de la récupération de la prochaine étape: $e');
      return null;
    }
  }
  
  // Obtenir le pourcentage global de progression du parcours
  Future<double> getOverallProgress(String userId) async {
    try {
      final progress = await getUserJourneyProgress(userId);
      final completedSteps = progress.where((stepData) => stepData['isCompleted'] == true).length;
      return completedSteps / _journeySteps.length;
    } catch (e) {
      print('Erreur lors du calcul de la progression globale: $e');
      return 0.0;
    }
  }
}