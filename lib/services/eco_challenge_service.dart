import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:greens_app/models/challenge_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class EcoChallengeService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();
  
  // Défis disponibles
  List<EcoChallenge> _availableChallenges = [];
  
  // Défis actuels de l'utilisateur
  List<EcoChallenge> _userChallenges = [];
  
  // Défis complétés par l'utilisateur
  List<EcoChallenge> _completedChallenges = [];
  
  // Getters
  List<EcoChallenge> get availableChallenges => _availableChallenges;
  List<EcoChallenge> get userChallenges => _userChallenges;
  List<EcoChallenge> get completedChallenges => _completedChallenges;
  
  // Défi quotidien actuel
  EcoChallenge? _dailyChallenge;
  EcoChallenge? get dailyChallenge => _dailyChallenge;
  
  // Défis hebdomadaires actuels
  List<EcoChallenge> _weeklyChallenges = [];
  List<EcoChallenge> get weeklyChallenges => _weeklyChallenges;
  
  // Initialiser le service
  Future<void> initialize(String userId) async {
    await _loadAvailableChallenges();
    await _loadUserChallenges(userId);
    await _checkAndAssignDailyChallenge(userId);
    await _checkAndAssignWeeklyChallenges(userId);
  }
  
  // Charger tous les défis disponibles depuis Firestore
  Future<void> _loadAvailableChallenges() async {
    try {
      final challengesSnapshot = await _firestore.collection('eco_challenges').get();
      _availableChallenges = challengesSnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des défis: $e');
      // Utiliser des défis par défaut en cas d'erreur
      _loadDefaultChallenges();
    }
  }
  
  // Charger les défis par défaut si Firestore n'est pas disponible
  void _loadDefaultChallenges() {
    _availableChallenges = [
      EcoChallenge(
        id: 'challenge_1',
        title: 'Journée sans plastique',
        description: 'Évitez tout emballage plastique à usage unique pendant une journée entière.',
        pointsValue: 50,
        duration: const Duration(hours: 24),
        category: ChallengeCategory.waste,
        frequency: ChallengeFrequency.daily,
        level: ChallengeLevel.beginner,
        estimatedImpact: 0.5,
        tips: [
          'Préparez vos repas à l\'avance dans des contenants réutilisables',
          'Utilisez un sac en tissu pour vos courses',
          'Apportez votre propre bouteille d\'eau réutilisable'
        ],
        imageUrl: 'assets/images/challenges/no_plastic.jpg',
      ),
      EcoChallenge(
        id: 'challenge_2',
        title: 'Transport écologique',
        description: 'Utilisez uniquement des moyens de transport écologiques pendant une semaine (marche, vélo, transports en commun).',
        pointsValue: 150,
        duration: const Duration(days: 7),
        category: ChallengeCategory.transport,
        frequency: ChallengeFrequency.weekly,
        level: ChallengeLevel.intermediate,
        estimatedImpact: 15.0,
        tips: [
          'Planifiez vos trajets à l\'avance',
          'Utilisez des applications de transport en commun',
          'Envisagez le covoiturage pour les longues distances'
        ],
        imageUrl: 'assets/images/challenges/eco_transport.jpg',
      ),
      EcoChallenge(
        id: 'challenge_3',
        title: 'Douche courte',
        description: 'Limitez vos douches à 5 minutes maximum pendant une semaine.',
        pointsValue: 100,
        duration: const Duration(days: 7),
        category: ChallengeCategory.water,
        frequency: ChallengeFrequency.weekly,
        level: ChallengeLevel.beginner,
        estimatedImpact: 3.5,
        tips: [
          'Utilisez un minuteur dans la salle de bain',
          'Coupez l\'eau pendant que vous vous savonnez',
          'Utilisez un pommeau de douche économe en eau'
        ],
        imageUrl: 'assets/images/challenges/short_shower.jpg',
      ),
      EcoChallenge(
        id: 'challenge_4',
        title: 'Journée végétarienne',
        description: 'Ne consommez aucun produit d\'origine animale pendant une journée entière.',
        pointsValue: 75,
        duration: const Duration(hours: 24),
        category: ChallengeCategory.food,
        frequency: ChallengeFrequency.daily,
        level: ChallengeLevel.beginner,
        estimatedImpact: 4.0,
        tips: [
          'Essayez des alternatives végétales aux produits laitiers',
          'Découvrez de nouvelles recettes à base de légumineuses',
          'Préparez vos repas à l\'avance'
        ],
        imageUrl: 'assets/images/challenges/vegetarian_day.jpg',
      ),
      EcoChallenge(
        id: 'challenge_5',
        title: 'Déconnexion numérique',
        description: 'Limitez votre utilisation des appareils numériques à 2 heures par jour pendant une semaine.',
        pointsValue: 120,
        duration: const Duration(days: 7),
        category: ChallengeCategory.digital,
        frequency: ChallengeFrequency.weekly,
        level: ChallengeLevel.intermediate,
        estimatedImpact: 1.2,
        tips: [
          'Désactivez les notifications non essentielles',
          'Utilisez une application de suivi du temps d\'écran',
          'Remplacez le temps d\'écran par des activités en plein air'
        ],
        imageUrl: 'assets/images/challenges/digital_detox.jpg',
      ),
    ];
    notifyListeners();
  }
  
  // Charger les défis de l'utilisateur depuis Firestore
  Future<void> _loadUserChallenges(String userId) async {
    try {
      final userChallengesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .get();
      
      _userChallenges = userChallengesSnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .where((challenge) => !challenge.isCompleted)
          .toList();
      
      _completedChallenges = userChallengesSnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .where((challenge) => challenge.isCompleted)
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des défis utilisateur: $e');
    }
  }
  
  // Vérifier et assigner le défi quotidien
  Future<void> _checkAndAssignDailyChallenge(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDailyUpdate = prefs.getInt('last_daily_challenge_update') ?? 0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastDailyUpdate);
      
      // Si le dernier défi quotidien a été assigné aujourd'hui, le récupérer
      if (lastUpdateDate.year == today.year && 
          lastUpdateDate.month == today.month && 
          lastUpdateDate.day == today.day) {
        
        // Chercher le défi quotidien actuel parmi les défis de l'utilisateur
        _dailyChallenge = _userChallenges.firstWhere(
          (challenge) => challenge.frequency == ChallengeFrequency.daily && 
                         challenge.startDate?.day == today.day,
          orElse: () => _assignNewDailyChallenge(userId, today),
        );
      } else {
        // Assigner un nouveau défi quotidien
        _dailyChallenge = _assignNewDailyChallenge(userId, today);
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la vérification du défi quotidien: $e');
    }
  }
  
  // Assigner un nouveau défi quotidien
  EcoChallenge _assignNewDailyChallenge(String userId, DateTime today) {
    // Filtrer les défis quotidiens disponibles
    final availableDailyChallenges = _availableChallenges
        .where((challenge) => challenge.frequency == ChallengeFrequency.daily)
        .toList();
    
    // Sélectionner un défi aléatoire
    final challenge = availableDailyChallenges[_random.nextInt(availableDailyChallenges.length)];
    
    // Créer une copie du défi avec une date de début
    final newChallenge = challenge.copyWith(
      startDate: today,
      progressPercentage: 0.0,
      isCompleted: false,
    );
    
    // Ajouter le défi à la liste des défis de l'utilisateur
    _userChallenges.add(newChallenge);
    
    // Sauvegarder le défi dans Firestore
    _saveUserChallenge(userId, newChallenge);
    
    // Mettre à jour la date du dernier défi quotidien
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('last_daily_challenge_update', today.millisecondsSinceEpoch);
    });
    
    return newChallenge;
  }
  
  // Vérifier et assigner les défis hebdomadaires
  Future<void> _checkAndAssignWeeklyChallenges(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastWeeklyUpdate = prefs.getInt('last_weekly_challenge_update') ?? 0;
      final now = DateTime.now();
      
      // Déterminer le début de la semaine actuelle (lundi)
      final currentWeekStart = DateTime(
        now.year, 
        now.month, 
        now.day - now.weekday + 1
      );
      
      final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastWeeklyUpdate);
      
      // Si les défis hebdomadaires ont déjà été assignés cette semaine, les récupérer
      if (lastUpdateDate.isAfter(currentWeekStart) || lastUpdateDate.isAtSameMomentAs(currentWeekStart)) {
        _weeklyChallenges = _userChallenges
            .where((challenge) => challenge.frequency == ChallengeFrequency.weekly &&
                               challenge.startDate?.isAfter(currentWeekStart) == true)
            .toList();
        
        // Si aucun défi hebdomadaire n'est trouvé, en assigner de nouveaux
        if (_weeklyChallenges.isEmpty) {
          _assignNewWeeklyChallenges(userId, currentWeekStart);
        }
      } else {
        // Assigner de nouveaux défis hebdomadaires
        _assignNewWeeklyChallenges(userId, currentWeekStart);
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la vérification des défis hebdomadaires: $e');
    }
  }
  
  // Assigner de nouveaux défis hebdomadaires
  void _assignNewWeeklyChallenges(String userId, DateTime weekStart) {
    // Filtrer les défis hebdomadaires disponibles
    final availableWeeklyChallenges = _availableChallenges
        .where((challenge) => challenge.frequency == ChallengeFrequency.weekly)
        .toList();
    
    // Sélectionner 3 défis aléatoires
    _weeklyChallenges = [];
    final numChallenges = min(3, availableWeeklyChallenges.length);
    
    // Mélanger la liste pour une sélection aléatoire
    availableWeeklyChallenges.shuffle();
    
    for (int i = 0; i < numChallenges; i++) {
      final challenge = availableWeeklyChallenges[i];
      
      // Créer une copie du défi avec une date de début
      final newChallenge = challenge.copyWith(
        startDate: weekStart,
        progressPercentage: 0.0,
        isCompleted: false,
      );
      
      // Ajouter le défi à la liste des défis de l'utilisateur
      _userChallenges.add(newChallenge);
      _weeklyChallenges.add(newChallenge);
      
      // Sauvegarder le défi dans Firestore
      _saveUserChallenge(userId, newChallenge);
    }
    
    // Mettre à jour la date du dernier défi hebdomadaire
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('last_weekly_challenge_update', weekStart.millisecondsSinceEpoch);
    });
  }
  
  // Sauvegarder un défi utilisateur dans Firestore
  Future<void> _saveUserChallenge(String userId, EcoChallenge challenge) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challenge.id)
          .set(challenge.toMap());
    } catch (e) {
      print('Erreur lors de la sauvegarde du défi utilisateur: $e');
    }
  }
  
  // Mettre à jour la progression d'un défi
  Future<void> updateChallengeProgress(String userId, String challengeId, double progress) async {
    try {
      // Trouver le défi dans les défis de l'utilisateur
      final challengeIndex = _userChallenges.indexWhere((c) => c.id == challengeId);
      
      if (challengeIndex >= 0) {
        // Mettre à jour la progression
        _userChallenges[challengeIndex].updateProgress(progress);
        
        // Si le défi est complété, le déplacer vers les défis complétés
        if (_userChallenges[challengeIndex].isCompleted) {
          final completedChallenge = _userChallenges[challengeIndex];
          _completedChallenges.add(completedChallenge);
          _userChallenges.removeAt(challengeIndex);
          
          // Mettre à jour le défi quotidien ou hebdomadaire si nécessaire
          if (_dailyChallenge?.id == challengeId) {
            _dailyChallenge = null;
          } else {
            _weeklyChallenges.removeWhere((c) => c.id == challengeId);
          }
        }
        
        // Sauvegarder les modifications dans Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('challenges')
            .doc(challengeId)
            .update({
              'progressPercentage': progress,
              'isCompleted': progress >= 100,
              'completionDate': progress >= 100 ? FieldValue.serverTimestamp() : null,
            });
        
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la progression du défi: $e');
    }
  }
  
  // Marquer un défi comme complété
  Future<void> completeChallenge(String userId, String challengeId) async {
    await updateChallengeProgress(userId, challengeId, 100.0);
  }
  
  // Obtenir les statistiques de défis de l'utilisateur
  Map<String, dynamic> getUserChallengeStats() {
    final totalCompleted = _completedChallenges.length;
    final totalInProgress = _userChallenges.length;
    
    // Calculer les points totaux
    final totalPoints = _completedChallenges.fold<int>(
      0, (sum, challenge) => sum + challenge.pointsValue
    );
    
    // Calculer l'impact environnemental total
    final totalImpact = _completedChallenges.fold<double>(
      0, (sum, challenge) => sum + challenge.estimatedImpact
    );
    
    // Calculer les statistiques par catégorie
    final Map<ChallengeCategory, int> challengesByCategory = {};
    
    for (final challenge in _completedChallenges) {
      challengesByCategory[challenge.category] = 
          (challengesByCategory[challenge.category] ?? 0) + 1;
    }
    
    return {
      'totalCompleted': totalCompleted,
      'totalInProgress': totalInProgress,
      'totalPoints': totalPoints,
      'totalImpact': totalImpact,
      'challengesByCategory': challengesByCategory,
    };
  }
  
  /// Permet à l'utilisateur de rejoindre un défi spécifique
  Future<void> joinChallenge(String userId, String challengeId) async {
    try {
      // Vérifier si le défi existe dans les défis disponibles
      final challengeToJoin = _availableChallenges.firstWhere(
        (challenge) => challenge.id == challengeId,
        orElse: () => throw Exception('Défi non trouvé dans les défis disponibles'),
      );
      
      // Vérifier si l'utilisateur participe déjà à ce défi
      final alreadyJoined = _userChallenges.any((challenge) => challenge.id == challengeId);
      
      if (alreadyJoined) {
        throw Exception('Vous participez déjà à ce défi');
      }
      
      // Créer une copie du défi avec les informations de l'utilisateur
      final now = DateTime.now();
      final userChallenge = challengeToJoin.copyWith(
        startDate: now,
        progressPercentage: 0.0,
        isCompleted: false,
      );
      
      // Ajouter le défi à la liste des défis de l'utilisateur
      _userChallenges.add(userChallenge);
      
      // Sauvegarder le défi dans Firestore
      await _saveUserChallenge(userId, userChallenge);
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la participation au défi: $e');
      rethrow;
    }
  }
  
  /// Obtient un défi recommandé pour l'utilisateur en fonction de son historique et de ses préférences
  Future<EcoChallengeModel?> getRecommendedChallenge(String userId) async {
    try {
      // Si aucun défi disponible, retourner null
      if (_availableChallenges.isEmpty) {
        return null;
      }
      
      // Vérifier les défis complétés pour déterminer les préférences de l'utilisateur
      final userStats = getUserChallengeStats();
      final challengesByCategory = userStats['challengesByCategory'] as Map<ChallengeCategory, int>? ?? {};
      
      // Déterminer la catégorie préférée
      ChallengeCategory? preferredCategory;
      int maxCount = 0;
      
      challengesByCategory.forEach((category, count) {
        if (count > maxCount) {
          maxCount = count;
          preferredCategory = category;
        }
      });
      
      // Filtrer les défis que l'utilisateur n'a pas encore rejoint
      final userChallengeIds = _userChallenges.map((c) => c.id).toList();
      final completedChallengeIds = _completedChallenges.map((c) => c.id).toList();
      
      final availableNewChallenges = _availableChallenges.where((challenge) => 
        !userChallengeIds.contains(challenge.id) && 
        !completedChallengeIds.contains(challenge.id)
      ).toList();
      
      // Si aucun nouveau défi disponible, retourner null
      if (availableNewChallenges.isEmpty) {
        return null;
      }
      
      // Si l'utilisateur a une catégorie préférée, privilégier ces défis
      if (preferredCategory != null) {
        final preferredChallenges = availableNewChallenges.where(
          (challenge) => challenge.category == preferredCategory
        ).toList();
        
        if (preferredChallenges.isNotEmpty) {
          // Convertir EcoChallenge vers EcoChallengeModel
          final challenge = preferredChallenges[_random.nextInt(preferredChallenges.length)];
          return _convertToEcoChallengeModel(challenge);
        }
      }
      
      // Sinon, recommander un défi aléatoire
      final randomChallenge = availableNewChallenges[_random.nextInt(availableNewChallenges.length)];
      return _convertToEcoChallengeModel(randomChallenge);
    } catch (e) {
      print('Erreur lors de la récupération du défi recommandé: $e');
      return null;
    }
  }
  
  /// Convertit un EcoChallenge en EcoChallengeModel
  EcoChallengeModel _convertToEcoChallengeModel(EcoChallenge challenge) {
    return EcoChallengeModel(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      category: challenge.category.toString().split('.').last,
      duration: challenge.duration.inDays,
      carbonImpact: challenge.estimatedImpact,
      startDate: challenge.startDate ?? DateTime.now(),
      endDate: challenge.startDate?.add(challenge.duration),
      isCompleted: challenge.isCompleted,
      rewards: {
        'points': challenge.pointsValue,
        'badge': 'eco_challenge_${challenge.category.toString().split('.').last.toLowerCase()}',
      },
      imageUrl: challenge.imageUrl,
    );
  }
} 