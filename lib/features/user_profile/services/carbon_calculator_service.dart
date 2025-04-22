import '../models/user_profile_model.dart';

class CarbonCalculatorService {
  // Singleton
  static final CarbonCalculatorService _instance = CarbonCalculatorService._internal();
  factory CarbonCalculatorService() => _instance;
  CarbonCalculatorService._internal();
  
  // Calcul de l'empreinte carbone totale
  double calculateTotalCarbonFootprint(UserProfileModel profile) {
    double transportFootprint = profile.transportProfile.calculateCarbonFootprint();
    double foodFootprint = profile.foodProfile.calculateCarbonFootprint();
    double energyFootprint = profile.energyProfile.calculateCarbonFootprint();
    double consumptionFootprint = profile.consumptionProfile.calculateCarbonFootprint();
    
    return transportFootprint + foodFootprint + energyFootprint + consumptionFootprint;
  }
  
  // Calcul de l'empreinte par catégorie
  Map<String, double> calculateFootprintByCategory(UserProfileModel profile) {
    return {
      'Transport': profile.transportProfile.calculateCarbonFootprint(),
      'Alimentation': profile.foodProfile.calculateCarbonFootprint(),
      'Logement': profile.energyProfile.calculateCarbonFootprint(),
      'Consommation': profile.consumptionProfile.calculateCarbonFootprint(),
    };
  }
  
  // Déterminer le niveau écologique
  EcoLevel determineEcoLevel(double totalCarbonFootprint) {
    if (totalCarbonFootprint <= 2.0) {
      return EcoLevel.expert;
    } else if (totalCarbonFootprint <= 4.0) {
      return EcoLevel.ambassadeur;
    } else if (totalCarbonFootprint <= 6.0) {
      return EcoLevel.acteur;
    } else if (totalCarbonFootprint <= 10.0) {
      return EcoLevel.explorateur;
    } else {
      return EcoLevel.debutant;
    }
  }
  
  // Comparaison avec la moyenne nationale (France)
  Map<String, dynamic> compareWithNationalAverage(UserProfileModel profile) {
    // Moyenne nationale française en tonnes de CO2 par an
    const double nationalAverageTotal = 9.9;
    const Map<String, double> nationalAverageByCategory = {
      'Transport': 2.9,
      'Alimentation': 2.4,
      'Logement': 2.7,
      'Consommation': 1.9,
    };
    
    Map<String, double> userFootprint = calculateFootprintByCategory(profile);
    double userTotal = calculateTotalCarbonFootprint(profile);
    
    Map<String, dynamic> comparison = {
      'totalDifference': nationalAverageTotal - userTotal,
      'totalPercentage': (userTotal / nationalAverageTotal) * 100,
      'categoryDifference': <String, double>{},
      'categoryPercentage': <String, double>{},
    };
    
    userFootprint.forEach((category, value) {
      double nationalValue = nationalAverageByCategory[category] ?? 0.0;
      comparison['categoryDifference'][category] = nationalValue - value;
      comparison['categoryPercentage'][category] = (value / nationalValue) * 100;
    });
    
    return comparison;
  }
  
  // Comparaison avec l'objectif climatique (2 tonnes/an)
  Map<String, dynamic> compareWithClimateGoal(UserProfileModel profile) {
    const double climateGoal = 2.0; // tonnes de CO2 par an
    double userTotal = calculateTotalCarbonFootprint(profile);
    
    return {
      'difference': userTotal - climateGoal,
      'percentage': (userTotal / climateGoal) * 100,
      'isAchieved': userTotal <= climateGoal,
    };
  }
  
