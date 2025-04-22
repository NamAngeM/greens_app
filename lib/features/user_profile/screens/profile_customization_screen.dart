import 'package:flutter/material.dart';
import '../models/environmental_profile.dart';
import '../widgets/category_section.dart';
import '../widgets/interactive_slider.dart';
import '../widgets/selection_toggle.dart';

class ProfileCustomizationScreen extends StatefulWidget {
  final EnvironmentalProfile? initialProfile;
  
  const ProfileCustomizationScreen({
    Key? key,
    this.initialProfile,
  }) : super(key: key);

  @override
  State<ProfileCustomizationScreen> createState() => _ProfileCustomizationScreenState();
}

class _ProfileCustomizationScreenState extends State<ProfileCustomizationScreen> {
  late EnvironmentalProfile _profile;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4; // Transport, Alimentation, Énergie, Consommation
  
  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile ?? EnvironmentalProfile.empty();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateTransportHabits(TransportHabits newTransport) {
    setState(() {
      _profile = _profile.copyWith(transportHabits: newTransport);
    });
  }
  
  void _updateDietProfile(DietProfile newDiet) {
    setState(() {
      _profile = _profile.copyWith(dietProfile: newDiet);
    });
  }
  
  void _updateEnergyProfile(EnergyProfile newEnergy) {
    setState(() {
      _profile = _profile.copyWith(energyProfile: newEnergy);
    });
  }
  
