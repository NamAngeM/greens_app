class CarbonFootprintModel {
  final String id;
  final String userId;
  final DateTime date;
  final double transportScore;
  final double energyScore;
  final double foodScore;
  final double consumptionScore;
  final double digitalScore;
  final double totalScore;
  final Map<String, dynamic>? details;
  final List<String>? recommendations;
  final int pointsEarned;

  CarbonFootprintModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.transportScore,
    required this.energyScore,
    required this.foodScore,
    required this.consumptionScore,
    required this.digitalScore,
    required this.totalScore,
    this.details,
    this.recommendations,
    this.pointsEarned = 0,
  });

  // Méthode pour créer une copie avec des champs mis à jour
  CarbonFootprintModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? transportScore,
    double? energyScore,
    double? foodScore,
    double? consumptionScore,
    double? digitalScore,
    double? totalScore,
    Map<String, dynamic>? details,
    List<String>? recommendations,
    int? pointsEarned,
  }) {
    return CarbonFootprintModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      transportScore: transportScore ?? this.transportScore,
      energyScore: energyScore ?? this.energyScore,
      foodScore: foodScore ?? this.foodScore,
      consumptionScore: consumptionScore ?? this.consumptionScore,
      digitalScore: digitalScore ?? this.digitalScore,
      totalScore: totalScore ?? this.totalScore,
      details: details ?? this.details,
      recommendations: recommendations ?? this.recommendations,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }

  factory CarbonFootprintModel.fromJson(Map<String, dynamic> json) {
    return CarbonFootprintModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      transportScore: (json['transportScore'] ?? 0).toDouble(),
      energyScore: (json['energyScore'] ?? 0).toDouble(),
      foodScore: (json['foodScore'] ?? 0).toDouble(),
      consumptionScore: (json['consumptionScore'] ?? 0).toDouble(),
      digitalScore: (json['digitalScore'] ?? 0).toDouble(),
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      details: json['details'],
      recommendations: json['recommendations'] != null 
          ? List<String>.from(json['recommendations']) 
          : null,
      pointsEarned: json['pointsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'transportScore': transportScore,
      'energyScore': energyScore,
      'foodScore': foodScore,
      'consumptionScore': consumptionScore,
      'digitalScore': digitalScore,
      'totalScore': totalScore,
      'details': details,
      'recommendations': recommendations,
      'pointsEarned': pointsEarned,
    };
  }

  // Méthode pour créer une instance initiale avec des valeurs par défaut
  factory CarbonFootprintModel.initial() {
    return CarbonFootprintModel(
      id: 'initial',
      userId: 'initial',
      date: DateTime.now(),
      transportScore: 0.0,
      energyScore: 0.0,
      foodScore: 0.0,
      consumptionScore: 0.0,
      digitalScore: 0.0,
      totalScore: 0.0,
      details: {
        'transport': {'car': 0, 'public': 0, 'bike': 0, 'walk': 0},
        'energy': {'electricity': 0, 'heating': 0},
        'food': {'meat': 0, 'dairy': 0, 'vegetable': 0},
        'consumption': {'clothing': 0, 'electronics': 0, 'others': 0},
        'digital': {'streaming': 0, 'emails': 0, 'cloud': 0},
      },
      recommendations: [
        'Privilégiez les transports en commun ou le vélo pour vos déplacements quotidiens',
        'Réduisez votre consommation de viande',
        'Éteignez les appareils en veille'
      ],
      pointsEarned: 0,
    );
  }
  
  // Getter pour obtenir l'empreinte carbone totale en kg de CO2
  double get totalFootprint {
    // Conversion arbitraire du score en kg de CO2 (à ajuster selon votre logique)
    return totalScore * 100; // par exemple, 1 point = 100 kg de CO2
  }
}
