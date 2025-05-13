// Modèle pour représenter l'impact environnemental de manière concrète et tangible
class EnvironmentalImpactModel {
  // Impact carbone en kilogrammes de CO2
  final double carbonSaved;
  
  // Équivalences concrètes
  final double treeEquivalent; // Nombre d'arbres plantés équivalent
  final double waterSaved; // Litres d'eau économisés
  final double plasticsAvoided; // Kilogrammes de plastique évités
  final double energySaved; // kWh d'énergie économisés
  
  // Impact cumulatif (individuel + communauté)
  final double communityCarbonSaved; // Impact total de la communauté (kg CO2)
  final int communityParticipants; // Nombre de participants dans la communauté
  final double userContributionPercentage; // Pourcentage de contribution de l'utilisateur
  
  // Historique pour suivre l'évolution
  final Map<String, double> monthlyImpact; // Impact par mois (clé: YYYY-MM)
  
  EnvironmentalImpactModel({
    required this.carbonSaved,
    required this.treeEquivalent,
    required this.waterSaved,
    required this.plasticsAvoided,
    required this.energySaved,
    required this.communityCarbonSaved,
    required this.communityParticipants,
    required this.userContributionPercentage,
    required this.monthlyImpact,
  });
  
  // Constructeur par défaut avec valeurs initiales
  factory EnvironmentalImpactModel.initial() {
    return EnvironmentalImpactModel(
      carbonSaved: 0.0,
      treeEquivalent: 0.0,
      waterSaved: 0.0,
      plasticsAvoided: 0.0,
      energySaved: 0.0,
      communityCarbonSaved: 0.0,
      communityParticipants: 0,
      userContributionPercentage: 0.0,
      monthlyImpact: {},
    );
  }
  
  // Constructeur depuis JSON
  factory EnvironmentalImpactModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentalImpactModel(
      carbonSaved: json['carbonSaved'] ?? 0.0,
      treeEquivalent: json['treeEquivalent'] ?? 0.0,
      waterSaved: json['waterSaved'] ?? 0.0,
      plasticsAvoided: json['plasticsAvoided'] ?? 0.0,
      energySaved: json['energySaved'] ?? 0.0,
      communityCarbonSaved: json['communityCarbonSaved'] ?? 0.0,
      communityParticipants: json['communityParticipants'] ?? 0,
      userContributionPercentage: json['userContributionPercentage'] ?? 0.0,
      monthlyImpact: Map<String, double>.from(json['monthlyImpact'] ?? {}),
    );
  }
  
  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'carbonSaved': carbonSaved,
      'treeEquivalent': treeEquivalent,
      'waterSaved': waterSaved,
      'plasticsAvoided': plasticsAvoided,
      'energySaved': energySaved,
      'communityCarbonSaved': communityCarbonSaved,
      'communityParticipants': communityParticipants,
      'userContributionPercentage': userContributionPercentage,
      'monthlyImpact': monthlyImpact,
    };
  }
  
  // Méthode pour calculer l'équivalent en arbres
  static double calculateTreeEquivalent(double carbonSaved) {
    // Un arbre absorbe environ 25kg de CO2 par an
    return carbonSaved / 25;
  }
  
  // Méthode pour calculer l'équivalent en eau
  static double calculateWaterSaved(double carbonSaved) {
    // Approximation: 1kg CO2 ≈ 500L d'eau (basé sur l'empreinte eau d'activités émettant 1kg CO2)
    return carbonSaved * 500;
  }
  
  // Méthode pour calculer l'équivalent en plastique
  static double calculatePlasticsAvoided(double carbonSaved) {
    // Approximation: 1kg CO2 ≈ 0.2kg de plastique (basé sur l'empreinte carbone de la production plastique)
    return carbonSaved * 0.2;
  }
  
  // Méthode pour calculer l'équivalent en énergie
  static double calculateEnergySaved(double carbonSaved) {
    // Approximation: 1kg CO2 ≈ 3kWh (basé sur les facteurs d'émission moyens)
    return carbonSaved * 3;
  }
  
  // Méthode pour créer un modèle d'impact à partir du carbone économisé
  factory EnvironmentalImpactModel.fromCarbonSaved({
    required double carbonSaved,
    required double communityCarbonSaved,
    required int communityParticipants,
    required Map<String, double> monthlyImpact,
  }) {
    final double userContribution = communityParticipants > 0 
        ? (carbonSaved / communityCarbonSaved) * 100
        : 0.0;
    
    return EnvironmentalImpactModel(
      carbonSaved: carbonSaved,
      treeEquivalent: calculateTreeEquivalent(carbonSaved),
      waterSaved: calculateWaterSaved(carbonSaved),
      plasticsAvoided: calculatePlasticsAvoided(carbonSaved),
      energySaved: calculateEnergySaved(carbonSaved),
      communityCarbonSaved: communityCarbonSaved,
      communityParticipants: communityParticipants,
      userContributionPercentage: userContribution,
      monthlyImpact: monthlyImpact,
    );
  }
  
  // Créer une copie avec des valeurs mises à jour
  EnvironmentalImpactModel copyWith({
    double? carbonSaved,
    double? treeEquivalent,
    double? waterSaved,
    double? plasticsAvoided,
    double? energySaved,
    double? communityCarbonSaved,
    int? communityParticipants,
    double? userContributionPercentage,
    Map<String, double>? monthlyImpact,
  }) {
    return EnvironmentalImpactModel(
      carbonSaved: carbonSaved ?? this.carbonSaved,
      treeEquivalent: treeEquivalent ?? this.treeEquivalent,
      waterSaved: waterSaved ?? this.waterSaved,
      plasticsAvoided: plasticsAvoided ?? this.plasticsAvoided,
      energySaved: energySaved ?? this.energySaved,
      communityCarbonSaved: communityCarbonSaved ?? this.communityCarbonSaved,
      communityParticipants: communityParticipants ?? this.communityParticipants,
      userContributionPercentage: userContributionPercentage ?? this.userContributionPercentage,
      monthlyImpact: monthlyImpact ?? this.monthlyImpact,
    );
  }
} 