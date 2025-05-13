import 'dart:math' as math;

/// Service avancé pour calculer l'empreinte carbone des produits
class CarbonFootprintCalculator {
  // Singleton
  static final CarbonFootprintCalculator _instance = CarbonFootprintCalculator._internal();
  factory CarbonFootprintCalculator() => _instance;
  CarbonFootprintCalculator._internal();
  
  // Facteurs d'émission par catégorie (kg CO2 eq/kg de produit)
  final Map<String, double> _categoryEmissionFactors = {
    'Fruits': 0.5,
    'Légumes': 0.7,
    'Viandes': 25.0,
    'Poissons': 5.0,
    'Produits laitiers': 3.0,
    'Céréales': 1.0,
    'Boissons': 0.8,
    'Produits transformés': 2.5,
    'Snacks': 2.0,
    'Produits animaux': 2.0,
    'Électronique': 30.0,
    'Vêtements': 15.0,
    'Beauté & Cosmétiques': 10.0,
    'Produits Ménagers': 8.0,
    'Livres & Médias': 2.0,
  };
  
  // Facteurs d'ajustement selon l'origine du produit
  final Map<String, double> _originMultipliers = {
    'Local': 0.8,       // Produit local
    'National': 1.0,    // Produit national
    'Europe': 1.2,      // Produit européen
    'Mondial': 1.5,     // Produit international
    'Inconnu': 1.2,     // Par défaut
  };
  
  // Facteurs d'ajustement selon le type d'emballage
  final Map<String, double> _packagingMultipliers = {
    'Sans emballage': 0.8,
    'Emballage minimal': 0.9,
    'Emballage standard': 1.0,
    'Emballage excessif': 1.2,
    'Emballage recyclable': 0.9,
    'Emballage non recyclable': 1.1,
  };
  
  // Facteurs d'ajustement selon le niveau de transformation
  final Map<String, double> _processingMultipliers = {
    'Non transformé': 0.8,
    'Peu transformé': 0.9,
    'Moyennement transformé': 1.0,
    'Très transformé': 1.2,
    'Ultra transformé': 1.5,
  };
  
  /// Calcule l'empreinte carbone d'un produit en fonction de sa catégorie
  /// et d'autres facteurs (origine, emballage, transformation)
  double calculateCarbonFootprint({
    required String category,
    required double weight,
    String origin = 'Inconnu',
    String packagingType = 'Emballage standard',
    String processingLevel = 'Moyennement transformé',
  }) {
    // Obtenir le facteur d'émission de base pour la catégorie
    double baseFactor = _categoryEmissionFactors[category] ?? 2.0;
    
    // Appliquer les multiplicateurs
    double originMultiplier = _originMultipliers[origin] ?? 1.2;
    double packagingMultiplier = _packagingMultipliers[packagingType] ?? 1.0;
    double processingMultiplier = _processingMultipliers[processingLevel] ?? 1.0;
    
    // Calculer l'empreinte totale en kg CO2 eq
    double totalFootprint = baseFactor * weight * originMultiplier * 
                           packagingMultiplier * processingMultiplier;
    
    // Arrondir à 2 décimales
    return double.parse(totalFootprint.toStringAsFixed(2));
  }
  
  /// Calcule l'empreinte carbone détaillée avec une répartition par composante
  Map<String, double> calculateDetailedCarbonFootprint({
    required String category,
    required double weight,
    String origin = 'Inconnu',
    String packagingType = 'Emballage standard',
    String processingLevel = 'Moyennement transformé',
  }) {
    // Facteur d'émission de base pour la catégorie
    double baseFactor = _categoryEmissionFactors[category] ?? 2.0;
    
    // Calculer chaque composante
    double productionFootprint = baseFactor * weight * 0.7; // 70% de l'impact
    
    // Transport (dépend de l'origine)
    double originMultiplier = _originMultipliers[origin] ?? 1.2;
    double transportFootprint = baseFactor * weight * 0.15 * originMultiplier;
    
    // Emballage
    double packagingMultiplier = _packagingMultipliers[packagingType] ?? 1.0;
    double packagingFootprint = baseFactor * weight * 0.1 * packagingMultiplier;
    
    // Transformation
    double processingMultiplier = _processingMultipliers[processingLevel] ?? 1.0;
    double processingFootprint = baseFactor * weight * 0.05 * processingMultiplier;
    
    // Arrondir chaque valeur à 2 décimales
    return {
      'production': double.parse(productionFootprint.toStringAsFixed(2)),
      'transport': double.parse(transportFootprint.toStringAsFixed(2)),
      'packaging': double.parse(packagingFootprint.toStringAsFixed(2)),
      'processing': double.parse(processingFootprint.toStringAsFixed(2)),
      'total': double.parse((productionFootprint + transportFootprint + 
                            packagingFootprint + processingFootprint).toStringAsFixed(2)),
    };
  }
  
