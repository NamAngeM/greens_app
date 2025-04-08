import 'dart:math';
import 'package:flutter/foundation.dart';

/// Service spécialisé dans l'analyse avancée de l'empreinte carbone
class CarbonAnalysisService {
  // Coefficients d'impact pour différentes catégories (kg CO2e)
  // Source: Valeurs adaptées des rapports de l'ADEME (Agence de la transition écologique)
  static const Map<String, double> _transportCoefficients = {
    'voiture_essence': 0.233,  // kg CO2e par km
    'voiture_diesel': 0.179,   // kg CO2e par km
    'voiture_electrique': 0.037, // kg CO2e par km
    'bus': 0.068,              // kg CO2e par km par passager
    'train': 0.011,            // kg CO2e par km par passager
    'avion_court': 0.258,      // kg CO2e par km par passager
    'avion_long': 0.151,       // kg CO2e par km par passager
    'velo': 0.0,               // kg CO2e par km
    'marche': 0.0,             // kg CO2e par km
  };
  
  static const Map<String, double> _alimentationCoefficients = {
    'boeuf': 27.0,           // kg CO2e par kg
    'poulet': 5.4,           // kg CO2e par kg
    'porc': 6.0,             // kg CO2e par kg
    'poisson': 5.0,          // kg CO2e par kg
    'produits_laitiers': 3.2, // kg CO2e par kg
    'fruits_legumes_locaux': 0.5, // kg CO2e par kg
    'fruits_legumes_importes': 1.5, // kg CO2e par kg
    'cereales': 0.8,         // kg CO2e par kg
  };
  
  static const Map<String, double> _energieCoefficients = {
    'electricite': 0.057,    // kg CO2e par kWh (mix FR)
    'gaz': 0.238,            // kg CO2e par kWh
    'fioul': 0.324,          // kg CO2e par kWh
    'bois': 0.03,            // kg CO2e par kWh
  };
  
  static const Map<String, double> _consommationCoefficients = {
    'vetements': 10.0,       // kg CO2e par article moyen
    'electronique': 100.0,   // kg CO2e par appareil moyen
    'meubles': 100.0,        // kg CO2e par meuble moyen
    'papier': 0.9,           // kg CO2e par kg
    'plastique': 3.5,        // kg CO2e par kg
  };
  
  /// Calculer l'empreinte carbone détaillée basée sur les données utilisateur
  Map<String, dynamic> calculateDetailedCarbonFootprint(Map<String, dynamic> userData) {
    try {
      // Initialiser les résultats
      final result = <String, dynamic>{
        'totalScore': 0.0,
        'detailedBreakdown': <String, dynamic>{},
        'carbonTonnesPerYear': 0.0,
        'recommendations': <String>[],
        'comparisons': <String, dynamic>{},
      };
      
      // Calculer l'empreinte transport
      double transportScore = _calculateTransportFootprint(userData['transport'] ?? {});
      
      // Calculer l'empreinte alimentation
      double alimentationScore = _calculateFoodFootprint(userData['alimentation'] ?? {});
      
      // Calculer l'empreinte énergie
      double energieScore = _calculateEnergyFootprint(userData['energie'] ?? {});
      
      // Calculer l'empreinte consommation
      double consommationScore = _calculateConsumptionFootprint(userData['consommation'] ?? {});
      
      // Score total
      double totalScore = transportScore + alimentationScore + energieScore + consommationScore;
      
      // Conversion en tonnes CO2 par an (estimation)
      double tonnesCO2 = totalScore * 0.001 * 365; // Conversion kg/jour en tonnes/an
      
      // Stocker les résultats
      result['totalScore'] = totalScore;
      result['carbonTonnesPerYear'] = tonnesCO2;
      result['detailedBreakdown'] = {
        'transport': transportScore,
        'alimentation': alimentationScore,
        'energie': energieScore,
        'consommation': consommationScore,
      };
      
      // Générer des comparaisons pour aider à contextualiser
      result['comparisons'] = _generateComparisons(tonnesCO2);
      
      // Générer des recommandations personnalisées
      result['recommendations'] = _generatePersonalizedRecommendations(
        result['detailedBreakdown'], 
        userData,
      );
      
      return result;
    } catch (e) {
      debugPrint('Erreur lors du calcul détaillé de l\'empreinte carbone: $e');
      // Retourner une estimation par défaut en cas d'erreur
      return {
        'totalScore': 12.0, // kg CO2 par jour (moyenne française ~12kg/jour)
        'carbonTonnesPerYear': 4.4, // tonnes CO2 par an (moyenne française ~4.4t/an)
        'detailedBreakdown': {
          'transport': 4.0,
          'alimentation': 3.0,
          'energie': 3.0,
          'consommation': 2.0,
        },
        'recommendations': [
          'Privilégiez les transports en commun et le vélo quand c\'est possible',
          'Réduisez votre consommation de viande rouge',
          'Éteignez les appareils en veille',
        ],
        'comparisons': {
          'vs_moyenne_nationale': 1.0, // Même que la moyenne
          'vs_objectif_2030': 1.76, // 4.4t vs objectif 2.5t
          'equivalent_arbres': 220, // 20 arbres pour compenser 1 tonne de CO2 par an
        },
      };
    }
  }
  
