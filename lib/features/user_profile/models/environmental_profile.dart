class EnvironmentalProfile {
  // Transport
  final TransportHabits transportHabits;
  
  // Alimentation
  final DietProfile dietProfile;
  
  // Énergie
  final EnergyProfile energyProfile;
  
  // Consommation
  final ConsumptionProfile consumptionProfile;
  
  // Numérique - Ajout de la nouvelle propriété
  final DigitalProfile digitalProfile;
  
  // Données calculées
  final double carbonFootprint; // tonnes CO2/an
  final double waterFootprint; // m3/an
  final double wasteGenerated; // kg/an
  
  const EnvironmentalProfile({
    required this.transportHabits,
    required this.dietProfile,
    required this.energyProfile,
    required this.consumptionProfile,
    required this.digitalProfile,
    this.carbonFootprint = 0.0,
    this.waterFootprint = 0.0,
    this.wasteGenerated = 0.0,
  });
  
  // Crée une copie avec certaines valeurs modifiées
  EnvironmentalProfile copyWith({
    TransportHabits? transportHabits,
    DietProfile? dietProfile,
    EnergyProfile? energyProfile,
    ConsumptionProfile? consumptionProfile,
    DigitalProfile? digitalProfile,
    double? carbonFootprint,
    double? waterFootprint,
    double? wasteGenerated,
  }) {
    return EnvironmentalProfile(
      transportHabits: transportHabits ?? this.transportHabits,
      dietProfile: dietProfile ?? this.dietProfile,
      energyProfile: energyProfile ?? this.energyProfile,
      consumptionProfile: consumptionProfile ?? this.consumptionProfile,
      digitalProfile: digitalProfile ?? this.digitalProfile,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      waterFootprint: waterFootprint ?? this.waterFootprint,
      wasteGenerated: wasteGenerated ?? this.wasteGenerated,
    );
  }
  
  // Calcule l'empreinte carbone totale en utilisant les données du profil
  double calculateTotalCarbonFootprint() {
    double transport = transportHabits.calculateCarbonFootprint();
    double diet = dietProfile.calculateCarbonFootprint();
    double energy = energyProfile.calculateCarbonFootprint();
    double consumption = consumptionProfile.calculateCarbonFootprint();
    double digital = digitalProfile.calculateCarbonFootprint();
    
    return transport + diet + energy + consumption + digital;
  }
  
  // Convertit le profil en Map pour la sauvegarde
  Map<String, dynamic> toMap() {
    return {
      'transportHabits': transportHabits.toMap(),
      'dietProfile': dietProfile.toMap(),
      'energyProfile': energyProfile.toMap(),
      'consumptionProfile': consumptionProfile.toMap(),
      'digitalProfile': digitalProfile.toMap(),
      'carbonFootprint': carbonFootprint,
      'waterFootprint': waterFootprint,
      'wasteGenerated': wasteGenerated,
    };
  }
  
  // Crée un profil à partir d'une Map
  factory EnvironmentalProfile.fromMap(Map<String, dynamic> map) {
    return EnvironmentalProfile(
      transportHabits: TransportHabits.fromMap(map['transportHabits']),
      dietProfile: DietProfile.fromMap(map['dietProfile']),
      energyProfile: EnergyProfile.fromMap(map['energyProfile']),
      consumptionProfile: ConsumptionProfile.fromMap(map['consumptionProfile']),
      digitalProfile: map['digitalProfile'] != null 
          ? DigitalProfile.fromMap(map['digitalProfile']) 
          : DigitalProfile.empty(),
      carbonFootprint: map['carbonFootprint'] ?? 0.0,
      waterFootprint: map['waterFootprint'] ?? 0.0,
      wasteGenerated: map['wasteGenerated'] ?? 0.0,
    );
  }
  
  // Crée un profil vide avec des valeurs par défaut
  factory EnvironmentalProfile.empty() {
    return EnvironmentalProfile(
      transportHabits: TransportHabits.empty(),
      dietProfile: DietProfile.empty(),
      energyProfile: EnergyProfile.empty(),
      consumptionProfile: ConsumptionProfile.empty(),
      digitalProfile: DigitalProfile.empty(),
    );
  }
}

