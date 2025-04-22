import 'package:flutter/material.dart';

class UserProfileModel {
  final String id;
  final String name;
  
  // Transport
  final TransportProfile transportProfile;
  
  // Alimentation
  final FoodProfile foodProfile;
  
  // Énergie
  final EnergyProfile energyProfile;
  
  // Consommation
  final ConsumptionProfile consumptionProfile;
  
  // Statistiques calculées
  final double totalCarbonFootprint; // en tonnes de CO2 par an
  final Map<String, double> footprintByCategory;
  final EcoLevel ecoLevel;
  
  UserProfileModel({
    required this.id,
    required this.name,
    required this.transportProfile,
    required this.foodProfile,
    required this.energyProfile,
    required this.consumptionProfile,
    required this.totalCarbonFootprint,
    required this.footprintByCategory,
    required this.ecoLevel,
  });
  
  factory UserProfileModel.empty() {
    return UserProfileModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Nouvel utilisateur',
      transportProfile: TransportProfile.empty(),
      foodProfile: FoodProfile.empty(),
      energyProfile: EnergyProfile.empty(),
      consumptionProfile: ConsumptionProfile.empty(),
      totalCarbonFootprint: 0.0,
      footprintByCategory: {
        'Transport': 0.0,
        'Alimentation': 0.0,
        'Logement': 0.0,
        'Consommation': 0.0,
      },
      ecoLevel: EcoLevel.debutant,
    );
  }
  
  UserProfileModel copyWith({
    String? id,
    String? name,
    TransportProfile? transportProfile,
    FoodProfile? foodProfile,
    EnergyProfile? energyProfile,
    ConsumptionProfile? consumptionProfile,
    double? totalCarbonFootprint,
    Map<String, double>? footprintByCategory,
    EcoLevel? ecoLevel,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      transportProfile: transportProfile ?? this.transportProfile,
      foodProfile: foodProfile ?? this.foodProfile,
      energyProfile: energyProfile ?? this.energyProfile,
      consumptionProfile: consumptionProfile ?? this.consumptionProfile,
      totalCarbonFootprint: totalCarbonFootprint ?? this.totalCarbonFootprint,
      footprintByCategory: footprintByCategory ?? this.footprintByCategory,
      ecoLevel: ecoLevel ?? this.ecoLevel,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'transportProfile': transportProfile.toMap(),
      'foodProfile': foodProfile.toMap(),
      'energyProfile': energyProfile.toMap(),
      'consumptionProfile': consumptionProfile.toMap(),
      'totalCarbonFootprint': totalCarbonFootprint,
      'footprintByCategory': footprintByCategory,
      'ecoLevel': ecoLevel.index,
    };
  }
  
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Utilisateur',
      transportProfile: TransportProfile.fromMap(map['transportProfile']),
      foodProfile: FoodProfile.fromMap(map['foodProfile']),
      energyProfile: EnergyProfile.fromMap(map['energyProfile']),
      consumptionProfile: ConsumptionProfile.fromMap(map['consumptionProfile']),
      totalCarbonFootprint: map['totalCarbonFootprint'] ?? 0.0,
      footprintByCategory: Map<String, double>.from(map['footprintByCategory'] ?? {}),
      ecoLevel: EcoLevel.values[map['ecoLevel'] ?? 0],
    );
  }
  
  String getProgressSuggestion() {
    if (totalCarbonFootprint > 10) {
      return "Pour atteindre les 2 tonnes de CO₂/an recommandées, commencez par réduire votre impact de transport.";
    } else if (totalCarbonFootprint > 5) {
      return "Vous êtes sur la bonne voie ! Pour atteindre les 2 tonnes de CO₂/an, réduisez votre consommation de viande.";
    } else if (totalCarbonFootprint > 2) {
      return "Encore un effort ! Pour atteindre les 2 tonnes de CO₂/an, optimisez votre consommation d'énergie.";
    } else {
      return "Bravo ! Vous êtes déjà sous la barre des 2 tonnes de CO₂/an, continuez comme ça !";
    }
  }
}

// Profil de transport
class TransportProfile {
  final TransportMode primaryMode;
  final int carKilometersPerYear;
  final int publicTransportKilometersPerYear;
  final int flightsPerYear;
  final int longDistanceFlightsPerYear;
  
  TransportProfile({
    required this.primaryMode,
    required this.carKilometersPerYear,
    required this.publicTransportKilometersPerYear,
    required this.flightsPerYear,
    required this.longDistanceFlightsPerYear,
  });
  