  /// Convertit l'empreinte carbone en équivalents concrets
  Map<String, double> carbonToEquivalents(double carbonFootprint) {
    return {
      'km_voiture': double.parse((carbonFootprint * 4.2).toStringAsFixed(1)),  // km en voiture moyenne
      'charges_smartphone': double.parse((carbonFootprint * 250).toStringAsFixed(0)),  // charges de smartphone
      'arbres_necessaires': double.parse((carbonFootprint / 25).toStringAsFixed(2)),  // arbres pour compenser pendant 1 an
      'jours_chauffage': double.parse((carbonFootprint / 15).toStringAsFixed(1)),  // jours de chauffage d'un appartement
      'litres_essence': double.parse((carbonFootprint / 2.3).toStringAsFixed(1)),  // litres d'essence
    };
  }
  
  /// Calcule un score éco de 0 à 10 basé sur l'empreinte carbone 
  /// et la catégorie du produit
  double calculateEcoScore(double carbonFootprint, String category) {
    // Obtenir l'empreinte moyenne pour cette catégorie
    double averageFootprint = _categoryEmissionFactors[category] ?? 2.0;
    
    // Si l'empreinte est inférieure à la moyenne, c'est bon
    if (carbonFootprint < averageFootprint * 0.7) {
      // Excellent: entre 8 et 10
      return 10 - 2 * (carbonFootprint / (averageFootprint * 0.7));
    } else if (carbonFootprint < averageFootprint) {
      // Bon: entre 6 et 8
      return 8 - 2 * ((carbonFootprint - averageFootprint * 0.7) / (averageFootprint * 0.3));
    } else if (carbonFootprint < averageFootprint * 1.5) {
      // Moyen: entre 4 et 6
      return 6 - 2 * ((carbonFootprint - averageFootprint) / (averageFootprint * 0.5));
    } else if (carbonFootprint < averageFootprint * 2.5) {
      // Mauvais: entre 2 et 4
      return 4 - 2 * ((carbonFootprint - averageFootprint * 1.5) / (averageFootprint));
    } else {
      // Très mauvais: entre 0 et 2
      return math.max(0, 2 - (carbonFootprint - averageFootprint * 2.5) / averageFootprint);
    }
  }
  
  /// Obtenir des conseils personnalisés pour réduire l'empreinte carbone
  List<String> getCarbonReductionTips(String category, double carbonFootprint, String origin, String packagingType) {
    List<String> tips = [];
    
    // Conseils généraux
    tips.add("Privilégiez les produits locaux et de saison pour réduire l'impact du transport.");
    
    // Conseils spécifiques à la catégorie
    if (category == 'Viandes') {
      tips.add("La viande a une forte empreinte carbone. Essayez de réduire votre consommation ou optez pour des alternatives végétales.");
      tips.add("Privilégiez les viandes blanches (poulet, dinde) qui ont une empreinte carbone plus faible que les viandes rouges.");
    } else if (category == 'Produits laitiers') {
      tips.add("Essayez les alternatives végétales au lait qui ont généralement une empreinte carbone plus faible.");
    } else if (category == 'Fruits' || category == 'Légumes') {
      tips.add("Achetez des fruits et légumes de saison et produits localement pour minimiser l'impact environnemental.");
    }
    
    // Conseils spécifiques à l'origine
    if (origin == 'Mondial' || origin == 'Inconnu') {
      tips.add("Ce produit a parcouru une longue distance. Recherchez des alternatives produites plus près de chez vous.");
    }
    
    // Conseils spécifiques à l'emballage
    if (packagingType == 'Emballage excessif' || packagingType == 'Emballage non recyclable') {
      tips.add("Recherchez des produits avec moins d'emballage ou des emballages recyclables pour réduire votre impact.");
    }
    
    return tips;
  }
} 