// Transport
class TransportHabits {
  final double carKmPerWeek; // km parcourus en voiture par semaine
  final bool isElectricCar; // voiture électrique ou non
  final double publicTransportKmPerWeek; // km en transports en commun par semaine
  final double bikeKmPerWeek; // km à vélo par semaine
  final double walkingKmPerWeek; // km à pied par semaine
  final int flightsPerYear; // nombre de vols par an
  final double flightHoursPerYear; // heures de vol par an
  
  const TransportHabits({
    this.carKmPerWeek = 0.0,
    this.isElectricCar = false,
    this.publicTransportKmPerWeek = 0.0,
    this.bikeKmPerWeek = 0.0,
    this.walkingKmPerWeek = 0.0,
    this.flightsPerYear = 0,
    this.flightHoursPerYear = 0.0,
  });
  
  // Calcule l'empreinte carbone des transports
  double calculateCarbonFootprint() {
    // Facteurs d'émission approximatifs
    final double carEmissionFactor = isElectricCar ? 0.02 : 0.2; // kg CO2/km
    final double publicTransportEmissionFactor = 0.05; // kg CO2/km
    final double flightEmissionFactor = 100.0; // kg CO2/heure
    
    // Calcul des émissions annuelles
    double carEmissions = carKmPerWeek * 52 * carEmissionFactor;
    double publicTransportEmissions = publicTransportKmPerWeek * 52 * publicTransportEmissionFactor;
    double flightEmissions = flightHoursPerYear * flightEmissionFactor;
    
    // Le vélo et la marche ont une empreinte carbone négligeable
    
    // Total en tonnes de CO2
    return (carEmissions + publicTransportEmissions + flightEmissions) / 1000;
  }
  
  // Sérialisation pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'carKmPerWeek': carKmPerWeek,
      'isElectricCar': isElectricCar,
      'publicTransportKmPerWeek': publicTransportKmPerWeek,
      'bikeKmPerWeek': bikeKmPerWeek,
      'walkingKmPerWeek': walkingKmPerWeek,
      'flightsPerYear': flightsPerYear,
      'flightHoursPerYear': flightHoursPerYear,
    };
  }
  
  // Désérialisation
  factory TransportHabits.fromMap(Map<String, dynamic> map) {
    return TransportHabits(
      carKmPerWeek: map['carKmPerWeek'] ?? 0.0,
      isElectricCar: map['isElectricCar'] ?? false,
      publicTransportKmPerWeek: map['publicTransportKmPerWeek'] ?? 0.0,
      bikeKmPerWeek: map['bikeKmPerWeek'] ?? 0.0,
      walkingKmPerWeek: map['walkingKmPerWeek'] ?? 0.0,
      flightsPerYear: map['flightsPerYear'] ?? 0,
      flightHoursPerYear: map['flightHoursPerYear'] ?? 0.0,
    );
  }
  
  // Valeurs par défaut
  factory TransportHabits.empty() {
    return const TransportHabits();
  }
}

// Alimentation
class DietProfile {
  final DietType dietType;
  final double meatKgPerWeek; // kg de viande par semaine
  final double dairyKgPerWeek; // kg de produits laitiers par semaine
  final bool localProducePreference; // préférence pour les produits locaux
  final bool organicPreference; // préférence pour le bio
  final double processedFoodPercentage; // pourcentage d'aliments transformés
  
  const DietProfile({
    this.dietType = DietType.omnivore,
    this.meatKgPerWeek = 0.5,
    this.dairyKgPerWeek = 1.0,
    this.localProducePreference = false,
    this.organicPreference = false,
    this.processedFoodPercentage = 50,
  });
  
  // Calcule l'empreinte carbone de l'alimentation
  double calculateCarbonFootprint() {
    // Facteurs d'émission approximatifs
    final Map<DietType, double> dietBaseEmissions = {
      DietType.vegan: 1.0, // tonnes CO2/an
      DietType.vegetarian: 1.5,
      DietType.pescatarian: 1.8,
      DietType.flexitarian: 2.0,
      DietType.omnivore: 2.5,
    };
    
    // Émissions de base selon le régime alimentaire
    double baseEmissions = dietBaseEmissions[dietType] ?? 2.5;
    
    // Ajustements
    double meatAdjustment = dietType == DietType.vegan || dietType == DietType.vegetarian
        ? 0.0
        : (meatKgPerWeek - 0.5) * 0.2; // 0.2 tonnes CO2 par kg de viande hebdomadaire au-dessus de 0.5kg
    
    double localAdjustment = localProducePreference ? -0.2 : 0.0;
    double organicAdjustment = organicPreference ? -0.1 : 0.0;
    double processedFoodAdjustment = (processedFoodPercentage - 50) / 100 * 0.3;
    
    return baseEmissions + meatAdjustment + localAdjustment + organicAdjustment + processedFoodAdjustment;
  }
  
