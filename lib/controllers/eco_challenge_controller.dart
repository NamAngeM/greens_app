import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

/// Contrôleur pour gérer les défis écologiques
class EcoChallengeController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();
  final Uuid _uuid = const Uuid();
  
  List<EcoChallenge> _dailyChallenges = [];
  List<EcoChallenge> _weeklyChallenges = [];
  List<EcoChallenge> _monthlyChallenges = [];
  List<EcoChallenge> _availableChallenges = [];
  List<EcoChallenge> _completedChallenges = [];
  List<EcoChallenge> _activeChallenges = [];
  
  // Getters
  List<EcoChallenge> get dailyChallenges => _dailyChallenges;
  List<EcoChallenge> get weeklyChallenges => _weeklyChallenges;
  List<EcoChallenge> get monthlyChallenges => _monthlyChallenges;
  List<EcoChallenge> get availableChallenges => _availableChallenges;
  List<EcoChallenge> get completedChallenges => _completedChallenges;
  List<EcoChallenge> get activeChallenges => _activeChallenges;
  
  /// Initialise le contrôleur et charge les données
  Future<void> initialize() async {
    await _loadChallenges();
    await loadUserChallenges();
    await generateDailyChallenges();
    await generateWeeklyChallenges();
    notifyListeners();
  }
  
  /// Charge tous les défis disponibles depuis Firestore
  Future<void> _loadChallenges() async {
    try {
      final snapshot = await _firestore.collection('challenges').get();
      _availableChallenges = snapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des défis: $e');
      // En cas d'erreur, utiliser des défis par défaut
      _availableChallenges = _getDefaultChallenges();
    }
  }
  
  /// Charge les défis de l'utilisateur (actifs et complétés)
  Future<void> loadUserChallenges() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      // Charger les défis actifs
      final activeSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activeChallenges')
          .get();
      
      _activeChallenges = activeSnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
          
      // Charger les défis complétés
      final completedSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completedChallenges')
          .get();
          
      _completedChallenges = completedSnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des défis utilisateur: $e');
    }
  }
  
  /// Génère des défis quotidiens personnalisés pour l'utilisateur
  Future<void> generateDailyChallenges() async {
    if (_availableChallenges.isEmpty) {
      await _loadChallenges();
    }
    
    // Filtrer pour les défis quotidiens non complétés
    final eligibleChallenges = _availableChallenges
        .where((challenge) => 
            challenge.frequency == ChallengeFrequency.daily &&
            !_isCompletedRecently(challenge.id))
        .toList();
    
    if (eligibleChallenges.isEmpty) {
      _dailyChallenges = [];
      return;
    }
    
    // Mélanger la liste pour plus de variété
    eligibleChallenges.shuffle(_random);
    
    // Sélectionner 3 défis maximum
    final count = min(3, eligibleChallenges.length);
    _dailyChallenges = eligibleChallenges.sublist(0, count);
    
    notifyListeners();
  }
  
  /// Génère des défis hebdomadaires personnalisés pour l'utilisateur
  Future<void> generateWeeklyChallenges() async {
    if (_availableChallenges.isEmpty) {
      await _loadChallenges();
    }
    
    // Filtrer pour les défis hebdomadaires non complétés
    final eligibleChallenges = _availableChallenges
        .where((challenge) => 
            challenge.frequency == ChallengeFrequency.weekly &&
            !_isCompletedRecently(challenge.id))
        .toList();
    
    if (eligibleChallenges.isEmpty) {
      _weeklyChallenges = [];
      return;
    }
    
    // Mélanger la liste pour plus de variété
    eligibleChallenges.shuffle(_random);
    
    // Sélectionner 2 défis maximum
    final count = min(2, eligibleChallenges.length);
    _weeklyChallenges = eligibleChallenges.sublist(0, count);
    
    notifyListeners();
  }
  
  /// Vérifie si un défi a été complété récemment
  bool _isCompletedRecently(String challengeId) {
    final challenge = _completedChallenges
        .where((c) => c.id == challengeId)
        .toList();
    
    if (challenge.isEmpty) return false;
    
    final lastCompletion = challenge.first.completionDate;
    if (lastCompletion == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(lastCompletion);
    
    // Pour les défis quotidiens, vérifier s'il a été complété dans les dernières 24h
    return difference.inHours < 24;
  }
  
  /// Accepte un défi proposé
  Future<bool> acceptChallenge(String challengeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    
    // Trouver le défi dans les listes disponibles
    EcoChallenge? challenge = _findChallengeById(challengeId);
    if (challenge == null) return false;
    
    // Démarrer le défi
    challenge.start();
    
    try {
      // Ajouter aux défis actifs
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activeChallenges')
          .doc(challengeId)
          .set(challenge.toMap());
      
      // Ajouter à la liste locale
      _activeChallenges.add(challenge);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'acceptation du défi: $e');
      return false;
    }
  }
  
  /// Marque un défi comme complété
  Future<bool> completeChallenge(String challengeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    
    // Trouver le défi actif
    final index = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return false;
    
    // Mettre à jour le défi
    final challenge = _activeChallenges[index];
    challenge.complete();
    
    try {
      // Supprimer des défis actifs
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activeChallenges')
          .doc(challengeId)
          .delete();
      
      // Ajouter aux défis complétés
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completedChallenges')
          .doc(challengeId)
          .set(challenge.toMap());
      
      // Mettre à jour les listes locales
      _activeChallenges.removeAt(index);
      _completedChallenges.add(challenge);
      
      // Mettre à jour les points de l'utilisateur
      await _updateUserPoints(challenge.pointsValue);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la complétion du défi: $e');
      return false;
    }
  }
  
  /// Met à jour la progression d'un défi
  Future<bool> updateChallengeProgress(String challengeId, double progress) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    
    // Trouver le défi actif
    final index = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return false;
    
    // Mettre à jour le défi
    final challenge = _activeChallenges[index];
    challenge.updateProgress(progress);
    
    try {
      // Mettre à jour dans Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activeChallenges')
          .doc(challengeId)
          .update({'progressPercentage': progress});
      
      // Si le défi est complété, le déplacer
      if (challenge.isCompleted) {
        await completeChallenge(challengeId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la progression: $e');
      return false;
    }
  }
  
  /// Met à jour les points de l'utilisateur
  Future<void> _updateUserPoints(int points) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      // Obtenir les points actuels
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentPoints = userDoc.data()?['ecoPoints'] ?? 0;
      
      // Mettre à jour les points
      await _firestore.collection('users').doc(userId).update({
        'ecoPoints': currentPoints + points,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour des points: $e');
    }
  }
  
  /// Crée un défi personnalisé
  Future<bool> createCustomChallenge(EcoChallenge challenge) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    
    // Générer un ID unique
    final newChallenge = challenge.copyWith(id: _uuid.v4());
    
    try {
      // Ajouter aux défis disponibles
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('customChallenges')
          .doc(newChallenge.id)
          .set(newChallenge.toMap());
      
      // Ajouter à la liste locale
      _availableChallenges.add(newChallenge);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la création du défi personnalisé: $e');
      return false;
    }
  }
  
  /// Trouve un défi par son ID dans toutes les listes
  EcoChallenge? _findChallengeById(String challengeId) {
    // Chercher dans toutes les listes
    for (final challenge in [..._dailyChallenges, ..._weeklyChallenges, ..._monthlyChallenges, ..._availableChallenges]) {
      if (challenge.id == challengeId) {
        return challenge;
      }
    }
    return null;
  }
  
  /// Obtient des défis par catégorie
  List<EcoChallenge> getChallengesByCategory(ChallengeCategory category) {
    return _availableChallenges
        .where((challenge) => challenge.category == category)
        .toList();
  }
  
  /// Obtient des défis par niveau de difficulté
  List<EcoChallenge> getChallengesByLevel(ChallengeLevel level) {
    return _availableChallenges
        .where((challenge) => challenge.level == level)
        .toList();
  }
  
  /// Fournit des défis par défaut si aucun n'est disponible dans Firestore
  List<EcoChallenge> _getDefaultChallenges() {
    return [
      EcoChallenge(
        id: 'daily-1',
        title: 'Jour sans viande',
        description: 'Ne consommez pas de viande pendant une journée entière.',
        pointsValue: 50,
        duration: const Duration(hours: 24),
        category: ChallengeCategory.food,
        frequency: ChallengeFrequency.daily,
        level: ChallengeLevel.beginner,
        estimatedImpact: 3.0,
        tips: [
          'Essayez des alternatives végétales comme le tofu ou les légumineuses',
          'Découvrez des recettes végétariennes internationales',
        ],
      ),
      EcoChallenge(
        id: 'daily-2',
        title: 'Transport écologique',
        description: 'Utilisez un moyen de transport écologique pour vos déplacements du jour.',
        pointsValue: 40,
        duration: const Duration(hours: 24),
        category: ChallengeCategory.transport,
        frequency: ChallengeFrequency.daily,
        level: ChallengeLevel.beginner,
        estimatedImpact: 5.0,
        tips: [
          'Privilégiez la marche pour les courts trajets',
          'Essayez le vélo ou les transports en commun',
        ],
      ),
      EcoChallenge(
        id: 'weekly-1',
        title: 'Semaine zéro déchet',
        description: 'Réduisez drastiquement vos déchets pendant une semaine.',
        pointsValue: 150,
        duration: const Duration(days: 7),
        category: ChallengeCategory.waste,
        frequency: ChallengeFrequency.weekly,
        level: ChallengeLevel.intermediate,
        estimatedImpact: 10.0,
        tips: [
          'Achetez des produits sans emballage',
          'Utilisez des contenants réutilisables',
          'Compostez vos déchets organiques',
        ],
      ),
      EcoChallenge(
        id: 'daily-3',
        title: 'Économie d\'eau',
        description: 'Réduisez votre consommation d\'eau aujourd\'hui.',
        pointsValue: 30,
        duration: const Duration(hours: 24),
        category: ChallengeCategory.water,
        frequency: ChallengeFrequency.daily,
        level: ChallengeLevel.beginner,
        estimatedImpact: 1.5,
        tips: [
          'Prenez des douches plus courtes',
          'Fermez le robinet pendant le brossage des dents',
        ],
      ),
      EcoChallenge(
        id: 'weekly-2',
        title: 'Détox numérique',
        description: 'Réduisez votre empreinte numérique pendant une semaine.',
        pointsValue: 120,
        duration: const Duration(days: 7),
        category: ChallengeCategory.digital,
        frequency: ChallengeFrequency.weekly,
        level: ChallengeLevel.intermediate,
        estimatedImpact: 4.0,
        tips: [
          'Limitez le streaming vidéo en HD',
          'Réduisez le temps d\'écran quotidien',
          'Nettoyez votre boîte mail',
        ],
      ),
    ];
  }
} 