  double _calculateTransportFootprint(Map<String, dynamic> transportData) {
    double score = 0.0;
    
    // Trajet domicile-travail
    String modeTransport = transportData['mode_principal'] ?? 'voiture_essence';
    double distanceQuotidienne = transportData['distance_quotidienne'] ?? 30.0; // km
    score += (_transportCoefficients[modeTransport] ?? 0.2) * distanceQuotidienne;
    
    // Voyages longue distance
    int voyagesAvion = transportData['vols_annuels'] ?? 0;
    double distanceMoyenneVol = transportData['distance_moyenne_vol'] ?? 1000.0; // km
    // Convertir en impact quotidien
    score += voyagesAvion * distanceMoyenneVol * (_transportCoefficients['avion_long'] ?? 0.15) / 365;
    
    return score;
  }
  
  double _calculateFoodFootprint(Map<String, dynamic> alimentationData) {
    double score = 0.0;
    
    // Consommation de viande
    int joursViandeRouge = alimentationData['jours_viande_rouge_semaine'] ?? 3;
    int joursVolaille = alimentationData['jours_volaille_semaine'] ?? 2;
    
    // Quantité moyenne par repas
    double quantiteViandeRouge = alimentationData['quantite_viande_rouge'] ?? 0.15; // kg
    double quantiteVolaille = alimentationData['quantite_volaille'] ?? 0.15; // kg
    
    // Impact quotidien
    score += joursViandeRouge * quantiteViandeRouge * (_alimentationCoefficients['boeuf'] ?? 27.0) / 7;
    score += joursVolaille * quantiteVolaille * (_alimentationCoefficients['poulet'] ?? 5.4) / 7;
    
    // Produits laitiers
    double produitLaitiersQuotidien = alimentationData['produits_laitiers_quotidien'] ?? 0.2; // kg
    score += produitLaitiersQuotidien * (_alimentationCoefficients['produits_laitiers'] ?? 3.2);
    
    // Fruits et légumes
    bool localSaisonnier = alimentationData['fruits_legumes_locaux'] ?? false;
    double fruitsLegumesQuotidien = alimentationData['fruits_legumes_quotidien'] ?? 0.4; // kg
    
    if (localSaisonnier) {
      score += fruitsLegumesQuotidien * (_alimentationCoefficients['fruits_legumes_locaux'] ?? 0.5);
    } else {
      score += fruitsLegumesQuotidien * (_alimentationCoefficients['fruits_legumes_importes'] ?? 1.5);
    }
    
    return score;
  }
  
  double _calculateEnergyFootprint(Map<String, dynamic> energieData) {
    double score = 0.0;
    
    // Type de chauffage
    String typeChauffage = energieData['type_chauffage'] ?? 'gaz';
    double consommationChauffage = energieData['consommation_chauffage_kwh'] ?? 40.0; // kWh/jour
    score += consommationChauffage * (_energieCoefficients[typeChauffage] ?? 0.2);
    
    // Électricité (hors chauffage)
    double consommationElectricite = energieData['consommation_electricite_kwh'] ?? 10.0; // kWh/jour
    score += consommationElectricite * (_energieCoefficients['electricite'] ?? 0.057);
    
    return score;
  }
  
  double _calculateConsumptionFootprint(Map<String, dynamic> consommationData) {
    double score = 0.0;
    
    // Achats de vêtements
    int vetementsParAn = consommationData['vetements_par_an'] ?? 12;
    score += vetementsParAn * (_consommationCoefficients['vetements'] ?? 10.0) / 365;
    
    // Achats d'appareils électroniques
    int electroniquesParAn = consommationData['electroniques_par_an'] ?? 2;
    score += electroniquesParAn * (_consommationCoefficients['electronique'] ?? 100.0) / 365;
    
    // Impact des déchets quotidiens
    double dechetsKg = consommationData['dechets_quotidiens_kg'] ?? 1.0;
    double tauxRecyclage = consommationData['taux_recyclage'] ?? 0.3; // 30% par défaut
    
    // Impact réduit grâce au recyclage
    score += dechetsKg * (1 - tauxRecyclage) * 1.0; // 1kg CO2e par kg de déchet non recyclé
    
    return score;
  }
  