  // Sérialisation pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'dietType': dietType.index,
      'meatKgPerWeek': meatKgPerWeek,
      'dairyKgPerWeek': dairyKgPerWeek,
      'localProducePreference': localProducePreference,
      'organicPreference': organicPreference,
      'processedFoodPercentage': processedFoodPercentage,
    };
  }
  
  // Désérialisation
  factory DietProfile.fromMap(Map<String, dynamic> map) {
    return DietProfile(
      dietType: DietType.values[map['dietType'] ?? 0],
      meatKgPerWeek: map['meatKgPerWeek'] ?? 0.5,
      dairyKgPerWeek: map['dairyKgPerWeek'] ?? 1.0,
      localProducePreference: map['localProducePreference'] ?? false,
      organicPreference: map['organicPreference'] ?? false,
      processedFoodPercentage: map['processedFoodPercentage'] ?? 50,
    );
  }
  
  // Valeurs par défaut
  factory DietProfile.empty() {
    return const DietProfile();
  }
}

// Types de régimes alimentaires
enum DietType {
  vegan,
  vegetarian,
  pescatarian,
  flexitarian,
  omnivore,
}

// Énergie
class EnergyProfile {
  final EnergySource heatingSource;
  final bool isRenewableElectricity;
  final double electricityKwhPerMonth; // consommation d'électricité mensuelle
  final double heatingKwhPerMonth; // consommation pour le chauffage mensuelle
  final bool hasEnergyEfficientAppliances; // appareils économes en énergie
  final bool hasHomeInsulation; // isolation du logement
  
  const EnergyProfile({
    this.heatingSource = EnergySource.naturalGas,
    this.isRenewableElectricity = false,
    this.electricityKwhPerMonth = 250.0,
    this.heatingKwhPerMonth = 500.0,
    this.hasEnergyEfficientAppliances = false,
    this.hasHomeInsulation = false,
  });
  
  // Calcule l'empreinte carbone de l'énergie
  double calculateCarbonFootprint() {
    // Facteurs d'émission approximatifs
    final Map<EnergySource, double> heatingEmissionFactors = {
      EnergySource.electricity: isRenewableElectricity ? 0.05 : 0.2, // kg CO2/kWh
      EnergySource.naturalGas: 0.25,
      EnergySource.oil: 0.35,
      EnergySource.wood: 0.05,
      EnergySource.heatPump: 0.08,
    };
    
    double electricityEmissionFactor = isRenewableElectricity ? 0.05 : 0.2; // kg CO2/kWh
    
    // Calcul des émissions annuelles
    double electricityEmissions = electricityKwhPerMonth * 12 * electricityEmissionFactor;
    double heatingEmissionFactor = heatingEmissionFactors[heatingSource] ?? 0.25;
    double heatingEmissions = heatingKwhPerMonth * 12 * heatingEmissionFactor;
    
    // Ajustements pour l'efficacité énergétique
    double efficiencyAdjustment = 1.0;
    if (hasEnergyEfficientAppliances) efficiencyAdjustment -= 0.1;
    if (hasHomeInsulation) efficiencyAdjustment -= 0.2;
    
    // Total en tonnes de CO2
    return (electricityEmissions + heatingEmissions) * efficiencyAdjustment / 1000;
  }
  
  // Sérialisation pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'heatingSource': heatingSource.index,
      'isRenewableElectricity': isRenewableElectricity,
      'electricityKwhPerMonth': electricityKwhPerMonth,
      'heatingKwhPerMonth': heatingKwhPerMonth,
      'hasEnergyEfficientAppliances': hasEnergyEfficientAppliances,
      'hasHomeInsulation': hasHomeInsulation,
    };
  }
  
  // Désérialisation
  factory EnergyProfile.fromMap(Map<String, dynamic> map) {
    return EnergyProfile(
      heatingSource: EnergySource.values[map['heatingSource'] ?? 0],
      isRenewableElectricity: map['isRenewableElectricity'] ?? false,
      electricityKwhPerMonth: map['electricityKwhPerMonth'] ?? 250.0,
      heatingKwhPerMonth: map['heatingKwhPerMonth'] ?? 500.0,
      hasEnergyEfficientAppliances: map['hasEnergyEfficientAppliances'] ?? false,
      hasHomeInsulation: map['hasHomeInsulation'] ?? false,
    );
  }
  
  // Valeurs par défaut
  factory EnergyProfile.empty() {
    return const EnergyProfile();
  }
}

