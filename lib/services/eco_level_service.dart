// lib/services/eco_level_service.dart
import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_level_model.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/services/carbon_footprint_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service qui gère les niveaux d'expertise écologique et les récompenses
class EcoLevelService extends ChangeNotifier {
  final EcoGoalController _goalController;
  final EcoBadgeController _badgeController;
  final CommunityController _communityController;
  final CarbonFootprintService _carbonService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // Singleton
  static final EcoLevelService _instance = EcoLevelService._internal(
    EcoGoalController(),
    EcoBadgeController(),
    CommunityController(),
    CarbonFootprintService(),
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
  
  factory EcoLevelService() {
    return _instance;
  }
  
  EcoLevelService._internal(
    this._goalController,
    this._badgeController,
    this._communityController,
    this._carbonService,
    this._firestore,
    this._auth,
  );
  
  static EcoLevelService get instance => _instance;
  
  // Données utilisateur
  int _userPoints = 0;
  EcoLevel _userLevel = EcoLevel.beginner;
  List<String> _userAchievements = [];
  List<Map<String, dynamic>> _recentRewards = [];
  String _currentUserId = '';
  
  // Getters
  int get userPoints => _userPoints;
  EcoLevel get userLevel => _userLevel;
  String get userLevelTitle => EcoLevelSystem.getLevelTitle(_userLevel);
  List<String> get userAchievements => _userAchievements;
  List<Map<String, dynamic>> get recentRewards => _recentRewards;
  double get progressToNextLevel => EcoLevelSystem.getProgressToNextLevel(_userPoints);
  int get pointsToNextLevel => EcoLevelSystem.getPointsToNextLevel(_userPoints);
  String get levelDescription => EcoLevelSystem.getLevelDescription(_userLevel);
  List<String> get levelBenefits => EcoLevelSystem.getLevelBenefits(_userLevel);
  String get levelColor => EcoLevelSystem.getLevelColor(_userLevel);
  String get levelIcon => EcoLevelSystem.getLevelIcon(_userLevel);
  String get currentUserId => _currentUserId;
  EcoLevel? get nextLevel => _userLevel == EcoLevel.expert ? null : EcoLevel.values[_userLevel.index + 1];
  
  /// Initialise le service et charge les données utilisateur
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      await loadUserData(user.uid);
    }
  }
  
  /// Charge les données de niveau et de points de l'utilisateur
  Future<void> loadUserData(String userId) async {
    try {
      // Charger les données de niveau depuis Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        
        _userPoints = userData['ecoPoints'] ?? 0;
        _userLevel = EcoLevelSystem.getLevelFromPoints(_userPoints);
        _userAchievements = List<String>.from(userData['achievements'] ?? []);
        
        // Charger les récompenses récentes
        final rewardsQuery = await _firestore
            .collection('users')
            .doc(userId)
            .collection('rewards')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();
        
        _recentRewards = rewardsQuery.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc.data()['title'] ?? '',
                  'description': doc.data()['description'] ?? '',
                  'points': doc.data()['points'] ?? 0,
                  'timestamp': doc.data()['timestamp']?.toDate() ?? DateTime.now(),
                  'type': doc.data()['type'] ?? 'achievement',
                })
            .toList();
      } else {
        // Initialiser les données par défaut
        await _firestore.collection('users').doc(userId).set({
          'ecoPoints': 0,
          'achievements': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      notifyListeners();
    } catch (e) {
      print('EcoLevelService: Erreur lors du chargement des données utilisateur: $e');
    }
  }
  
  /// Calcule le niveau écologique basé sur toutes les activités de l'utilisateur
  Future<void> calculateUserLevel(String userId) async {
    try {
      // Charger les données nécessaires
      await _goalController.getUserGoals(userId);
      await _badgeController.getUserBadges(userId);
      final challenges = await _communityController.getUserChallenges(userId);
      final footprint = await _carbonService.getUserCarbonFootprint(userId);
      
      // Points de base pour les objectifs
      int goalPoints = 0;
      for (final goal in _goalController.userGoals) {
        // Points pour la progression
        goalPoints += ((goal.currentProgress / goal.target) * 20).floor();
        
        // Bonus pour les objectifs complétés
        if (goal.isCompleted) {
          goalPoints += 50;
        }
      }
      
      // Points pour les badges
      final badgePoints = _badgeController.userBadges.length * 75;
      
      // Points pour les défis communautaires
      int challengePoints = 0;
      for (final challenge in challenges) {
        // Points de base pour participation
        challengePoints += 30;
        
        // Bonus pour les défis complétés
        if (challenge.isCompleted) {
          challengePoints += 100;
        }
      }
      
      // Points pour l'empreinte carbone (réduction par rapport à la moyenne)
      int carbonPoints = 0;
      if (footprint != null) {
        // Moyenne nationale (exemple: 10000)
        const averageFootprint = 10000.0;
        
        // Si l'empreinte est inférieure à la moyenne, attribuer des points
        if (footprint.totalScore < averageFootprint) {
          final reduction = (averageFootprint - footprint.totalScore) / 100;
          carbonPoints = reduction.floor();
        }
      }
      
      // Calculer le total des points
      final totalPoints = goalPoints + badgePoints + challengePoints + carbonPoints;
      
      // Mettre à jour les points et le niveau de l'utilisateur
      await _firestore.collection('users').doc(userId).update({
        'ecoPoints': totalPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Mettre à jour les variables locales
      _userPoints = totalPoints;
      _userLevel = EcoLevelSystem.getLevelFromPoints(totalPoints);
      
      // Vérifier si l'utilisateur a atteint un nouveau niveau
      await _checkLevelUpAchievement(userId);
      
      notifyListeners();
    } catch (e) {
      print('EcoLevelService: Erreur lors du calcul du niveau utilisateur: $e');
    }
  }
  
  /// Vérifie si l'utilisateur a atteint un nouveau niveau et attribue une récompense
  Future<void> _checkLevelUpAchievement(String userId) async {
    try {
      // Récupérer l'ancien niveau enregistré
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final oldLevel = userDoc.data()?['ecoLevel'] ?? 'beginner';
      
      // Convertir la chaîne en enum
      final oldLevelEnum = EcoLevel.values.firstWhere(
        (e) => e.toString().split('.').last == oldLevel,
        orElse: () => EcoLevel.beginner,
      );
      
      // Si le niveau a augmenté
      if (_userLevel.index > oldLevelEnum.index) {
        // Enregistrer le nouveau niveau
        await _firestore.collection('users').doc(userId).update({
          'ecoLevel': _userLevel.toString().split('.').last,
        });
        
        // Créer une récompense pour le niveau atteint
        await _addReward(
          userId: userId,
          title: 'Niveau ${EcoLevelSystem.getLevelTitle(_userLevel)} atteint !',
          description: 'Félicitations ! Vous avez atteint le niveau ${EcoLevelSystem.getLevelTitle(_userLevel)}.',
          points: 100,
          type: 'level_up',
        );
        
        // Ajouter un badge pour le nouveau niveau
        await _badgeController.addBadgeToUser(
          userId: userId,
          badgeId: 'level_${_userLevel.toString().split('.').last}',
          title: 'Niveau ${EcoLevelSystem.getLevelTitle(_userLevel)}',
          description: 'A atteint le niveau ${EcoLevelSystem.getLevelTitle(_userLevel)}',
          category: 'level',
        );
        
        // Afficher une notification (à implémenter dans l'UI)
      }
    } catch (e) {
      print('EcoLevelService: Erreur lors de la vérification de niveau: $e');
    }
  }
  
  /// Ajoute des points à l'utilisateur pour une action écologique
  Future<Map<String, dynamic>> addPointsForAction({
    required String userId,
    required String actionTitle,
    required String actionDescription,
    required int points,
    String type = 'action',
  }) async {
    try {
      // Mettre à jour les points dans Firestore
      await _firestore.collection('users').doc(userId).update({
        'ecoPoints': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Ajouter la récompense
      final reward = await _addReward(
        userId: userId,
        title: actionTitle,
        description: actionDescription,
        points: points,
        type: type,
      );
      
      // Mettre à jour les variables locales
      _userPoints += points;
      _userLevel = EcoLevelSystem.getLevelFromPoints(_userPoints);
      
      // Vérifier si l'utilisateur a atteint un nouveau niveau
      await _checkLevelUpAchievement(userId);
      
      notifyListeners();
      
      return reward;
    } catch (e) {
      print('EcoLevelService: Erreur lors de l\'ajout de points: $e');
      return {
        'error': e.toString(),
        'success': false,
      };
    }
  }
  
  /// Ajoute une récompense à l'utilisateur
  Future<Map<String, dynamic>> _addReward({
    required String userId,
    required String title,
    required String description,
    required int points,
    required String type,
  }) async {
    try {
      // Créer la récompense dans Firestore
      final rewardRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('rewards')
          .doc();
      
      final reward = {
        'title': title,
        'description': description,
        'points': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
      };
      
      await rewardRef.set(reward);
      
      // Ajouter à la liste locale des récompenses récentes
      final newReward = {
        'id': rewardRef.id,
        'title': title,
        'description': description,
        'points': points,
        'timestamp': DateTime.now(),
        'type': type,
      };
      
      _recentRewards.insert(0, newReward);
      if (_recentRewards.length > 10) {
        _recentRewards.removeLast();
      }
      
      notifyListeners();
      
      return {
        'id': rewardRef.id,
        'success': true,
        ...reward,
      };
    } catch (e) {
      print('EcoLevelService: Erreur lors de l\'ajout d\'une récompense: $e');
      return {
        'error': e.toString(),
        'success': false,
      };
    }
  }
  
  /// Vérifie si l'utilisateur a débloqué de nouveaux achievements
  Future<void> checkForNewAchievements(String userId) async {
    try {
      // Charger les données nécessaires
      await _goalController.getUserGoals(userId);
      await _badgeController.getUserBadges(userId);
      final challenges = await _communityController.getUserChallenges(userId);
      
      // Liste des achievements potentiels
      final achievements = [
        {
          'id': 'first_goal',
          'title': 'Premier objectif',
          'condition': _goalController.userGoals.isNotEmpty,
          'description': 'Créer votre premier objectif écologique',
          'points': 50,
        },
        {
          'id': 'five_goals',
          'title': 'Cinq objectifs',
          'condition': _goalController.userGoals.length >= 5,
          'description': 'Créer cinq objectifs écologiques',
          'points': 100,
        },
        {
          'id': 'complete_goal',
          'condition': _goalController.userGoals.any((goal) => goal.isCompleted),
          'title': 'Objectif accompli',
          'description': 'Compléter un objectif écologique',
          'points': 75,
        },
        {
          'id': 'join_challenge',
          'condition': challenges.isNotEmpty,
          'title': 'Esprit communautaire',
          'description': 'Rejoindre un défi communautaire',
          'points': 60,
        },
        {
          'id': 'complete_challenge',
          'condition': challenges.any((challenge) => challenge.isCompleted),
          'title': 'Défi relevé',
          'description': 'Compléter un défi communautaire',
          'points': 120,
        },
      ];
      
      // Vérifier chaque achievement
      for (final achievement in achievements) {
        final achievementId = achievement['id'] as String;
        
        // Si l'achievement est déjà débloqué, passer au suivant
        if (_userAchievements.contains(achievementId)) {
          continue;
        }
        
        // Si la condition est remplie, débloquer l'achievement
        if (achievement['condition'] as bool) {
          // Ajouter l'achievement à la liste
          await _firestore.collection('users').doc(userId).update({
            'achievements': FieldValue.arrayUnion([achievementId]),
          });
          
          // Ajouter des points
          final points = achievement['points'] as int;
          await _firestore.collection('users').doc(userId).update({
            'ecoPoints': FieldValue.increment(points),
          });
          
          // Ajouter la récompense
          await _addReward(
            userId: userId,
            title: achievement['title'] as String,
            description: achievement['description'] as String,
            points: points,
            type: 'achievement',
          );
          
          // Ajouter un badge
          await _badgeController.addBadgeToUser(
            userId: userId,
            badgeId: achievementId,
            title: achievement['title'] as String,
            description: achievement['description'] as String,
            category: 'achievement',
          );
          
          // Mettre à jour la liste locale
          _userAchievements.add(achievementId);
          _userPoints += points;
        }
      }
      
      // Vérifier si l'utilisateur a atteint un nouveau niveau
      await _checkLevelUpAchievement(userId);
      
      notifyListeners();
    } catch (e) {
      print('EcoLevelService: Erreur lors de la vérification des achievements: $e');
    }
  }
  
  /// Génère une animation de célébration pour une récompense
  Map<String, dynamic> generateCelebrationData(Map<String, dynamic> reward) {
    final type = reward['type'] as String;
    final points = reward['points'] as int;
    
    // Différents types de célébrations selon le type de récompense
    switch (type) {
      case 'level_up':
        return {
          'animation': 'level_up',
          'color': levelColor,
          'icon': levelIcon,
          'sound': 'level_up',
          'confetti': true,
          'duration': 3000,
        };
      case 'achievement':
        return {
          'animation': 'achievement',
          'color': '#FFD700', // Or
          'icon': 'trophy',
          'sound': 'achievement',
          'confetti': true,
          'duration': 2500,
        };
      case 'badge':
        return {
          'animation': 'badge',
          'color': '#1E88E5', // Bleu
          'icon': 'badge',
          'sound': 'badge',
          'confetti': false,
          'duration': 2000,
        };
      default:
        // Adapter la célébration en fonction du nombre de points
        if (points >= 100) {
          return {
            'animation': 'big_reward',
            'color': '#4CAF50', // Vert
            'icon': 'star',
            'sound': 'big_reward',
            'confetti': true,
            'duration': 2000,
          };
        } else if (points >= 50) {
          return {
            'animation': 'medium_reward',
            'color': '#4CAF50', // Vert
            'icon': 'eco',
            'sound': 'medium_reward',
            'confetti': false,
            'duration': 1500,
          };
        } else {
          return {
            'animation': 'small_reward',
            'color': '#4CAF50', // Vert
            'icon': 'thumb_up',
            'sound': 'small_reward',
            'confetti': false,
            'duration': 1000,
          };
        }
    }
  }

  /// Récupère le classement de l'utilisateur actuel
  Future<Map<String, dynamic>> getUserRanking() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return {
          'rank': 0,
          'totalUsers': 0,
          'points': _userPoints,
          'percentile': 0.0,
        };
      }

      // Récupérer tous les utilisateurs classés par points
      final usersSnapshot = await _firestore
          .collection('users')
          .orderBy('ecoPoints', descending: true)
          .get();
      
      final totalUsers = usersSnapshot.docs.length;
      
      // Trouver la position de l'utilisateur
      int userRank = 0;
      for (int i = 0; i < usersSnapshot.docs.length; i++) {
        if (usersSnapshot.docs[i].id == userId) {
          userRank = i + 1;
          break;
        }
      }
      
      // Calculer le percentile
      final percentile = totalUsers > 0 ? ((totalUsers - userRank) / totalUsers) * 100 : 0.0;
      
      return {
        'rank': userRank,
        'totalUsers': totalUsers,
        'points': _userPoints,
        'percentile': percentile,
      };
    } catch (e) {
      print('EcoLevelService: Erreur lors de la récupération du classement: $e');
      return {
        'rank': 0,
        'totalUsers': 0,
        'points': _userPoints,
        'percentile': 0.0,
      };
    }
  }

  /// Récupère le classement des meilleurs utilisateurs
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .orderBy('ecoPoints', descending: true)
          .limit(limit)
          .get();
      
      final List<Map<String, dynamic>> leaderboard = [];
      
      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        
        // Récupérer les infos de profil de l'utilisateur
        final userProfileDoc = await _firestore
            .collection('user_profiles')
            .doc(doc.id)
            .get();
        
        final String username = userProfileDoc.exists && userProfileDoc.data() != null
            ? (userProfileDoc.data()?['username'] ?? 'Utilisateur')
            : 'Utilisateur';
        
        final String avatar = userProfileDoc.exists && userProfileDoc.data() != null
            ? (userProfileDoc.data()?['avatar'] ?? '')
            : '';
        
        leaderboard.add({
          'userId': doc.id,
          'username': username,
          'avatar': avatar,
          'points': userData['ecoPoints'] ?? 0,
          'level': EcoLevelSystem.getLevelTitle(
              EcoLevelSystem.getLevelFromPoints(userData['ecoPoints'] ?? 0)),
          'achievements': List<String>.from(userData['achievements'] ?? []),
        });
      }
      
      return leaderboard;
    } catch (e) {
      print('EcoLevelService: Erreur lors de la récupération du classement: $e');
      return [];
    }
  }

  /// Récupère l'historique des points gagnés
  Future<List<Map<String, dynamic>>> getPointsHistory({int limit = 10}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return [];
      }
      
      final rewardsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('rewards')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return rewardsQuery.docs.map((doc) => {
        'id': doc.id,
        'title': doc.data()['title'] ?? '',
        'description': doc.data()['description'] ?? '',
        'points': doc.data()['points'] ?? 0,
        'timestamp': doc.data()['timestamp']?.toDate() ?? DateTime.now(),
        'type': doc.data()['type'] ?? 'action',
      }).toList();
    } catch (e) {
      print('EcoLevelService: Erreur lors de la récupération de l\'historique des points: $e');
      return [];
    }
  }
}