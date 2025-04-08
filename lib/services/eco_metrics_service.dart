// lib/services/eco_metrics_service.dart
import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/utils/app_colors.dart';

/// Service qui unifie les métriques d'impact écologique
/// Fournit des facteurs de conversion et des méthodes de calcul
class EcoMetricsService {
  // Facteurs de conversion pour différentes actions écologiques
  final Map<String, double> _conversionFactors = {
    'water': 0.001, // kgCO2e par litre d'eau économisé
    'energy': 0.5, // kgCO2e par kWh économisé
    'waste': 0.5, // kgCO2e par kg de déchets évité
    'transport': 0.2, // kgCO2e par km de transport durable
    'food': 1.5, // kgCO2e par repas végétarien
  };

  /// Convertit une action écologique en équivalent CO2
  double convertToC02Equivalent(String actionType, double value) {
    if (!_conversionFactors.containsKey(actionType)) {
      return 0;
    }
    return value * _conversionFactors[actionType]!;
  }

  /// Calcule l'impact CO2 total basé sur les objectifs écologiques
  double calculateTotalC02Impact(List goals) {
    double totalImpact = 0;
    for (final goal in goals) {
      // Convertir selon le type d'objectif
      String actionType = 'waste'; // Par défaut
      switch (goal.type.toString()) {
        case 'GoalType.wasteReduction':
          actionType = 'waste';
          break;
        case 'GoalType.waterSaving':
          actionType = 'water';
          break;
        case 'GoalType.energySaving':
          actionType = 'energy';
          break;
        case 'GoalType.transportation':
          actionType = 'transport';
          break;
        case 'GoalType.sustainableShopping':
          actionType = 'food';
          break;
      }
      
      // Calculer l'impact en fonction du progrès
      double progress = goal.currentProgress / goal.target;
      totalImpact += convertToC02Equivalent(actionType, progress * 100);
    }
    return totalImpact;
  }

  /// Génère une explication de l'impact écologique pour l'utilisateur
  String generateImpactExplanation(double co2Impact) {
    if (co2Impact <= 0) {
      return "Vous n'avez pas encore d'impact écologique mesurable. Commencez par définir des objectifs !";
    }
    
    // Équivalences concrètes
    final treeMonths = (co2Impact / 10).round(); // Un arbre absorbe environ 10kg de CO2 par mois
    final carKm = (co2Impact * 7).round(); // 1kg de CO2 équivaut à environ 7km en voiture
    
    return "Votre impact équivaut à planter $treeMonths arbres pendant un mois ou à éviter $carKm km en voiture !";
  }

  /// Vérifie les badges éligibles pour un utilisateur en fonction de ses objectifs
  Future<List<EcoBadge>> checkEligibleBadges(String userId, List goals) async {
    // Liste des badges éligibles
    final List<EcoBadge> eligibleBadges = [];
    
    // Vérifier les critères pour différents badges
    if (goals.length >= 3) {
      // Badge pour avoir créé 3 objectifs
      eligibleBadges.add(
        EcoBadge(
          id: 'eco_starter',
          title: 'Éco-débutant',
          description: 'A créé 3 objectifs écologiques',
          imageUrl: 'assets/images/badges/eco_starter.png',
          category: BadgeCategory.generalEcology,
          level: BadgeLevel.bronze,
          pointsAwarded: 10,
          dateAwarded: DateTime.now(),
          badgeColor: '#4CAF50',
        )
      );
    }
    
    // Vérifier les objectifs complétés
    final completedGoals = goals.where((goal) => goal.isCompleted).toList();
    if (completedGoals.length >= 1) {
      // Badge pour avoir complété un objectif
      eligibleBadges.add(
        EcoBadge(
          id: 'first_goal_completed',
          title: 'Premier objectif atteint',
          description: 'A complété son premier objectif écologique',
          imageUrl: 'assets/images/badges/first_goal.png',
          category: BadgeCategory.generalEcology,
          level: BadgeLevel.bronze,
          pointsAwarded: 15,
          dateAwarded: DateTime.now(),
          badgeColor: '#4CAF50',
        )
      );
    }
    
    return eligibleBadges;
  }

  /// Sources des facteurs d'émission
  Map<String, String> getEmissionFactorSources() {
    return {
      'water': 'Base Carbone ADEME, 2021',
      'energy': 'Base Carbone ADEME, 2021',
      'waste': 'Base Carbone ADEME, 2021',
      'transport': 'Base Carbone ADEME, 2021',
      'food': 'Étude Food Carbon Footprint, Université d\'Oxford, 2018',
    };
  }
  
  /// Calcule l'impact CO2 d'un défi communautaire
  double calculateChallengeC02Impact(CommunityChallenge challenge) {
    // Convertir l'impact du défi en CO2 équivalent
    // Utiliser une valeur par défaut pour l'impact par participant si non disponible
    double impactPerParticipant = 5.0; // Valeur par défaut
    
    // Utiliser le type de défi pour déterminer le facteur de conversion
    String actionType = 'waste'; // Par défaut
    
    switch (challenge.type.toString()) {
      case 'GoalType.wasteReduction':
        actionType = 'waste';
        break;
      case 'GoalType.waterSaving':
        actionType = 'water';
        break;
      case 'GoalType.energySaving':
        actionType = 'energy';
        break;
      case 'GoalType.transportation':
        actionType = 'transport';
        break;
      case 'GoalType.sustainableShopping':
        actionType = 'food';
        break;
    }
    
    // Calculer l'impact total
    int participantCount = challenge.participants?.length ?? 0;
    return participantCount * impactPerParticipant * _conversionFactors[actionType]!;
  }
  
  /// Calcule l'équivalent en arbres plantés pour une quantité de CO2
  int calculateTreeEquivalent(double co2KgAmount) {
    // Un arbre absorbe environ 25 kg de CO2 par an
    const kgCO2PerTreePerYear = 25.0;
    return (co2KgAmount / kgCO2PerTreePerYear).ceil();
  }
  
  /// Retourne un texte explicatif de la méthodologie
  String getMethodologyExplanation() {
    return '''
# Méthodologie de calcul d'impact

Nos calculs d'impact environnemental sont basés sur des facteurs d'émission reconnus internationalement :

## Eau
- 0,001 kg CO2e par litre d'eau économisé
- Source : Base Carbone ADEME, 2021

## Énergie
- 0,5 kg CO2e par kWh économisé
- Source : Base Carbone ADEME, 2021

## Déchets
- 0,5 kg CO2e par kg de déchets évités
- Source : Base Carbone ADEME, 2021

## Transport
- 0,2 kg CO2e par km en transport durable
- Source : Base Carbone ADEME, 2021

## Alimentation
- 1,5 kg CO2e par repas végétarien
- Source : Étude Food Carbon Footprint, Université d'Oxford, 2018

Ces facteurs sont régulièrement mis à jour pour refléter les dernières données scientifiques disponibles.
''';
  }
}