// Sources d'énergie pour le chauffage
enum EnergySource {
  electricity,
  naturalGas,
  oil,
  wood,
  heatPump,
}

// Consommation
class ConsumptionProfile {
  final int newClothesPerYear; // nombre de vêtements neufs par an
  final int newElectronicsPerYear; // nombre d'appareils électroniques par an
  final double plasticConsumptionKgPerWeek; // kg de plastique consommé par semaine
  final double wasteGeneratedKgPerWeek; // kg de déchets générés par semaine
  final double recyclingPercentage; // pourcentage de déchets recyclés
  final bool secondHandPreference; // préférence pour l'occasion
  
  const ConsumptionProfile({
    this.newClothesPerYear = 12,
    this.newElectronicsPerYear = 2,
    this.plasticConsumptionKgPerWeek = 0.5,
    this.wasteGeneratedKgPerWeek = 5.0,
    this.recyclingPercentage = 30.0,
    this.secondHandPreference = false,
  });
  
  // Calcule l'empreinte carbone de la consommation
  double calculateCarbonFootprint() {
    // Facteurs d'émission approximatifs
    final double clothingEmissionFactor = secondHandPreference ? 5.0 : 15.0; // kg CO2/vêtement
    final double electronicsEmissionFactor = 100.0; // kg CO2/appareil
    final double plasticEmissionFactor = 6.0; // kg CO2/kg de plastique
    final double wasteEmissionFactor = 0.5; // kg CO2/kg de déchets
    
    // Calcul des émissions annuelles
    double clothingEmissions = newClothesPerYear * clothingEmissionFactor;
    double electronicsEmissions = newElectronicsPerYear * electronicsEmissionFactor;
    double plasticEmissions = plasticConsumptionKgPerWeek * 52 * plasticEmissionFactor;
    double wasteEmissions = wasteGeneratedKgPerWeek * 52 * wasteEmissionFactor * (1 - recyclingPercentage / 100);
    
    // Total en tonnes de CO2
    return (clothingEmissions + electronicsEmissions + plasticEmissions + wasteEmissions) / 1000;
  }
  
  // Sérialisation pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'newClothesPerYear': newClothesPerYear,
      'newElectronicsPerYear': newElectronicsPerYear,
      'plasticConsumptionKgPerWeek': plasticConsumptionKgPerWeek,
      'wasteGeneratedKgPerWeek': wasteGeneratedKgPerWeek,
      'recyclingPercentage': recyclingPercentage,
      'secondHandPreference': secondHandPreference,
    };
  }
  
  // Désérialisation
  factory ConsumptionProfile.fromMap(Map<String, dynamic> map) {
    return ConsumptionProfile(
      newClothesPerYear: map['newClothesPerYear'] ?? 12,
      newElectronicsPerYear: map['newElectronicsPerYear'] ?? 2,
      plasticConsumptionKgPerWeek: map['plasticConsumptionKgPerWeek'] ?? 0.5,
      wasteGeneratedKgPerWeek: map['wasteGeneratedKgPerWeek'] ?? 5.0,
      recyclingPercentage: map['recyclingPercentage'] ?? 30.0,
      secondHandPreference: map['secondHandPreference'] ?? false,
    );
  }
  
  // Valeurs par défaut
  factory ConsumptionProfile.empty() {
    return const ConsumptionProfile();
  }
}

// Digital - Nouvelle classe pour la pollution numérique
class DigitalProfile {
  // Usage quotidien
  final double streamingHoursPerDay; // Heures de streaming par jour
  final double socialMediaHoursPerDay; // Heures sur les réseaux sociaux par jour
  final double videoCallsHoursPerWeek; // Heures d'appels vidéo par semaine
  
