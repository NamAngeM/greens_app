// lib/services/social_sharing_service.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/eco_level_model.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/services/eco_level_service.dart';
import 'package:greens_app/services/carbon_footprint_service.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/utils/app_theme.dart';

/// Service qui gère le partage social et les comparaisons anonymisées
class SocialSharingService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final EcoLevelService _levelService;
  final CarbonFootprintService _carbonService;
  final EcoGoalController _goalController;
  final CommunityController _communityController;
  
  // Singleton
  static final SocialSharingService _instance = SocialSharingService._internal(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    EcoLevelService.instance,
    CarbonFootprintService(),
    EcoGoalController(),
    CommunityController(),
  );
  
  factory SocialSharingService() {
    return _instance;
  }
  
  SocialSharingService._internal(
    this._firestore,
    this._auth,
    this._levelService,
    this._carbonService,
    this._goalController,
    this._communityController,
  );
  
  static SocialSharingService get instance => _instance;
  
  // Données pour les comparaisons
  Map<String, dynamic> _communityStats = {};
  bool _isLoadingStats = false;
  DateTime _lastStatsUpdate = DateTime.now().subtract(const Duration(days: 1));
  
  // Getters
  Map<String, dynamic> get communityStats => _communityStats;
  bool get isLoadingStats => _isLoadingStats;
  
  /// Initialise le service
  Future<void> initialize() async {
    await loadCommunityStats();
  }
  
  /// Partage un objectif écologique atteint
  Future<bool> shareGoalAchievement(EcoGoal goal, GlobalKey widgetKey) async {
    try {
      // Capturer l'image du widget
      final imageBytes = await _captureWidget(widgetKey);
      if (imageBytes == null) {
        return false;
      }
      
      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/goal_achievement.png');
      await file.writeAsBytes(imageBytes);
      
      // Texte à partager
      final text = 'J\'ai atteint mon objectif écologique "${goal.title}" sur Green Minds ! 🌱 #GreenMinds #Écologie';
      
      // Partager via le plugin share_plus
      await Share.shareFiles(
        [file.path],
        text: text,
        subject: 'Objectif écologique atteint !',
      );
      
      // Enregistrer l'événement de partage
      await _recordSharingEvent('goal_achievement', goal.id);
      
      return true;
    } catch (e) {
      print('SocialSharingService: Erreur lors du partage d\'un objectif: $e');
      return false;
    }
  }
  
  /// Partage un niveau écologique atteint
  Future<bool> shareLevelAchievement(EcoLevel level, GlobalKey widgetKey) async {
    try {
      // Capturer l'image du widget
      final imageBytes = await _captureWidget(widgetKey);
      if (imageBytes == null) {
        return false;
      }
      
      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/level_achievement.png');
      await file.writeAsBytes(imageBytes);
      
      // Texte à partager
      final levelTitle = EcoLevelSystem.getLevelTitle(level);
      final text = 'J\'ai atteint le niveau $levelTitle sur Green Minds ! 🌿 #GreenMinds #ÉcologieNiveau';
      
      // Partager via le plugin share_plus
      await Share.shareFiles(
        [file.path],
        text: text,
        subject: 'Niveau écologique atteint !',
      );
      
      // Enregistrer l'événement de partage
      await _recordSharingEvent('level_achievement', level.toString());
      
      return true;
    } catch (e) {
      print('SocialSharingService: Erreur lors du partage d\'un niveau: $e');
      return false;
    }
  }
  
  /// Partage un badge obtenu
  Future<bool> shareBadgeAchievement(Map<String, dynamic> badge, GlobalKey widgetKey) async {
    try {
      // Capturer l'image du widget
      final imageBytes = await _captureWidget(widgetKey);
      if (imageBytes == null) {
        return false;
      }
      
      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/badge_achievement.png');
      await file.writeAsBytes(imageBytes);
      
      // Texte à partager
      final badgeTitle = badge['title'] as String;
      final text = 'J\'ai obtenu le badge "$badgeTitle" sur Green Minds ! 🏆 #GreenMinds #ÉcologieBadge';
      
      // Partager via le plugin share_plus
      await Share.shareFiles(
        [file.path],
        text: text,
        subject: 'Badge écologique obtenu !',
      );
      
      // Enregistrer l'événement de partage
      await _recordSharingEvent('badge_achievement', badge['id'] as String);
      
      return true;
    } catch (e) {
      print('SocialSharingService: Erreur lors du partage d\'un badge: $e');
      return false;
    }
  }
  
  /// Partage un résumé de l'empreinte carbone
  Future<bool> shareCarbonFootprint(CarbonFootprintModel footprint, GlobalKey widgetKey) async {
    try {
      // Capturer l'image du widget
      final imageBytes = await _captureWidget(widgetKey);
      if (imageBytes == null) {
        return false;
      }
      
      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/carbon_footprint.png');
      await file.writeAsBytes(imageBytes);
      
      // Texte à partager
      final text = 'Voici mon empreinte carbone calculée avec Green Minds ! Je travaille à la réduire chaque jour. 🌍 #GreenMinds #EmpreinteCarbone';
      
      // Partager via le plugin share_plus
      await Share.shareFiles(
        [file.path],
        text: text,
        subject: 'Mon empreinte carbone',
      );
      
      // Enregistrer l'événement de partage
      await _recordSharingEvent('carbon_footprint', 'footprint_share');
      
      return true;
    } catch (e) {
      print('SocialSharingService: Erreur lors du partage de l\'empreinte carbone: $e');
      return false;
    }
  }
  
  /// Partage un défi communautaire
  Future<bool> shareCommunityChallenge(Map<String, dynamic> challenge, GlobalKey widgetKey) async {
    try {
      // Capturer l'image du widget
      final imageBytes = await _captureWidget(widgetKey);
      if (imageBytes == null) {
        return false;
      }
      
      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/community_challenge.png');
      await file.writeAsBytes(imageBytes);
      
      // Texte à partager
      final challengeTitle = challenge['title'] as String;
      final text = 'Je participe au défi "$challengeTitle" sur Green Minds ! Rejoignez-moi pour agir ensemble pour l\'environnement. 🌱 #GreenMinds #DéfiÉcologique';
      
      // Partager via le plugin share_plus
      await Share.shareFiles(
        [file.path],
        text: text,
        subject: 'Défi écologique communautaire',
      );
      
      // Enregistrer l'événement de partage
      await _recordSharingEvent('community_challenge', challenge['id'] as String);
      
      return true;
    } catch (e) {
      print('SocialSharingService: Erreur lors du partage d\'un défi communautaire: $e');
      return false;
    }
  }
  
  /// Enregistre un événement de partage
  Future<void> _recordSharingEvent(String type, String itemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      
      await _firestore.collection('users').doc(userId).collection('sharing_events').add({
        'type': type,
        'itemId': itemId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Mettre à jour les statistiques globales
      await _firestore.collection('stats').doc('sharing').update({
        'total_shares': FieldValue.increment(1),
        '${type}_shares': FieldValue.increment(1),
      });
    } catch (e) {
      print('SocialSharingService: Erreur lors de l\'enregistrement de l\'événement de partage: $e');
    }
  }
  
  /// Capture un widget en tant qu'image
  Future<Uint8List?> _captureWidget(GlobalKey widgetKey) async {
    try {
      final RenderRepaintBoundary boundary = widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        return null;
      }
      
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('SocialSharingService: Erreur lors de la capture du widget: $e');
      return null;
    }
  }
  
  /// Charge les statistiques communautaires anonymisées
  Future<void> loadCommunityStats() async {
    try {
      // Vérifier si les statistiques sont déjà chargées et récentes
      final cacheAge = DateTime.now().difference(_lastStatsUpdate).inHours;
      if (_communityStats.isNotEmpty && cacheAge < 24) {
        return;
      }
      
      _isLoadingStats = true;
      notifyListeners();
      
      // Récupérer les statistiques globales
      final statsDoc = await _firestore.collection('stats').doc('community').get();
      
      if (statsDoc.exists) {
        _communityStats = statsDoc.data() ?? {};
      } else {
        // Créer le document s'il n'existe pas
        await _firestore.collection('stats').doc('community').set({
          'total_users': 0,
          'total_goals': 0,
          'completed_goals': 0,
          'total_challenges': 0,
          'average_carbon_footprint': 0,
          'users_by_level': {
            'beginner': 0,
            'aware': 0,
            'engaged': 0,
            'ambassador': 0,
            'expert': 0,
          },
          'last_updated': FieldValue.serverTimestamp(),
        });
        
        _communityStats = {
          'total_users': 0,
          'total_goals': 0,
          'completed_goals': 0,
          'total_challenges': 0,
          'average_carbon_footprint': 0,
          'users_by_level': {
            'beginner': 0,
            'aware': 0,
            'engaged': 0,
            'ambassador': 0,
            'expert': 0,
          },
        };
      }
      
      _lastStatsUpdate = DateTime.now();
      _isLoadingStats = false;
      notifyListeners();
    } catch (e) {
      print('SocialSharingService: Erreur lors du chargement des statistiques communautaires: $e');
      _isLoadingStats = false;
      notifyListeners();
    }
  }
  
  /// Récupère les statistiques de comparaison pour un utilisateur
  Future<Map<String, dynamic>> getUserComparisonStats(String userId) async {
    try {
      // Charger les données nécessaires
      await loadCommunityStats();
      final userLevel = await _levelService.getUserLevel;
      final userPoints = await _levelService.userPoints;
      final footprint = await _carbonService.getUserCarbonFootprint(userId);
      await _goalController.getUserGoals(userId);
      final goals = _goalController.userGoals;
      final completedGoals = goals.where((goal) => goal.isCompleted).length;
      final challenges = await _communityController.getUserChallenges(userId);
      
      // Calculer les comparaisons
      final levelComparison = _calculateLevelComparison(userLevel);
      final carbonComparison = _calculateCarbonComparison(footprint);
      final goalsComparison = _calculateGoalsComparison(completedGoals);
      
      return {
        'user_level': userLevel,
        'user_points': userPoints,
        'user_completed_goals': completedGoals,
        'user_active_challenges': challenges.length,
        'level_comparison': levelComparison,
        'carbon_comparison': carbonComparison,
        'goals_comparison': goalsComparison,
        'community_stats': _communityStats,
      };
    } catch (e) {
      print('SocialSharingService: Erreur lors de la récupération des statistiques de comparaison: $e');
      return {
        'error': e.toString(),
      };
    }
  }
  
  /// Calcule la comparaison de niveau avec la communauté
  Map<String, dynamic> _calculateLevelComparison(EcoLevel userLevel) {
    try {
      final usersByLevel = _communityStats['users_by_level'] as Map<String, dynamic>? ?? {};
      final totalUsers = _communityStats['total_users'] as int? ?? 0;
      
      if (totalUsers == 0) {
        return {
          'percentile': 0,
          'better_than_percent': 0,
          'same_level_percent': 0,
        };
      }
      
      // Calculer le nombre d'utilisateurs à chaque niveau
      int usersBelowLevel = 0;
      int usersSameLevel = 0;
      
      for (final entry in usersByLevel.entries) {
        final level = EcoLevel.values.firstWhere(
          (e) => e.toString().split('.').last == entry.key,
          orElse: () => EcoLevel.beginner,
        );
        
        final count = entry.value as int? ?? 0;
        
        if (level.index < userLevel.index) {
          usersBelowLevel += count;
        } else if (level.index == userLevel.index) {
          usersSameLevel = count;
        }
      }
      
      // Calculer les pourcentages
      final betterThanPercent = (usersBelowLevel / totalUsers) * 100;
      final sameLevelPercent = (usersSameLevel / totalUsers) * 100;
      final percentile = betterThanPercent + (sameLevelPercent / 2);
      
      return {
        'percentile': percentile,
        'better_than_percent': betterThanPercent,
        'same_level_percent': sameLevelPercent,
      };
    } catch (e) {
      print('SocialSharingService: Erreur lors du calcul de la comparaison de niveau: $e');
      return {
        'percentile': 0,
        'better_than_percent': 0,
        'same_level_percent': 0,
      };
    }
  }
  
  /// Calcule la comparaison d'empreinte carbone avec la communauté
  Map<String, dynamic> _calculateCarbonComparison(CarbonFootprintModel? footprint) {
    try {
      if (footprint == null) {
        return {
          'better_than_percent': 0,
          'difference_from_average': 0,
        };
      }
      
      final averageFootprint = _communityStats['average_carbon_footprint'] as double? ?? 0;
      
      if (averageFootprint == 0) {
        return {
          'better_than_percent': 0,
          'difference_from_average': 0,
        };
      }
      
      // Calculer la différence avec la moyenne
      final difference = averageFootprint - footprint.totalScore;
      final percentDifference = (difference / averageFootprint) * 100;
      
      // Estimer le pourcentage d'utilisateurs avec une empreinte plus élevée
      // (Cette estimation est simplifiée, dans un système réel, on utiliserait des données plus précises)
      double betterThanPercent = 0;
      if (difference > 0) {
        // L'utilisateur est meilleur que la moyenne
        betterThanPercent = 50 + (percentDifference / 2);
        betterThanPercent = betterThanPercent.clamp(50, 99);
      } else {
        // L'utilisateur est moins bon que la moyenne
        betterThanPercent = 50 - (percentDifference.abs() / 2);
        betterThanPercent = betterThanPercent.clamp(1, 50);
      }
      
      return {
        'better_than_percent': betterThanPercent,
        'difference_from_average': difference,
        'percent_difference': percentDifference,
      };
    } catch (e) {
      print('SocialSharingService: Erreur lors du calcul de la comparaison d\'empreinte carbone: $e');
      return {
        'better_than_percent': 0,
        'difference_from_average': 0,
      };
    }
  }
  
  /// Calcule la comparaison d'objectifs complétés avec la communauté
  Map<String, dynamic> _calculateGoalsComparison(int completedGoals) {
    try {
      final totalUsers = _communityStats['total_users'] as int? ?? 0;
      final totalCompletedGoals = _communityStats['completed_goals'] as int? ?? 0;
      
      if (totalUsers == 0) {
        return {
          'better_than_percent': 0,
          'average_completed_goals': 0,
        };
      }
      
      // Calculer la moyenne d'objectifs complétés par utilisateur
      final averageCompletedGoals = totalCompletedGoals / totalUsers;
      
      // Estimer le pourcentage d'utilisateurs avec moins d'objectifs complétés
      // (Cette estimation est simplifiée, dans un système réel, on utiliserait des données plus précises)
      double betterThanPercent = 0;
      if (completedGoals > averageCompletedGoals) {
        // L'utilisateur est meilleur que la moyenne
        final percentAbove = ((completedGoals - averageCompletedGoals) / averageCompletedGoals) * 100;
        betterThanPercent = 50 + (percentAbove / 2);
        betterThanPercent = betterThanPercent.clamp(50, 99);
      } else {
        // L'utilisateur est moins bon que la moyenne
        final percentBelow = ((averageCompletedGoals - completedGoals) / averageCompletedGoals) * 100;
        betterThanPercent = 50 - (percentBelow / 2);
        betterThanPercent = betterThanPercent.clamp(1, 50);
      }
      
      return {
        'better_than_percent': betterThanPercent,
        'average_completed_goals': averageCompletedGoals,
        'difference_from_average': completedGoals - averageCompletedGoals,
      };
    } catch (e) {
      print('SocialSharingService: Erreur lors du calcul de la comparaison d\'objectifs: $e');
      return {
        'better_than_percent': 0,
        'average_completed_goals': 0,
      };
    }
  }
  
  /// Met à jour les statistiques communautaires
  Future<void> updateCommunityStats() async {
    try {
      // Cette méthode serait normalement exécutée par un Cloud Function
      // Pour l'exemple, nous l'incluons ici mais elle ne devrait pas être appelée par les clients
      
      // Récupérer les statistiques globales
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      
      int totalGoals = 0;
      int completedGoals = 0;
      int totalChallenges = 0;
      double totalCarbonFootprint = 0;
      int usersWithFootprint = 0;
      
      final usersByLevel = {
        'beginner': 0,
        'aware': 0,
        'engaged': 0,
        'ambassador': 0,
        'expert': 0,
      };
      
      // Parcourir tous les utilisateurs
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        
        // Niveau
        final ecoLevel = userData['ecoLevel'] ?? 'beginner';
        usersByLevel[ecoLevel] = (usersByLevel[ecoLevel] ?? 0) + 1;
        
        // Objectifs
        final goalsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .get();
        
        totalGoals += goalsSnapshot.docs.length;
        completedGoals += goalsSnapshot.docs
            .where((doc) => doc.data()['isCompleted'] == true)
            .length;
        
        // Défis
        final challengesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('challenges')
            .get();
        
        totalChallenges += challengesSnapshot.docs.length;
        
        // Empreinte carbone
        final footprintSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('carbon_footprint')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        
        if (footprintSnapshot.docs.isNotEmpty) {
          final footprintData = footprintSnapshot.docs.first.data();
          final totalScore = footprintData['totalScore'] as double? ?? 0;
          
          if (totalScore > 0) {
            totalCarbonFootprint += totalScore;
            usersWithFootprint++;
          }
        }
      }
      
      // Calculer la moyenne d'empreinte carbone
      final averageCarbonFootprint = usersWithFootprint > 0
          ? totalCarbonFootprint / usersWithFootprint
          : 0;
      
      // Mettre à jour les statistiques
      await _firestore.collection('stats').doc('community').set({
        'total_users': totalUsers,
        'total_goals': totalGoals,
        'completed_goals': completedGoals,
        'total_challenges': totalChallenges,
        'average_carbon_footprint': averageCarbonFootprint,
        'users_by_level': usersByLevel,
        'last_updated': FieldValue.serverTimestamp(),
      });
      
      // Mettre à jour le cache local
      _communityStats = {
        'total_users': totalUsers,
        'total_goals': totalGoals,
        'completed_goals': completedGoals,
        'total_challenges': totalChallenges,
        'average_carbon_footprint': averageCarbonFootprint,
        'users_by_level': usersByLevel,
      };
      
      _lastStatsUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('SocialSharingService: Erreur lors de la mise à jour des statistiques communautaires: $e');
    }
  }
}
