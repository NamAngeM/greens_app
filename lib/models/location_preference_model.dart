import 'package:flutter/foundation.dart';

enum LocationAccuracy {
  precise, // GPS précis (élevée consommation d'énergie)
  balanced, // Équilibré (précision vs économie d'énergie)
  lowPower, // Précision réduite (économie d'énergie)
  passive // Uniquement lorsque d'autres apps utilisent la localisation
}

enum LocationUpdateFrequency {
  continuous, // Mise à jour continue (haute consommation)
  high, // Fréquente (toutes les 30 secondes)
  medium, // Modérée (toutes les 2 minutes)
  low, // Basse (toutes les 15 minutes)
  manual // Seulement à la demande explicite
}

class LocationPreferenceModel {
  final String id;
  final String userId;
  final LocationAccuracy accuracy;
  final LocationUpdateFrequency updateFrequency;
  final bool useWifiOnly; // Si true, n'utilise que le WiFi pour localiser
  final bool onlyWhenRequired; // Si true, n'active que pour les fonctionnalités qui le nécessitent

  LocationPreferenceModel({
    required this.id,
    required this.userId,
    this.accuracy = LocationAccuracy.balanced,
    this.updateFrequency = LocationUpdateFrequency.medium,
    this.useWifiOnly = false,
    this.onlyWhenRequired = true,
  });

  // Méthode pour créer une copie avec des paramètres modifiés
  LocationPreferenceModel copyWith({
    String? id,
    String? userId,
    LocationAccuracy? accuracy,
    LocationUpdateFrequency? updateFrequency,
    bool? useWifiOnly,
    bool? onlyWhenRequired,
  }) {
    return LocationPreferenceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accuracy: accuracy ?? this.accuracy,
      updateFrequency: updateFrequency ?? this.updateFrequency,
      useWifiOnly: useWifiOnly ?? this.useWifiOnly,
      onlyWhenRequired: onlyWhenRequired ?? this.onlyWhenRequired,
    );
  }

  // Conversion depuis JSON
  factory LocationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return LocationPreferenceModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      accuracy: LocationAccuracy.values[json['accuracy'] ?? 1], // 1 = balanced
      updateFrequency: LocationUpdateFrequency.values[json['updateFrequency'] ?? 2], // 2 = medium
      useWifiOnly: json['useWifiOnly'] ?? false,
      onlyWhenRequired: json['onlyWhenRequired'] ?? true,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accuracy': accuracy.index,
      'updateFrequency': updateFrequency.index,
      'useWifiOnly': useWifiOnly,
      'onlyWhenRequired': onlyWhenRequired,
    };
  }

  // Estimation de l'économie d'énergie par rapport au maximum
  // Retourne un pourcentage approximatif d'économie d'énergie (0-100)
  int getEstimatedEnergySaving() {
    int base = 0;
    
    // Estimation basée sur la précision
    switch (accuracy) {
      case LocationAccuracy.precise:
        base += 0; // Aucune économie
        break;
      case LocationAccuracy.balanced:
        base += 20; // 20% d'économie
        break;
      case LocationAccuracy.lowPower:
        base += 40; // 40% d'économie
        break;
      case LocationAccuracy.passive:
        base += 70; // 70% d'économie
        break;
    }
    
    // Estimation basée sur la fréquence
    switch (updateFrequency) {
      case LocationUpdateFrequency.continuous:
        base += 0; // Aucune économie
        break;
      case LocationUpdateFrequency.high:
        base += 10; // 10% d'économie
        break;
      case LocationUpdateFrequency.medium:
        base += 20; // 20% d'économie
        break;
      case LocationUpdateFrequency.low:
        base += 30; // 30% d'économie
        break;
      case LocationUpdateFrequency.manual:
        base += 50; // 50% d'économie
        break;
    }
    
    // Bonus pour l'utilisation du WiFi uniquement
    if (useWifiOnly) {
      base += 15;
    }
    
    // Bonus pour l'activation uniquement quand nécessaire
    if (onlyWhenRequired) {
      base += 15;
    }
    
    // Moyenne pondérée avec maximum de 100%
    return base ~/ 2 > 100 ? 100 : base ~/ 2;
  }
} 