  // Générer des recommandations personnalisées
  List<Recommendation> generateRecommendations(UserProfileModel profile) {
    List<Recommendation> recommendations = [];
    Map<String, double> footprintByCategory = calculateFootprintByCategory(profile);
    
    // Identifier la catégorie avec la plus grande empreinte
    String highestCategory = 'Transport';
    double highestValue = 0;
    
    footprintByCategory.forEach((category, value) {
      if (value > highestValue) {
        highestValue = value;
        highestCategory = category;
      }
    });
    
    // Recommandations pour le transport
    if (highestCategory == 'Transport' || profile.transportProfile.flightsPerYear > 0) {
      if (profile.transportProfile.flightsPerYear > 0) {
        recommendations.add(
          Recommendation(
            title: 'Réduire les vols',
            description: 'Chaque vol en moins représente une économie importante de CO₂',
            impact: 'Jusqu\'à -1.5 tonnes CO₂/an par vol long-courrier évité',
            difficulty: 'Moyenne',
            category: 'Transport',
          ),
        );
      }
      
      if (profile.transportProfile.carKilometersPerYear > 5000) {
        recommendations.add(
          Recommendation(
            title: 'Privilégier les transports en commun',
            description: 'Utiliser le train ou le bus plutôt que la voiture quand c\'est possible',
            impact: '-0.15 tonnes CO₂/an pour 1000 km',
            difficulty: 'Facile',
            category: 'Transport',
          ),
        );
      }
    }
    
    // Recommandations pour l'alimentation
    if (highestCategory == 'Alimentation' || 
        (profile.foodProfile.dietType == DietType.omnivore && profile.foodProfile.meatMealsPerWeek > 3)) {
      recommendations.add(
        Recommendation(
          title: 'Réduire la consommation de viande rouge',
          description: 'Limitez votre consommation de viande rouge à 1-2 fois par semaine',
          impact: '-0.5 tonnes CO₂/an',
          difficulty: 'Moyenne',
          category: 'Alimentation',
        ),
      );
      
      if (!profile.foodProfile.localSeasonal) {
        recommendations.add(
          Recommendation(
            title: 'Privilégier les aliments locaux et de saison',
            description: 'Les produits locaux et de saison nécessitent moins de transport et d\'énergie',
            impact: '-0.4 tonnes CO₂/an',
            difficulty: 'Facile',
            category: 'Alimentation',
          ),
        );
      }
    }
    
    // Recommandations pour l'énergie
    if (highestCategory == 'Logement' || !profile.energyProfile.renewableEnergy) {
      recommendations.add(
        Recommendation(
          title: 'Passer à un fournisseur d\'énergie verte',
          description: 'Choisir un fournisseur d\'électricité proposant une énergie 100% renouvelable',
          impact: '-0.3 tonnes CO₂/an',
          difficulty: 'Facile',
          category: 'Logement',
        ),
      );
      
      recommendations.add(
        Recommendation(
          title: 'Réduire la température du chauffage',
          description: 'Baisser de 1°C la température de votre logement',
          impact: '-0.3 tonnes CO₂/an',
          difficulty: 'Facile',
          category: 'Logement',
        ),
      );
    }
    
    // Recommandations pour la consommation
    if (highestCategory == 'Consommation' || profile.consumptionProfile.recyclingPercentage < 50) {
      recommendations.add(
        Recommendation(
          title: 'Augmenter votre taux de recyclage',
          description: 'Trier davantage vos déchets et recycler tout ce qui peut l\'être',
          impact: '-0.2 tonnes CO₂/an',
          difficulty: 'Facile',
          category: 'Consommation',
        ),
      );
      
      if (profile.consumptionProfile.newClothesPerYear > 5) {
        recommendations.add(
          Recommendation(
            title: 'Acheter moins de vêtements neufs',
            description: 'Privilégier les vêtements de seconde main ou durables',
            impact: '-0.25 tonnes CO₂/an',
            difficulty: 'Moyenne',
            category: 'Consommation',
          ),
        );
      }
    }
    
    // Limiter à 5 recommandations maximum, triées par impact
    recommendations.sort((a, b) {
      // Extraction de la valeur numérique de l'impact
      double extractImpact(String impact) {
        RegExp regExp = RegExp(r'-(\d+(\.\d+)?)');
        var match = regExp.firstMatch(impact);
        if (match != null) {
          return double.parse(match.group(1)!);
        }
        return 0.0;
      }
      
      return extractImpact(b.impact).compareTo(extractImpact(a.impact));
    });
    
    return recommendations.take(5).toList();
  }
  