  // Stockage de données
  final double cloudStorageGB; // Stockage cloud en GB
  final int emailsPerDay; // Nombre d'emails envoyés par jour
  final bool cleanInbox; // Nettoyage régulier des emails
  
  // Appareils
  final int smartphonesOwnedLast5Years; // Smartphones possédés ces 5 dernières années
  final int computersOwnedLast5Years; // Ordinateurs possédés ces 5 dernières années
  final int otherDevicesOwnedLast5Years; // Autres appareils électroniques ces 5 dernières années
  
  // Habitudes
  final bool usesEcoSearchEngine; // Utilisation d'un moteur de recherche écologique
  final bool darkModeEnabled; // Mode sombre activé sur les appareils
  final bool lowDataModeEnabled; // Mode économie de données activé
  
  // Pollution sonore
  final int headphonesUseHoursPerDay; // Heures d'utilisation d'écouteurs par jour
  final double averageVolumeLevel; // Niveau moyen de volume (échelle 0-100)
  final bool usesNoiseCancellation; // Utilisation de la réduction de bruit
  final int exposureToLoudEnvironmentsHoursPerWeek; // Exposition à des environnements bruyants (heures/semaine)
  
  const DigitalProfile({
    this.streamingHoursPerDay = 2.0,
    this.socialMediaHoursPerDay = 2.0,
    this.videoCallsHoursPerWeek = 2.0,
    this.cloudStorageGB = 50.0,
    this.emailsPerDay = 20,
    this.cleanInbox = false,
    this.smartphonesOwnedLast5Years = 2,
    this.computersOwnedLast5Years = 1,
    this.otherDevicesOwnedLast5Years = 3,
    this.usesEcoSearchEngine = false,
    this.darkModeEnabled = false,
    this.lowDataModeEnabled = false,
    this.headphonesUseHoursPerDay = 2,
    this.averageVolumeLevel = 60,
    this.usesNoiseCancellation = false,
    this.exposureToLoudEnvironmentsHoursPerWeek = 5,
  });
  
  // Calcule l'empreinte carbone des activités numériques
  double calculateCarbonFootprint() {
    // Facteurs d'émission approximatifs
    final double streamingEmissionFactor = 0.08; // kg CO2/heure (HD)
    final double socialMediaEmissionFactor = 0.02; // kg CO2/heure
    final double videoCallEmissionFactor = 0.15; // kg CO2/heure
    final double cloudStorageEmissionFactor = 0.02; // kg CO2/GB/an
    final double emailEmissionFactor = 0.004; // kg CO2/email
    final double deviceEmissionFactor = 80.0; // kg CO2/appareil/an (fabrication amortie)
    
    // Usage internet et données
    double streamingEmissions = streamingHoursPerDay * 365 * streamingEmissionFactor;
    double socialMediaEmissions = socialMediaHoursPerDay * 365 * socialMediaEmissionFactor;
    double videoCallEmissions = videoCallsHoursPerWeek * 52 * videoCallEmissionFactor;
    double cloudEmissions = cloudStorageGB * cloudStorageEmissionFactor;
    double emailEmissions = emailsPerDay * 365 * emailEmissionFactor * (cleanInbox ? 0.7 : 1.0);
    
    // Fabrication des appareils
    double deviceEmissions = (smartphonesOwnedLast5Years + computersOwnedLast5Years + otherDevicesOwnedLast5Years) 
        * deviceEmissionFactor / 5; // Amortissement sur 5 ans
    
    // Pollution sonore - impact énergétique estimé
    // Les écouteurs à haut volume et sans réduction de bruit consomment plus d'énergie
    double soundEmissionFactor = 0.001; // kg CO2/heure d'utilisation
    double volumeMultiplier = averageVolumeLevel > 70 ? 1.5 : 1.0;
    double noiseCancellationMultiplier = usesNoiseCancellation ? 1.2 : 1.0; // consomme un peu plus d'énergie
    
    double soundEmissions = headphonesUseHoursPerDay * 365 * soundEmissionFactor 
        * volumeMultiplier * noiseCancellationMultiplier;
    
    // Réductions liées aux bonnes pratiques
    double practicesMultiplier = 1.0;
    if (usesEcoSearchEngine) practicesMultiplier -= 0.05;
    if (darkModeEnabled) practicesMultiplier -= 0.03;
    if (lowDataModeEnabled) practicesMultiplier -= 0.07;
    
    // Total en tonnes de CO2
    double totalEmissions = (streamingEmissions + socialMediaEmissions + videoCallEmissions +
                            cloudEmissions + emailEmissions + deviceEmissions + soundEmissions) * practicesMultiplier;
    
    return totalEmissions / 1000; // Conversion en tonnes
  }
  