  void _updateConsumptionProfile(ConsumptionProfile newConsumption) {
    setState(() {
      _profile = _profile.copyWith(consumptionProfile: newConsumption);
    });
  }
  
  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }
  
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _saveProfile() {
    // Calculer les empreintes carbone et eau
    final carbonFootprint = _profile.calculateTotalCarbonFootprint();
    final waterFootprint = 0.0; // TODO: Implémenter le calcul de l'empreinte eau
    final wasteGenerated = _profile.consumptionProfile.wasteGeneratedKgPerWeek * 52; // en kg/an
    
    final updatedProfile = _profile.copyWith(
      carbonFootprint: carbonFootprint,
      waterFootprint: waterFootprint,
      wasteGenerated: wasteGenerated,
    );
    
    // Sauvegarder le profil mis à jour et retourner à l'écran précédent
    Navigator.of(context).pop(updatedProfile);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnaliser mon profil écologique'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Indicateur de progression
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).primaryColor,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          // Pages principales
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildTransportPage(),
                _buildDietPage(),
                _buildEnergyPage(),
                _buildConsumptionPage(),
              ],
            ),
          ),
          
          // Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: _goToPreviousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                  )
                else
                  const SizedBox(width: 120),
                
                ElevatedButton.icon(
                  onPressed: _goToNextPage,
                  icon: Icon(_currentPage < _totalPages - 1 ? Icons.arrow_forward : Icons.check),
                  label: Text(_currentPage < _totalPages - 1 ? 'Suivant' : 'Terminer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransportPage() {
    final transport = _profile.transportHabits;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: CategorySection(
        title: 'Transport',
        iconData: Icons.directions_car,
        description: 'Comment vous déplacez-vous au quotidien ?',
        children: [
          InteractiveSlider(
            title: 'Voiture (km/semaine)',
            value: transport.carKmPerWeek,
            min: 0,
            max: 500,
            onChanged: (value) {
              _updateTransportHabits(
                transport.copyWith(carKmPerWeek: value),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          SelectionToggle(
            title: 'Type de voiture',
            options: const ['Thermique', 'Électrique'],
            selectedIndex: transport.isElectricCar ? 1 : 0,
            onSelected: (index) {
              _updateTransportHabits(
                transport.copyWith(isElectricCar: index == 1),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Transports en commun (km/semaine)',
            value: transport.publicTransportKmPerWeek,
            min: 0,
            max: 300,
            onChanged: (value) {
              _updateTransportHabits(
                transport.copyWith(publicTransportKmPerWeek: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Vélo (km/semaine)',
            value: transport.bikeKmPerWeek,
            min: 0,
            max: 200,
            onChanged: (value) {
              _updateTransportHabits(
                transport.copyWith(bikeKmPerWeek: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Marche (km/semaine)',
            value: transport.walkingKmPerWeek,
            min: 0,
            max: 100,
            onChanged: (value) {
              _updateTransportHabits(
                transport.copyWith(walkingKmPerWeek: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Nombre de vols par an',
            value: transport.flightsPerYear.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            displayValue: (val) => val.toInt().toString(),
            onChanged: (value) {
              _updateTransportHabits(
                transport.copyWith(flightsPerYear: value.toInt()),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Heures de vol par an',
            value: transport.flightHoursPerYear,
            min: 0,
            max: 100,
            onChanged: (value) {
              _updateTransportHabits(
                transport.copyWith(flightHoursPerYear: value),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDietPage() {
    final diet = _profile.dietProfile;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: CategorySection(
        title: 'Alimentation',
        iconData: Icons.restaurant,
        description: 'Quelles sont vos habitudes alimentaires ?',
        children: [
          const Text(
            'Type d\'alimentation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            children: [
              for (final dietType in DietType.values)
                ChoiceChip(
                  label: Text(_getDietTypeLabel(dietType)),
                  selected: diet.dietType == dietType,
                  onSelected: (selected) {
                    if (selected) {
                      _updateDietProfile(
                        diet.copyWith(dietType: dietType),
                      );
                    }
                  },
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (diet.dietType != DietType.vegan && diet.dietType != DietType.vegetarian)
            InteractiveSlider(
              title: 'Consommation de viande (kg/semaine)',
              value: diet.meatKgPerWeek,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (value) {
                _updateDietProfile(
                  diet.copyWith(meatKgPerWeek: value),
                );
              },
            ),
          
          if (diet.dietType != DietType.vegan)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: InteractiveSlider(
                title: 'Produits laitiers (kg/semaine)',
                value: diet.dairyKgPerWeek,
                min: 0,
                max: 5,
                divisions: 10,
                onChanged: (value) {
                  _updateDietProfile(
                    diet.copyWith(dairyKgPerWeek: value),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 24),
          
          SwitchListTile(
            title: const Text('Préférence produits locaux'),
            subtitle: const Text('Je privilégie des aliments produits localement'),
            value: diet.localProducePreference,
            onChanged: (value) {
              _updateDietProfile(
                diet.copyWith(localProducePreference: value),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          SwitchListTile(
            title: const Text('Préférence produits bio'),
            subtitle: const Text('Je privilégie des aliments issus de l\'agriculture biologique'),
            value: diet.organicPreference,
            onChanged: (value) {
              _updateDietProfile(
                diet.copyWith(organicPreference: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Aliments transformés (%)',
            value: diet.processedFoodPercentage,
            min: 0,
            max: 100,
            divisions: 10,
            displayValue: (val) => '${val.toInt()}%',
            onChanged: (value) {
              _updateDietProfile(
                diet.copyWith(processedFoodPercentage: value),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnergyPage() {
    final energy = _profile.energyProfile;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: CategorySection(
        title: 'Énergie',
        iconData: Icons.electric_bolt,
        description: 'Comment consommez-vous l\'énergie ?',
        children: [
          const Text(
            'Source de chauffage principale',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            children: [
              for (final source in EnergySource.values)
                ChoiceChip(
                  label: Text(_getEnergySourceLabel(source)),
                  selected: energy.heatingSource == source,
                  onSelected: (selected) {
                    if (selected) {
                      _updateEnergyProfile(
                        energy.copyWith(heatingSource: source),
                      );
                    }
                  },
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SwitchListTile(
            title: const Text('Électricité renouvelable'),
            subtitle: const Text('J\'utilise un fournisseur d\'électricité verte'),
            value: energy.isRenewableElectricity,
            onChanged: (value) {
              _updateEnergyProfile(
                energy.copyWith(isRenewableElectricity: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Consommation d\'électricité (kWh/mois)',
            value: energy.electricityKwhPerMonth,
            min: 50,
            max: 1000,
            divisions: 19,
            displayValue: (val) => '${val.toInt()} kWh',
            onChanged: (value) {
              _updateEnergyProfile(
                energy.copyWith(electricityKwhPerMonth: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Consommation de chauffage (kWh/mois)',
            value: energy.heatingKwhPerMonth,
            min: 0,
            max: 2000,
            divisions: 20,
            displayValue: (val) => '${val.toInt()} kWh',
            onChanged: (value) {
              _updateEnergyProfile(
                energy.copyWith(heatingKwhPerMonth: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          SwitchListTile(
            title: const Text('Appareils économes en énergie'),
            subtitle: const Text('J\'utilise principalement des appareils à haute efficacité énergétique'),
            value: energy.hasEnergyEfficientAppliances,
            onChanged: (value) {
              _updateEnergyProfile(
                energy.copyWith(hasEnergyEfficientAppliances: value),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          SwitchListTile(
            title: const Text('Bonne isolation du logement'),
            subtitle: const Text('Mon logement est bien isolé thermiquement'),
            value: energy.hasHomeInsulation,
            onChanged: (value) {
              _updateEnergyProfile(
                energy.copyWith(hasHomeInsulation: value),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildConsumptionPage() {
    final consumption = _profile.consumptionProfile;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: CategorySection(
        title: 'Consommation',
        iconData: Icons.shopping_bag,
        description: 'Quelles sont vos habitudes de consommation et de gestion des déchets ?',
        children: [
          InteractiveSlider(
            title: 'Vêtements neufs achetés par an',
            value: consumption.newClothesPerYear.toDouble(),
            min: 0,
            max: 50,
            divisions: 50,
            displayValue: (val) => val.toInt().toString(),
            onChanged: (value) {
              _updateConsumptionProfile(
                consumption.copyWith(newClothesPerYear: value.toInt()),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Appareils électroniques achetés par an',
            value: consumption.newElectronicsPerYear.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            displayValue: (val) => val.toInt().toString(),
            onChanged: (value) {
              _updateConsumptionProfile(
                consumption.copyWith(newElectronicsPerYear: value.toInt()),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Consommation de plastique (kg/semaine)',
            value: consumption.plasticConsumptionKgPerWeek,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (value) {
              _updateConsumptionProfile(
                consumption.copyWith(plasticConsumptionKgPerWeek: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Déchets générés (kg/semaine)',
            value: consumption.wasteGeneratedKgPerWeek,
            min: 0,
            max: 20,
            divisions: 20,
            onChanged: (value) {
              _updateConsumptionProfile(
                consumption.copyWith(wasteGeneratedKgPerWeek: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSlider(
            title: 'Taux de recyclage (%)',
            value: consumption.recyclingPercentage,
            min: 0,
            max: 100,
            divisions: 10,
            displayValue: (val) => '${val.toInt()}%',
            onChanged: (value) {
              _updateConsumptionProfile(
                consumption.copyWith(recyclingPercentage: value),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          SwitchListTile(
            title: const Text('Préférence pour l\'occasion'),
            subtitle: const Text('Je privilégie l\'achat de produits d\'occasion'),
            value: consumption.secondHandPreference,
            onChanged: (value) {
              _updateConsumptionProfile(
                consumption.copyWith(secondHandPreference: value),
              );
            },
          ),
        ],
      ),
    );
  }
  
  String _getDietTypeLabel(DietType type) {
    switch (type) {
      case DietType.vegan:
        return 'Végétalien';
      case DietType.vegetarian:
        return 'Végétarien';
      case DietType.pescatarian:
        return 'Pescétarien';
      case DietType.flexitarian:
        return 'Flexitarien';
      case DietType.omnivore:
        return 'Omnivore';
    }
  }
  
  String _getEnergySourceLabel(EnergySource source) {
    switch (source) {
      case EnergySource.electricity:
        return 'Électricité';
      case EnergySource.naturalGas:
        return 'Gaz naturel';
      case EnergySource.oil:
        return 'Fioul';
      case EnergySource.wood:
        return 'Bois';
      case EnergySource.heatPump:
        return 'Pompe à chaleur';
    }
  }
} 