  // Simuler l'évolution de l'empreinte avec les recommandations appliquées
  UserProfileModel simulateChanges(UserProfileModel profile, List<String> appliedRecommendations) {
    // Copie du profil original
    UserProfileModel updatedProfile = profile.copyWith();
    double newTotalFootprint = profile.totalCarbonFootprint;
    Map<String, double> newFootprintByCategory = Map.from(profile.footprintByCategory);
    
    // Appliquer les changements pour chaque recommandation
    for (String recommendation in appliedRecommendations) {
      if (recommendation == 'Réduire les vols') {
        int newFlights = (profile.transportProfile.flightsPerYear - 1).clamp(0, double.infinity).toInt();
        int newLongFlights = (profile.transportProfile.longDistanceFlightsPerYear - 1).clamp(0, double.infinity).toInt();
        
        TransportProfile newTransportProfile = TransportProfile(
          primaryMode: profile.transportProfile.primaryMode,
          carKilometersPerYear: profile.transportProfile.carKilometersPerYear,
          publicTransportKilometersPerYear: profile.transportProfile.publicTransportKilometersPerYear,
          flightsPerYear: newFlights,
          longDistanceFlightsPerYear: newLongFlights,
        );
        
        updatedProfile = updatedProfile.copyWith(
          transportProfile: newTransportProfile,
        );
        
        // Mettre à jour l'empreinte de transport
        double newTransportFootprint = newTransportProfile.calculateCarbonFootprint();
        double reduction = newFootprintByCategory['Transport']! - newTransportFootprint;
        newFootprintByCategory['Transport'] = newTransportFootprint;
        newTotalFootprint -= reduction;
      }
      
      else if (recommendation == 'Privilégier les transports en commun') {
        int carReduction = 1000;
        int newCarKm = (profile.transportProfile.carKilometersPerYear - carReduction).clamp(0, double.infinity).toInt();
        int newPublicKm = profile.transportProfile.publicTransportKilometersPerYear + carReduction;
        
        TransportProfile newTransportProfile = TransportProfile(
          primaryMode: profile.transportProfile.primaryMode,
          carKilometersPerYear: newCarKm,
          publicTransportKilometersPerYear: newPublicKm,
          flightsPerYear: profile.transportProfile.flightsPerYear,
          longDistanceFlightsPerYear: profile.transportProfile.longDistanceFlightsPerYear,
        );
        
        updatedProfile = updatedProfile.copyWith(
          transportProfile: newTransportProfile,
        );
        
        // Mettre à jour l'empreinte de transport
        double newTransportFootprint = newTransportProfile.calculateCarbonFootprint();
        double reduction = newFootprintByCategory['Transport']! - newTransportFootprint;
        newFootprintByCategory['Transport'] = newTransportFootprint;
        newTotalFootprint -= reduction;
      }
      
      else if (recommendation == 'Réduire la consommation de viande rouge') {
        int newMeatMeals = (profile.foodProfile.meatMealsPerWeek - 2).clamp(0, double.infinity).toInt();
        
        FoodProfile newFoodProfile = FoodProfile(
          dietType: profile.foodProfile.dietType,
          meatMealsPerWeek: newMeatMeals,
          localSeasonal: profile.foodProfile.localSeasonal,
          wastePercentage: profile.foodProfile.wastePercentage,
        );
        
        updatedProfile = updatedProfile.copyWith(
          foodProfile: newFoodProfile,
        );
        
        // Mettre à jour l'empreinte alimentaire
        double newFoodFootprint = newFoodProfile.calculateCarbonFootprint();
        double reduction = newFootprintByCategory['Alimentation']! - newFoodFootprint;
        newFootprintByCategory['Alimentation'] = newFoodFootprint;
        newTotalFootprint -= reduction;
      }
      
      // Autres recommandations... (similaire pour les autres)
    }
    
    // Mettre à jour le profil avec les nouvelles valeurs calculées
    updatedProfile = updatedProfile.copyWith(
      totalCarbonFootprint: newTotalFootprint,
      footprintByCategory: newFootprintByCategory,
      ecoLevel: determineEcoLevel(newTotalFootprint),
    );
    
    return updatedProfile;
  }
}

// Classe pour les recommandations
class Recommendation {
  final String title;
  final String description;
  final String impact;
  final String difficulty; // "Facile", "Moyenne", "Difficile"
  final String category;
  
  Recommendation({
    required this.title,
    required this.description,
    required this.impact,
    required this.difficulty,
    required this.category,
  });
} 