// Modèle pour représenter le jumeau numérique écologique de l'utilisateur
// Ce modèle permet de suivre et visualiser l'empreinte écologique en temps réel

import 'package:greens_app/models/environmental_impact_model.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/models/eco_challenge_model.dart';

class EcoDigitalTwinModel {
  // Identifiant unique du jumeau numérique
  final String id;
  
  // Identifiant de l'utilisateur associé
  final String userId;
  
  // Date de création et dernière mise à jour
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  // Données d'impact environnemental
  final EnvironmentalImpactModel environmentalImpact;
  
  // Données d'empreinte carbone
  final CarbonFootprintModel carbonFootprint;
  
  // Historique des actions écologiques
  final List<EcoAction> ecoActions;
  
  // Défis en cours et complétés
  final List<EcoChallengeModel> currentChallenges;
  final List<EcoChallengeModel> completedChallenges;
  
  // Niveau écologique actuel et progression
  final int ecoLevel;
  final double levelProgress; // Progression vers le niveau suivant (0.0 - 1.0)
  
  // Statistiques de comportement écologique
  final Map<String, dynamic> behaviouralStats;
  
  // Prédictions et tendances
  final Map<String, dynamic> predictions;
  
  // Caractéristiques visuelles pour l'avatar écologique
  final Map<String, dynamic> visualFeatures;

  EcoDigitalTwinModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.lastUpdated,
    required this.environmentalImpact,
    required this.carbonFootprint,
    required this.ecoActions,
    required this.currentChallenges,
    required this.completedChallenges,
    required this.ecoLevel,
    required this.levelProgress,
    required this.behaviouralStats,
    required this.predictions,
    required this.visualFeatures,
  });
  
  // Créer une version initiale du jumeau numérique
  factory EcoDigitalTwinModel.initial(String userId) {
    final now = DateTime.now();
    return EcoDigitalTwinModel(
      id: 'twin_$userId',
      userId: userId,
      createdAt: now,
      lastUpdated: now,
      environmentalImpact: EnvironmentalImpactModel.initial(),
      carbonFootprint: CarbonFootprintModel.initial(),
      ecoActions: [],
      currentChallenges: [],
      completedChallenges: [],
      ecoLevel: 1,
      levelProgress: 0.0,
      behaviouralStats: {
        'transportMode': {'car': 0.6, 'public': 0.3, 'bike': 0.1},
        'dietType': {'omnivore': 0.7, 'vegetarian': 0.3},
        'energySaving': 0.4,
        'wasteReduction': 0.3,
        'waterConservation': 0.5,
      },
      predictions: {
        'carbonReductionPotential': 25.0, // pourcentage de réduction potentielle
        'nextMonthProjection': 120.0, // kg CO2
        'ecoScoreImprovement': 0.15, // amélioration potentielle du score
      },
      visualFeatures: {
        'avatarColor': 'green',
        'avatarSize': 1.0,
        'avatarAccessories': ['leaf', 'water_drop'],
        'environment': 'forest',
        'weatherCondition': 'sunny',
      },
    );
  }
  
  // Conversion depuis JSON
  factory EcoDigitalTwinModel.fromJson(Map<String, dynamic> json) {
    return EcoDigitalTwinModel(
      id: json['id'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      environmentalImpact: EnvironmentalImpactModel.fromJson(json['environmentalImpact']),
      carbonFootprint: CarbonFootprintModel.fromJson(json['carbonFootprint']),
      ecoActions: (json['ecoActions'] as List).map((e) => EcoAction.fromJson(e)).toList(),
      currentChallenges: (json['currentChallenges'] as List).map((e) => EcoChallengeModel.fromJson(e)).toList(),
      completedChallenges: (json['completedChallenges'] as List).map((e) => EcoChallengeModel.fromJson(e)).toList(),
      ecoLevel: json['ecoLevel'],
      levelProgress: json['levelProgress'],
      behaviouralStats: json['behaviouralStats'],
      predictions: json['predictions'],
      visualFeatures: json['visualFeatures'],
    );
  }
  
  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'environmentalImpact': environmentalImpact.toJson(),
      'carbonFootprint': carbonFootprint.toJson(),
      'ecoActions': ecoActions.map((e) => e.toJson()).toList(),
      'currentChallenges': currentChallenges.map((e) => e.toJson()).toList(),
      'completedChallenges': completedChallenges.map((e) => e.toJson()).toList(),
      'ecoLevel': ecoLevel,
      'levelProgress': levelProgress,
      'behaviouralStats': behaviouralStats,
      'predictions': predictions,
      'visualFeatures': visualFeatures,
    };
  }
  
  // Mettre à jour le jumeau avec de nouvelles données
  EcoDigitalTwinModel copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? lastUpdated,
    EnvironmentalImpactModel? environmentalImpact,
    CarbonFootprintModel? carbonFootprint,
    List<EcoAction>? ecoActions,
    List<EcoChallengeModel>? currentChallenges,
    List<EcoChallengeModel>? completedChallenges,
    int? ecoLevel,
    double? levelProgress,
    Map<String, dynamic>? behaviouralStats,
    Map<String, dynamic>? predictions,
    Map<String, dynamic>? visualFeatures,
  }) {
    return EcoDigitalTwinModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      ecoActions: ecoActions ?? this.ecoActions,
      currentChallenges: currentChallenges ?? this.currentChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      ecoLevel: ecoLevel ?? this.ecoLevel,
      levelProgress: levelProgress ?? this.levelProgress,
      behaviouralStats: behaviouralStats ?? this.behaviouralStats,
      predictions: predictions ?? this.predictions,
      visualFeatures: visualFeatures ?? this.visualFeatures,
    );
  }
}

// Modèle pour les actions écologiques individuelles
class EcoAction {
  final String id;
  final String actionType;
  final String description;
  final double carbonImpact;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;
  
  EcoAction({
    required this.id,
    required this.actionType,
    required this.description,
    required this.carbonImpact,
    required this.timestamp,
    this.additionalData,
  });
  
  factory EcoAction.fromJson(Map<String, dynamic> json) {
    return EcoAction(
      id: json['id'],
      actionType: json['actionType'],
      description: json['description'],
      carbonImpact: json['carbonImpact'],
      timestamp: DateTime.parse(json['timestamp']),
      additionalData: json['additionalData'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType,
      'description': description,
      'carbonImpact': carbonImpact,
      'timestamp': timestamp.toIso8601String(),
      'additionalData': additionalData,
    };
  }
} 