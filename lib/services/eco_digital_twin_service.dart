import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_digital_twin_model.dart';
import 'package:greens_app/models/environmental_impact_model.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:uuid/uuid.dart';

/// Service pour gérer le jumeau numérique écologique de l'utilisateur
class EcoDigitalTwinService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  EcoDigitalTwinModel? _digitalTwin;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  EcoDigitalTwinModel? get digitalTwin => _digitalTwin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Initialise ou charge le jumeau numérique de l'utilisateur
  Future<void> loadOrCreateDigitalTwin(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Vérifier si un jumeau numérique existe déjà
      final docSnapshot = await _firestore
          .collection('eco_digital_twins')
          .doc(userId)
          .get();
      
      if (docSnapshot.exists) {
        // Charger le jumeau existant
        _digitalTwin = EcoDigitalTwinModel.fromJson(
          Map<String, dynamic>.from(docSnapshot.data() as Map)
        );
      } else {
        // Créer un nouveau jumeau numérique
        _digitalTwin = EcoDigitalTwinModel.initial(userId);
        
        // Sauvegarder dans Firestore
        await _firestore
            .collection('eco_digital_twins')
            .doc(userId)
            .set(_digitalTwin!.toJson());
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement du jumeau numérique: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Enregistre une nouvelle action écologique
  Future<void> addEcoAction(String userId, {
    required String actionType,
    required String description,
    required double carbonImpact,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      // Créer la nouvelle action
      final newAction = EcoAction(
        id: _uuid.v4(),
        actionType: actionType,
        description: description,
        carbonImpact: carbonImpact,
        timestamp: DateTime.now(),
        additionalData: additionalData,
      );
      
      // Mettre à jour l'environnemental impact
      final updatedImpact = _digitalTwin!.environmentalImpact.copyWith(
        carbonSaved: _digitalTwin!.environmentalImpact.carbonSaved + carbonImpact,
      );
      
      // Mettre à jour le modèle local
      final actions = List<EcoAction>.from(_digitalTwin!.ecoActions);
      actions.add(newAction);
      
      _digitalTwin = _digitalTwin!.copyWith(
        ecoActions: actions,
        environmentalImpact: updatedImpact,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout d\'une action: $e';
      notifyListeners();
    }
  }
  
  /// Met à jour le jumeau numérique avec de nouvelles données d'empreinte carbone
  Future<void> updateCarbonFootprint(String userId, CarbonFootprintModel newFootprint) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      // Mettre à jour le modèle local
      _digitalTwin = _digitalTwin!.copyWith(
        carbonFootprint: newFootprint,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de l\'empreinte carbone: $e';
      notifyListeners();
    }
  }
  
  /// Met à jour l'impact environnemental
  Future<void> updateEnvironmentalImpact(String userId, EnvironmentalImpactModel newImpact) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      // Mettre à jour le modèle local
      _digitalTwin = _digitalTwin!.copyWith(
        environmentalImpact: newImpact,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de l\'impact environnemental: $e';
      notifyListeners();
    }
  }
  
  /// Ajoute un nouveau défi écologique
  Future<void> addChallenge(String userId, EcoChallengeModel challenge) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      final challenges = List<EcoChallengeModel>.from(_digitalTwin!.currentChallenges);
      challenges.add(challenge);
      
      // Mettre à jour le modèle local
      _digitalTwin = _digitalTwin!.copyWith(
        currentChallenges: challenges,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout d\'un défi: $e';
      notifyListeners();
    }
  }
  
  /// Marque un défi comme complété
  Future<void> completeChallenge(String userId, String challengeId) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      // Trouver le défi
      final challenge = _digitalTwin!.currentChallenges.firstWhere(
        (c) => c.id == challengeId,
        orElse: () => throw Exception('Défi non trouvé'),
      );
      
      // Supprimer des défis en cours
      final currentChallenges = _digitalTwin!.currentChallenges
          .where((c) => c.id != challengeId)
          .toList();
      
      // Ajouter aux défis complétés
      final completedChallenges = List<EcoChallengeModel>.from(_digitalTwin!.completedChallenges);
      completedChallenges.add(challenge);
      
      // Mettre à jour le niveau écologique
      int newLevel = _digitalTwin!.ecoLevel;
      double newProgress = _digitalTwin!.levelProgress + 0.1; // +10% par défi
      
      if (newProgress >= 1.0) {
        newLevel++;
        newProgress = newProgress - 1.0;
      }
      
      // Mettre à jour le modèle local
      _digitalTwin = _digitalTwin!.copyWith(
        currentChallenges: currentChallenges,
        completedChallenges: completedChallenges,
        ecoLevel: newLevel,
        levelProgress: newProgress,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la complétion d\'un défi: $e';
      notifyListeners();
    }
  }
  
  /// Met à jour les caractéristiques visuelles du jumeau numérique
  Future<void> updateVisualFeatures(String userId, Map<String, dynamic> features) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      // Fusionner avec les caractéristiques existantes
      final visualFeatures = Map<String, dynamic>.from(_digitalTwin!.visualFeatures);
      visualFeatures.addAll(features);
      
      // Mettre à jour le modèle local
      _digitalTwin = _digitalTwin!.copyWith(
        visualFeatures: visualFeatures,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour des caractéristiques visuelles: $e';
      notifyListeners();
    }
  }
  
  /// Met à jour les prédictions du jumeau numérique
  Future<void> updatePredictions(String userId) async {
    try {
      if (_digitalTwin == null) {
        await loadOrCreateDigitalTwin(userId);
      }
      
      // Analyse des actions récentes pour générer des prédictions
      // Dans une application réelle, cela pourrait utiliser un algorithme d'IA
      // Pour l'exemple, nous utilisons des calculs simples
      
      // Obtenir les actions des 30 derniers jours
      final recentActions = _digitalTwin!.ecoActions.where((action) {
        final daysAgo = DateTime.now().difference(action.timestamp).inDays;
        return daysAgo <= 30;
      }).toList();
      
      // Calculer le total d'impact carbone récent
      final recentCarbonImpact = recentActions.fold<double>(
        0, (sum, action) => sum + action.carbonImpact);
      
      // Projeter pour le mois suivant (avec une légère amélioration)
      final projectedImpact = recentCarbonImpact * 1.1;
      
      // Calculer le potentiel de réduction en pourcentage
      final currentFootprint = _digitalTwin!.carbonFootprint.totalFootprint;
      final potentialReduction = (currentFootprint > 0) 
          ? (recentCarbonImpact / currentFootprint) * 100
          : 5.0; // valeur par défaut
      
      // Prédire l'amélioration du score écologique
      final currentLevel = _digitalTwin!.ecoLevel + _digitalTwin!.levelProgress;
      final projectedImprovement = recentActions.length > 5 ? 0.2 : 0.1;
      
      // Créer les nouvelles prédictions
      final predictions = {
        'carbonReductionPotential': potentialReduction,
        'nextMonthProjection': projectedImpact,
        'ecoScoreImprovement': projectedImprovement,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Mettre à jour le modèle local
      _digitalTwin = _digitalTwin!.copyWith(
        predictions: predictions,
        lastUpdated: DateTime.now(),
      );
      
      // Mettre à jour dans Firestore
      await _updateTwinInFirestore(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour des prédictions: $e';
      notifyListeners();
    }
  }
  
  /// Met à jour le jumeau numérique dans Firestore
  Future<void> _updateTwinInFirestore(String userId) async {
    if (_digitalTwin == null) return;
    
    await _firestore
        .collection('eco_digital_twins')
        .doc(userId)
        .set(_digitalTwin!.toJson());
  }
  
  /// Génère un message personnalisé basé sur le jumeau numérique
  String generateStatusMessage() {
    if (_digitalTwin == null) {
      return "Commencez à utiliser l'application pour créer votre jumeau numérique écologique !";
    }
    
    final recentActions = _digitalTwin!.ecoActions
        .where((a) => DateTime.now().difference(a.timestamp).inDays < 7)
        .length;
    
    if (recentActions == 0) {
      return "Votre jumeau écologique a besoin de vous ! Réalisez des actions écologiques pour le faire évoluer.";
    }
    
    final messages = [
      "Votre jumeau écologique est au niveau ${_digitalTwin!.ecoLevel} et vous avez économisé ${_digitalTwin!.environmentalImpact.carbonSaved.toStringAsFixed(1)} kg de CO₂.",
      "Votre impact positif sur l'environnement équivaut à ${_digitalTwin!.environmentalImpact.treeEquivalent.toStringAsFixed(1)} arbres plantés.",
      "Continuez vos efforts ! Il vous manque ${((1 - _digitalTwin!.levelProgress) * 100).toStringAsFixed(0)}% pour atteindre le niveau suivant.",
      "Vous avez réalisé $recentActions actions écologiques cette semaine. Continuez sur cette lancée !",
    ];
    
    // Sélectionner un message aléatoire
    final index = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[index];
  }
  
  /// Obtient un conseil personnalisé basé sur le jumeau numérique
  String getPersonalizedTip() {
    if (_digitalTwin == null) {
      return "Connectez-vous pour obtenir des conseils personnalisés !";
    }
    
    final behaviorStats = _digitalTwin!.behaviouralStats;
    final tips = <String>[];
    
    // Conseils basés sur les habitudes de transport
    final transportMode = behaviorStats['transportMode'] as Map<String, dynamic>?;
    if (transportMode != null && transportMode['car'] != null && transportMode['car'] > 0.5) {
      tips.add("Essayez de réduire vos déplacements en voiture. Même un jour par semaine en transport en commun peut faire une grande différence !");
    }
    
    // Conseils basés sur les habitudes alimentaires
    final dietType = behaviorStats['dietType'] as Map<String, dynamic>?;
    if (dietType != null && dietType['omnivore'] != null && dietType['omnivore'] > 0.6) {
      tips.add("Essayez d'introduire plus de repas végétariens dans votre alimentation. Même un jour sans viande par semaine a un impact important !");
    }
    
    // Conseils basés sur les économies d'énergie
    final energySaving = behaviorStats['energySaving'] as double?;
    if (energySaving != null && energySaving < 0.5) {
      tips.add("Pensez à éteindre les appareils en veille et à utiliser des ampoules LED pour réduire votre consommation d'énergie.");
    }
    
    // Conseils basés sur la réduction des déchets
    final wasteReduction = behaviorStats['wasteReduction'] as double?;
    if (wasteReduction != null && wasteReduction < 0.5) {
      tips.add("Essayez de réduire vos déchets en achetant des produits avec moins d'emballages et en recyclant davantage.");
    }
    
    // Si aucun conseil spécifique, donner un conseil général
    if (tips.isEmpty) {
      return "Continuez vos efforts écologiques ! Chaque petite action compte pour la planète.";
    }
    
    // Sélectionner un conseil aléatoire parmi ceux qui s'appliquent
    final index = DateTime.now().millisecondsSinceEpoch % tips.length;
    return tips[index];
  }
} 