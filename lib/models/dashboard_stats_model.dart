class DashboardStatsModel {
  final String userId;
  final DateTime lastUpdated;
  
  // Statistiques carbone
  final double carbonFootprint; // en kg de CO2
  final double carbonSaved; // en kg de CO2 économisés
  final int carbonTrend; // pourcentage d'amélioration (-X% ou +X%)
  
  // Statistiques produits
  final int productsScanCount; // nombre de produits scannés
  final double avgProductEcoScore; // score éco moyen (0-100)
  final int ecoFriendlyProductCount; // produits écologiques (score > 70)
  
  // Statistiques objectifs
  final int activeGoalsCount; // objectifs actifs
  final int completedGoalsCount; // objectifs complétés
  final double goalCompletionRate; // taux de complétion (0-100%)
  
  // Statistiques communauté
  final int participatedChallenges; // défis auxquels l'utilisateur a participé
  final int totalCommunityImpact; // impact estimé (en kg CO2 ou équivalent)
  
  // Statistiques de l'appareil
  final double appEnergyUsage; // consommation d'énergie de l'app (estimation)
  final int energySavingRate; // pourcentage d'économie d'énergie (0-100%)
  
  // Badges et accomplissements
  final int totalBadges;
  final int totalPoints;
  final String currentLevel;
  
  final int actionsCompleted;
  final int highCarbonProductsCount;
  final int mediumCarbonProductsCount;
  final int lowCarbonProductsCount;
  final Map<String, dynamic>? currentGoal;
  final int goalsCompleted;
  final int communityRanking;
  final double communityContribution;
  final double deviceUsageHours;
  final double deviceEnergyUsage;
  final List<Map<String, dynamic>> achievements;
  
  DashboardStatsModel({
    required this.userId,
    required this.lastUpdated,
    this.carbonFootprint = 0.0,
    this.carbonSaved = 0.0,
    this.carbonTrend = 0,
    this.productsScanCount = 0,
    this.avgProductEcoScore = 0.0,
    this.ecoFriendlyProductCount = 0,
    this.activeGoalsCount = 0,
    this.completedGoalsCount = 0,
    this.goalCompletionRate = 0.0,
    this.participatedChallenges = 0,
    this.totalCommunityImpact = 0,
    this.appEnergyUsage = 0.0,
    this.energySavingRate = 0,
    this.totalBadges = 0,
    this.totalPoints = 0,
    this.currentLevel = 'Débutant',
    required this.actionsCompleted,
    required this.highCarbonProductsCount,
    required this.mediumCarbonProductsCount,
    required this.lowCarbonProductsCount,
    this.currentGoal,
    required this.goalsCompleted,
    required this.communityRanking,
    required this.communityContribution,
    required this.deviceUsageHours,
    required this.deviceEnergyUsage,
    required this.achievements,
  });
  
  // Méthode pour créer une copie avec des champs mis à jour
  DashboardStatsModel copyWith({
    String? userId,
    DateTime? lastUpdated,
    double? carbonFootprint,
    double? carbonSaved,
    int? carbonTrend,
    int? productsScanCount,
    double? avgProductEcoScore,
    int? ecoFriendlyProductCount,
    int? activeGoalsCount,
    int? completedGoalsCount,
    double? goalCompletionRate,
    int? participatedChallenges,
    int? totalCommunityImpact,
    double? appEnergyUsage,
    int? energySavingRate,
    int? totalBadges,
    int? totalPoints,
    String? currentLevel,
    int? actionsCompleted,
    int? highCarbonProductsCount,
    int? mediumCarbonProductsCount,
    int? lowCarbonProductsCount,
    Map<String, dynamic>? currentGoal,
    int? goalsCompleted,
    int? communityRanking,
    double? communityContribution,
    double? deviceUsageHours,
    double? deviceEnergyUsage,
    List<Map<String, dynamic>>? achievements,
  }) {
    return DashboardStatsModel(
      userId: userId ?? this.userId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      carbonSaved: carbonSaved ?? this.carbonSaved,
      carbonTrend: carbonTrend ?? this.carbonTrend,
      productsScanCount: productsScanCount ?? this.productsScanCount,
      avgProductEcoScore: avgProductEcoScore ?? this.avgProductEcoScore,
      ecoFriendlyProductCount: ecoFriendlyProductCount ?? this.ecoFriendlyProductCount,
      activeGoalsCount: activeGoalsCount ?? this.activeGoalsCount,
      completedGoalsCount: completedGoalsCount ?? this.completedGoalsCount,
      goalCompletionRate: goalCompletionRate ?? this.goalCompletionRate,
      participatedChallenges: participatedChallenges ?? this.participatedChallenges,
      totalCommunityImpact: totalCommunityImpact ?? this.totalCommunityImpact,
      appEnergyUsage: appEnergyUsage ?? this.appEnergyUsage,
      energySavingRate: energySavingRate ?? this.energySavingRate,
      totalBadges: totalBadges ?? this.totalBadges,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      actionsCompleted: actionsCompleted ?? this.actionsCompleted,
      highCarbonProductsCount: highCarbonProductsCount ?? this.highCarbonProductsCount,
      mediumCarbonProductsCount: mediumCarbonProductsCount ?? this.mediumCarbonProductsCount,
      lowCarbonProductsCount: lowCarbonProductsCount ?? this.lowCarbonProductsCount,
      currentGoal: currentGoal ?? this.currentGoal,
      goalsCompleted: goalsCompleted ?? this.goalsCompleted,
      communityRanking: communityRanking ?? this.communityRanking,
      communityContribution: communityContribution ?? this.communityContribution,
      deviceUsageHours: deviceUsageHours ?? this.deviceUsageHours,
      deviceEnergyUsage: deviceEnergyUsage ?? this.deviceEnergyUsage,
      achievements: achievements ?? this.achievements,
    );
  }

  // Conversion depuis JSON
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      userId: json['userId'] ?? '',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now(),
      carbonFootprint: (json['carbonFootprint'] ?? 0).toDouble(),
      carbonSaved: (json['carbonSaved'] ?? 0).toDouble(),
      carbonTrend: json['carbonTrend'] ?? 0,
      productsScanCount: json['productsScanCount'] ?? 0,
      avgProductEcoScore: (json['avgProductEcoScore'] ?? 0).toDouble(),
      ecoFriendlyProductCount: json['ecoFriendlyProductCount'] ?? 0,
      activeGoalsCount: json['activeGoalsCount'] ?? 0,
      completedGoalsCount: json['completedGoalsCount'] ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] ?? 0).toDouble(),
      participatedChallenges: json['participatedChallenges'] ?? 0,
      totalCommunityImpact: json['totalCommunityImpact'] ?? 0,
      appEnergyUsage: (json['appEnergyUsage'] ?? 0).toDouble(),
      energySavingRate: json['energySavingRate'] ?? 0,
      totalBadges: json['totalBadges'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      currentLevel: json['currentLevel'] ?? 'Débutant',
      actionsCompleted: json['actionsCompleted'] ?? 0,
      highCarbonProductsCount: json['highCarbonProductsCount'] ?? 0,
      mediumCarbonProductsCount: json['mediumCarbonProductsCount'] ?? 0,
      lowCarbonProductsCount: json['lowCarbonProductsCount'] ?? 0,
      currentGoal: json['currentGoal'] as Map<String, dynamic>?,
      goalsCompleted: json['goalsCompleted'] ?? 0,
      communityRanking: json['communityRanking'] ?? 0,
      communityContribution: (json['communityContribution'] ?? 0).toDouble(),
      deviceUsageHours: (json['deviceUsageHours'] ?? 0).toDouble(),
      deviceEnergyUsage: (json['deviceEnergyUsage'] ?? 0).toDouble(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lastUpdated': lastUpdated.toIso8601String(),
      'carbonFootprint': carbonFootprint,
      'carbonSaved': carbonSaved,
      'carbonTrend': carbonTrend,
      'productsScanCount': productsScanCount,
      'avgProductEcoScore': avgProductEcoScore,
      'ecoFriendlyProductCount': ecoFriendlyProductCount,
      'activeGoalsCount': activeGoalsCount,
      'completedGoalsCount': completedGoalsCount,
      'goalCompletionRate': goalCompletionRate,
      'participatedChallenges': participatedChallenges,
      'totalCommunityImpact': totalCommunityImpact,
      'appEnergyUsage': appEnergyUsage,
      'energySavingRate': energySavingRate,
      'totalBadges': totalBadges,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'actionsCompleted': actionsCompleted,
      'highCarbonProductsCount': highCarbonProductsCount,
      'mediumCarbonProductsCount': mediumCarbonProductsCount,
      'lowCarbonProductsCount': lowCarbonProductsCount,
      'currentGoal': currentGoal,
      'goalsCompleted': goalsCompleted,
      'communityRanking': communityRanking,
      'communityContribution': communityContribution,
      'deviceUsageHours': deviceUsageHours,
      'deviceEnergyUsage': deviceEnergyUsage,
      'achievements': achievements,
    };
  }
  
  // Méthode pour calculer le niveau de l'utilisateur
  String calculateLevel() {
    if (totalPoints < 100) {
      return 'Débutant';
    } else if (totalPoints < 500) {
      return 'Apprenti';
    } else if (totalPoints < 1000) {
      return 'Éco-conscient';
    } else if (totalPoints < 2000) {
      return 'Éco-responsable';
    } else if (totalPoints < 5000) {
      return 'Éco-expert';
    } else {
      return 'Éco-champion';
    }
  }
} 