  Map<String, dynamic> _generateComparisons(double tonnesCO2) {
    // Moyenne française: environ 4.4 tonnes CO2e par personne par an
    double moyenneNationale = 4.4;
    // Objectif 2030 pour limiter le réchauffement à 2°C: 2.5 tonnes CO2e par personne par an
    double objectif2030 = 2.5;
    // Objectif 2050 pour limiter le réchauffement à 1.5°C: 1 tonne CO2e par personne par an
    double objectif2050 = 1.0;
    
    // Un arbre absorbe environ 20kg de CO2 par an
    int arbresEquivalents = (tonnesCO2 * 1000 / 20).round();
    
    // Surface de forêt nécessaire (un hectare absorbe environ 5 tonnes CO2 par an)
    double surfaceForetHa = tonnesCO2 / 5;
    
    return {
      'vs_moyenne_nationale': tonnesCO2 / moyenneNationale,
      'vs_objectif_2030': tonnesCO2 / objectif2030,
      'vs_objectif_2050': tonnesCO2 / objectif2050,
      'equivalent_arbres': arbresEquivalents,
      'surface_foret_ha': surfaceForetHa,
    };
  }
  
  List<String> _generatePersonalizedRecommendations(
    Map<String, dynamic> breakdown,
    Map<String, dynamic> userData,
  ) {
    List<String> recommendations = [];
    
    // Identifier les catégories avec le plus fort impact
    List<MapEntry<String, dynamic>> sortedImpacts = breakdown.entries.toList()
      ..sort((a, b) => (b.value as double).compareTo(a.value as double));
    
    // Recommandations pour le transport
    if (sortedImpacts.first.key == 'transport' || 
        breakdown['transport'] > 4.0) {
      
      String modeTransport = userData['transport']?['mode_principal'] ?? 'voiture_essence';
      
      if (modeTransport.contains('voiture')) {
        recommendations.add(
          'Votre impact transport est significatif. Essayez le covoiturage pour vos trajets quotidiens,'
          ' ce qui pourrait réduire votre empreinte de 50%.'
        );
        recommendations.add(
          'Envisagez les transports en commun ou le vélo pour les courts trajets.'
          ' Cela pourrait économiser jusqu\'à 230g de CO2 par kilomètre.'
        );
      }
      
      int voyagesAvion = userData['transport']?['vols_annuels'] ?? 0;
      if (voyagesAvion > 2) {
        recommendations.add(
          'Les vols en avion représentent une part importante de votre empreinte carbone.'
          ' Privilégiez le train pour les moyennes distances quand c\'est possible.'
        );
      }
    }
    
    // Recommandations pour l'alimentation
    if (breakdown['alimentation'] > 3.0) {
      int joursViandeRouge = userData['alimentation']?['jours_viande_rouge_semaine'] ?? 3;
      
      if (joursViandeRouge > 2) {
        recommendations.add(
          'Réduire votre consommation de viande rouge à 1-2 fois par semaine peut diminuer'
          ' votre empreinte alimentaire de 30%.'
        );
      }
      
      bool localSaisonnier = userData['alimentation']?['fruits_legumes_locaux'] ?? false;
      if (!localSaisonnier) {
        recommendations.add(
          'Privilégiez les fruits et légumes locaux et de saison pour réduire l\'impact'
          ' du transport et de la production hors-saison.'
        );
      }
    }
    
    // Recommandations pour l'énergie
    if (breakdown['energie'] > 3.0) {
      String typeChauffage = userData['energie']?['type_chauffage'] ?? '';
      
      if (typeChauffage == 'fioul' || typeChauffage == 'gaz') {
        recommendations.add(
          'Votre système de chauffage au ${typeChauffage} a un impact environnemental élevé.'
          ' Envisagez une pompe à chaleur qui réduirait vos émissions de 70%.'
        );
      }
      
      recommendations.add(
        'Réduisez votre consommation énergétique: baissez le chauffage de 1°C,'
        ' utilisez des ampoules LED et éteignez les appareils en veille.'
      );
    }
    
    // Recommandations pour la consommation
    if (breakdown['consommation'] > 2.0) {
      int vetementsParAn = userData['consommation']?['vetements_par_an'] ?? 12;
      
      if (vetementsParAn > 10) {
        recommendations.add(
          'Réduire vos achats de vêtements neufs et privilégier la seconde main'
          ' peut diminuer significativement votre impact. L\'industrie textile'
          ' est la 2ème plus polluante au monde.'
        );
      }
      
      double tauxRecyclage = userData['consommation']?['taux_recyclage'] ?? 0.3;
      if (tauxRecyclage < 0.5) {
        recommendations.add(
          'Améliorez votre tri des déchets pour atteindre 70% de recyclage'
          ' et réduisez les emballages à usage unique.'
        );
      }
    }
    
    // Ajouter des recommandations générales si nécessaire
    if (recommendations.isEmpty) {
      recommendations.add(
        'Votre empreinte est déjà assez bonne! Pour aller plus loin, pensez à compenser'
        ' vos émissions restantes en soutenant des projets de reforestation.'
      );
    }
    
    // Limiter le nombre de recommandations pour ne pas submerger l'utilisateur
    if (recommendations.length > 5) {
      // Garder les 5 premières recommandations
      recommendations = recommendations.sublist(0, 5);
    }
    
    return recommendations;
  }
} 