  factory TransportProfile.empty() {
    return TransportProfile(
      primaryMode: TransportMode.publicTransport,
      carKilometersPerYear: 0,
      publicTransportKilometersPerYear: 0,
      flightsPerYear: 0,
      longDistanceFlightsPerYear: 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'primaryMode': primaryMode.index,
      'carKilometersPerYear': carKilometersPerYear,
      'publicTransportKilometersPerYear': publicTransportKilometersPerYear,
      'flightsPerYear': flightsPerYear,
      'longDistanceFlightsPerYear': longDistanceFlightsPerYear,
    };
  }
  
  factory TransportProfile.fromMap(Map<String, dynamic> map) {
    return TransportProfile(
      primaryMode: TransportMode.values[map['primaryMode'] ?? 0],
      carKilometersPerYear: map['carKilometersPerYear'] ?? 0,
      publicTransportKilometersPerYear: map['publicTransportKilometersPerYear'] ?? 0,
      flightsPerYear: map['flightsPerYear'] ?? 0,
      longDistanceFlightsPerYear: map['longDistanceFlightsPerYear'] ?? 0,
    );
  }
  
  double calculateCarbonFootprint() {
    double footprint = 0.0;
    
    // CO2 pour la voiture (en tonnes) : ~ 0.2 kg CO2/km
    footprint += carKilometersPerYear * 0.0002;
    
    // CO2 pour les transports en commun (en tonnes) : ~ 0.05 kg CO2/km
    footprint += publicTransportKilometersPerYear * 0.00005;
    
    // CO2 pour les vols court/moyen-courrier (en tonnes) : ~ 0.2 tonnes par vol
    footprint += flightsPerYear * 0.2;
    
    // CO2 pour les vols long-courrier (en tonnes) : ~ 1.5 tonnes par vol
    footprint += longDistanceFlightsPerYear * 1.5;
    
    return footprint;
  }
}

enum TransportMode {
  walking,
  cycling,
  publicTransport,
  car,
  other
}

// Profil alimentaire
class FoodProfile {
  final DietType dietType;
  final int meatMealsPerWeek;
  final bool localSeasonal;
  final int wastePercentage;
  
  FoodProfile({
    required this.dietType,
    required this.meatMealsPerWeek,
    required this.localSeasonal,
    required this.wastePercentage,
  });
  
  factory FoodProfile.empty() {
    return FoodProfile(
      dietType: DietType.omnivore,
      meatMealsPerWeek: 7,
      localSeasonal: false,
      wastePercentage: 30,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'dietType': dietType.index,
      'meatMealsPerWeek': meatMealsPerWeek,
      'localSeasonal': localSeasonal,
      'wastePercentage': wastePercentage,
    };
  }
  
  factory FoodProfile.fromMap(Map<String, dynamic> map) {
    return FoodProfile(
      dietType: DietType.values[map['dietType'] ?? 0],
      meatMealsPerWeek: map['meatMealsPerWeek'] ?? 7,
      localSeasonal: map['localSeasonal'] ?? false,
      wastePercentage: map['wastePercentage'] ?? 30,
    );
  }
  
  double calculateCarbonFootprint() {
    double baseDietFootprint = 0.0;
    
    // Émissions de base selon le régime alimentaire (en tonnes par an)
    switch (dietType) {
      case DietType.vegan:
        baseDietFootprint = 1.0;
        break;
      case DietType.vegetarian:
        baseDietFootprint = 1.5;
        break;
      case DietType.pescatarian:
        baseDietFootprint = 1.8;
        break;
      case DietType.omnivore:
        baseDietFootprint = 2.0 + (meatMealsPerWeek * 0.1); // Plus de viande = plus d'émissions
        break;
    }
    
    // Réduction pour alimentation locale et de saison
    if (localSeasonal) {
      baseDietFootprint *= 0.8; // 20% de réduction
    }
    
    // Impact du gaspillage alimentaire
    baseDietFootprint *= (1 + (wastePercentage / 100) * 0.3);
    
    return baseDietFootprint;
  }
}

enum DietType {
  vegan,
  vegetarian,
  pescatarian,
  omnivore
}

// Profil énergétique
class EnergyProfile {
  final EnergyType energyType;
  final int homeSize; // en m²
  final int electricityConsumption; // en kWh par an
  final int heatingConsumption; // en kWh par an
  final bool renewableEnergy;
  
  EnergyProfile({
    required this.energyType,
    required this.homeSize,
    required this.electricityConsumption,
    required this.heatingConsumption,
    required this.renewableEnergy,
  });
  
  factory EnergyProfile.empty() {
    return EnergyProfile(
      energyType: EnergyType.electricity,
      homeSize: 75,
      electricityConsumption: 3500,
      heatingConsumption: 10000,
      renewableEnergy: false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'energyType': energyType.index,
      'homeSize': homeSize,
      'electricityConsumption': electricityConsumption,
      'heatingConsumption': heatingConsumption,
      'renewableEnergy': renewableEnergy,
    };
  }
  