  // Calcule l'impact sur la santé de la pollution sonore (échelle 0-100)
  double calculateSoundHealthImpact() {
    double baseImpact = 0.0;
    
    // Impact du volume
    if (averageVolumeLevel > 85) {
      baseImpact += 40; // Risque élevé de dommages auditifs
    } else if (averageVolumeLevel > 70) {
      baseImpact += 20; // Risque modéré
    } else if (averageVolumeLevel > 60) {
      baseImpact += 10; // Risque faible
    }
    
    // Impact de la durée d'exposition
    baseImpact += (headphonesUseHoursPerDay > 4) ? 20 : (headphonesUseHoursPerDay > 2 ? 10 : 0);
    
    // Impact des environnements bruyants
    baseImpact += (exposureToLoudEnvironmentsHoursPerWeek > 10) ? 30 : 
                  (exposureToLoudEnvironmentsHoursPerWeek > 5 ? 15 : 5);
    
    // Réduction grâce à la réduction de bruit active
    if (usesNoiseCancellation) {
      baseImpact *= 0.8; // Réduction de 20%
    }
    
    // Plafonner à 100
    return baseImpact > 100 ? 100 : baseImpact;
  }
  
  // Sérialisation pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'streamingHoursPerDay': streamingHoursPerDay,
      'socialMediaHoursPerDay': socialMediaHoursPerDay,
      'videoCallsHoursPerWeek': videoCallsHoursPerWeek,
      'cloudStorageGB': cloudStorageGB,
      'emailsPerDay': emailsPerDay,
      'cleanInbox': cleanInbox,
      'smartphonesOwnedLast5Years': smartphonesOwnedLast5Years,
      'computersOwnedLast5Years': computersOwnedLast5Years,
      'otherDevicesOwnedLast5Years': otherDevicesOwnedLast5Years,
      'usesEcoSearchEngine': usesEcoSearchEngine,
      'darkModeEnabled': darkModeEnabled,
      'lowDataModeEnabled': lowDataModeEnabled,
      'headphonesUseHoursPerDay': headphonesUseHoursPerDay,
      'averageVolumeLevel': averageVolumeLevel,
      'usesNoiseCancellation': usesNoiseCancellation,
      'exposureToLoudEnvironmentsHoursPerWeek': exposureToLoudEnvironmentsHoursPerWeek,
    };
  }
  
  // Désérialisation
  factory DigitalProfile.fromMap(Map<String, dynamic> map) {
    return DigitalProfile(
      streamingHoursPerDay: map['streamingHoursPerDay'] ?? 2.0,
      socialMediaHoursPerDay: map['socialMediaHoursPerDay'] ?? 2.0,
      videoCallsHoursPerWeek: map['videoCallsHoursPerWeek'] ?? 2.0,
      cloudStorageGB: map['cloudStorageGB'] ?? 50.0,
      emailsPerDay: map['emailsPerDay'] ?? 20,
      cleanInbox: map['cleanInbox'] ?? false,
      smartphonesOwnedLast5Years: map['smartphonesOwnedLast5Years'] ?? 2,
      computersOwnedLast5Years: map['computersOwnedLast5Years'] ?? 1,
      otherDevicesOwnedLast5Years: map['otherDevicesOwnedLast5Years'] ?? 3,
      usesEcoSearchEngine: map['usesEcoSearchEngine'] ?? false,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      lowDataModeEnabled: map['lowDataModeEnabled'] ?? false,
      headphonesUseHoursPerDay: map['headphonesUseHoursPerDay'] ?? 2,
      averageVolumeLevel: map['averageVolumeLevel'] ?? 60,
      usesNoiseCancellation: map['usesNoiseCancellation'] ?? false,
      exposureToLoudEnvironmentsHoursPerWeek: map['exposureToLoudEnvironmentsHoursPerWeek'] ?? 5,
    );
  }
  
  // Valeurs par défaut
  factory DigitalProfile.empty() {
    return const DigitalProfile();
  }
} 