  factory EnergyProfile.fromMap(Map<String, dynamic> map) {
    return EnergyProfile(
      energyType: EnergyType.values[map['energyType'] ?? 0],
      homeSize: map['homeSize'] ?? 75,
      electricityConsumption: map['electricityConsumption'] ?? 3500,
      heatingConsumption: map['heatingConsumption'] ?? 10000,
      renewableEnergy: map['renewableEnergy'] ?? false,
    );
  }
  
  double calculateCarbonFootprint() {
    double footprint = 0.0;
    
    // CO2 pour l'électricité (en tonnes) : ~ 0.0001 tonnes par kWh en France
    double electricityFactor = renewableEnergy ? 0.00001 : 0.0001;
    footprint += electricityConsumption * electricityFactor;
    
    // CO2 pour le chauffage
    double heatingFactor = 0.0;
    switch (energyType) {
      case EnergyType.electricity:
        heatingFactor = 0.0001;
        break;
      case EnergyType.gas:
        heatingFactor = 0.0002;
        break;
      case EnergyType.fuelOil:
        heatingFactor = 0.0003;
        break;
      case EnergyType.wood:
        heatingFactor = 0.00005;
        break;
    }
    
    footprint += heatingConsumption * heatingFactor;
    
    return footprint;
  }
}

enum EnergyType {
  electricity,
  gas,
  fuelOil,
  wood
}

// Profil de consommation
class ConsumptionProfile {
  final int newClothesPerYear;
  final int newElectronicsPerYear;
  final int plasticWastePerWeek; // en grammes
  final int recyclingPercentage;
  
  ConsumptionProfile({
    required this.newClothesPerYear,
    required this.newElectronicsPerYear,
    required this.plasticWastePerWeek,
    required this.recyclingPercentage,
  });
  
  factory ConsumptionProfile.empty() {
    return ConsumptionProfile(
      newClothesPerYear: 10,
      newElectronicsPerYear: 1,
      plasticWastePerWeek: 500,
      recyclingPercentage: 30,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'newClothesPerYear': newClothesPerYear,
      'newElectronicsPerYear': newElectronicsPerYear,
      'plasticWastePerWeek': plasticWastePerWeek,
      'recyclingPercentage': recyclingPercentage,
    };
  }
  
  factory ConsumptionProfile.fromMap(Map<String, dynamic> map) {
    return ConsumptionProfile(
      newClothesPerYear: map['newClothesPerYear'] ?? 10,
      newElectronicsPerYear: map['newElectronicsPerYear'] ?? 1,
      plasticWastePerWeek: map['plasticWastePerWeek'] ?? 500,
      recyclingPercentage: map['recyclingPercentage'] ?? 30,
    );
  }
  
  double calculateCarbonFootprint() {
    double footprint = 0.0;
    
    // CO2 pour les vêtements (en tonnes) : ~ 0.05 tonnes par vêtement
    footprint += newClothesPerYear * 0.05;
    
    // CO2 pour l'électronique (en tonnes) : ~ 0.1 tonnes par appareil (moyenne)
    footprint += newElectronicsPerYear * 0.1;
    
    // CO2 pour les déchets plastiques (en tonnes) : ~ 0.0001 tonnes par kg
    footprint += (plasticWastePerWeek / 1000) * 52 * 0.0001;
    
    // Réduction grâce au recyclage
    footprint *= (1 - (recyclingPercentage / 100) * 0.2); // 20% d'impact max du recyclage
    
    return footprint;
  }
}

enum EcoLevel {
  debutant,
  explorateur,
  acteur,
  ambassadeur,
  expert
}

class UserProfileModel {
  final String id;
  final String name;
  final Map<String, double> footprintByCategory;
  final double totalCarbonFootprint;
  
  UserProfileModel({
    required this.id,
    required this.name,
    required this.footprintByCategory,
    required this.totalCarbonFootprint,
  });
  
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> footprintMap = json['footprintByCategory'] ?? {};
    final Map<String, double> footprintByCategory = footprintMap.map(
      (key, value) => MapEntry(key, value is double ? value : (value as num).toDouble())
    );
    
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      footprintByCategory: footprintByCategory,
      totalCarbonFootprint: json['totalCarbonFootprint'] is double 
          ? json['totalCarbonFootprint'] 
          : (json['totalCarbonFootprint'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'footprintByCategory': footprintByCategory,
      'totalCarbonFootprint': totalCarbonFootprint,
    };
  }
  
  UserProfileModel copyWith({
    String? id,
    String? name,
    Map<String, double>? footprintByCategory,
    double? totalCarbonFootprint,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      footprintByCategory: footprintByCategory ?? this.footprintByCategory,
      totalCarbonFootprint: totalCarbonFootprint ?? this.totalCarbonFootprint,
    );
  }
} 