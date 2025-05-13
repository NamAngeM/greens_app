import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class InstantImpactCalculator extends StatefulWidget {
  const InstantImpactCalculator({Key? key}) : super(key: key);
  
  @override
  _InstantImpactCalculatorState createState() => _InstantImpactCalculatorState();
}

class _InstantImpactCalculatorState extends State<InstantImpactCalculator> {
  String _selectedAction = 'transport';
  final Map<String, dynamic> _actionParameters = {};
  double? _impactResult;
  String _resultUnit = 'kg CO₂e';
  bool _isCalculating = false;
  
  // Définition des actions disponibles et leurs paramètres
  final Map<String, Map<String, dynamic>> _actionsConfig = {
    'transport': {
      'label': 'Transport',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'parameters': [
        {
          'key': 'distance',
          'label': 'Distance (km)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'vehicleType',
          'label': 'Type de véhicule',
          'type': 'dropdown',
          'options': [
            {'value': 'petrol_car', 'label': 'Voiture essence'},
            {'value': 'diesel_car', 'label': 'Voiture diesel'},
            {'value': 'electric_car', 'label': 'Voiture électrique'},
            {'value': 'bus', 'label': 'Bus'},
            {'value': 'train', 'label': 'Train'},
            {'value': 'plane', 'label': 'Avion'},
          ],
          'required': true,
        },
        {
          'key': 'passengers',
          'label': 'Nombre de passagers',
          'type': 'number',
          'required': false,
          'default': 1,
        },
      ],
      'resultUnit': 'kg CO₂e',
    },
    'energy': {
      'label': 'Consommation d\'énergie',
      'icon': Icons.electric_bolt,
      'color': Colors.orange,
      'parameters': [
        {
          'key': 'consumption',
          'label': 'Consommation (kWh)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'energyType',
          'label': 'Type d\'énergie',
          'type': 'dropdown',
          'options': [
            {'value': 'grid', 'label': 'Réseau électrique'},
            {'value': 'natural_gas', 'label': 'Gaz naturel'},
            {'value': 'renewable', 'label': 'Renouvelable'},
            {'value': 'coal', 'label': 'Charbon'},
          ],
          'required': true,
        },
      ],
      'resultUnit': 'kg CO₂e',
    },
    'food': {
      'label': 'Alimentation',
      'icon': Icons.restaurant,
      'color': Colors.green,
      'parameters': [
        {
          'key': 'foodType',
          'label': 'Type d\'aliment',
          'type': 'dropdown',
          'options': [
            {'value': 'beef', 'label': 'Bœuf'},
            {'value': 'chicken', 'label': 'Poulet'},
            {'value': 'fish', 'label': 'Poisson'},
            {'value': 'vegetables', 'label': 'Légumes'},
            {'value': 'fruits', 'label': 'Fruits'},
            {'value': 'dairy', 'label': 'Produits laitiers'},
          ],
          'required': true,
        },
        {
          'key': 'quantity',
          'label': 'Quantité (kg)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'isLocal',
          'label': 'Production locale',
          'type': 'boolean',
          'required': false,
          'default': false,
        },
      ],
      'resultUnit': 'kg CO₂e',
    },
    'waste': {
      'label': 'Déchets',
      'icon': Icons.delete,
      'color': Colors.red,
      'parameters': [
        {
          'key': 'wasteType',
          'label': 'Type de déchet',
          'type': 'dropdown',
          'options': [
            {'value': 'plastic', 'label': 'Plastique'},
            {'value': 'paper', 'label': 'Papier'},
            {'value': 'glass', 'label': 'Verre'},
            {'value': 'metal', 'label': 'Métal'},
            {'value': 'organic', 'label': 'Organique'},
            {'value': 'electronic', 'label': 'Électronique'},
          ],
          'required': true,
        },
        {
          'key': 'quantity',
          'label': 'Quantité (kg)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'isRecycled',
          'label': 'Recyclé',
          'type': 'boolean',
          'required': false,
          'default': false,
        },
      ],
      'resultUnit': 'kg CO₂e',
    },
    'water': {
      'label': 'Eau',
      'icon': Icons.water_drop,
      'color': Colors.lightBlue,
      'parameters': [
        {
          'key': 'volume',
          'label': 'Volume (litres)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'temperature',
          'label': 'Température',
          'type': 'dropdown',
          'options': [
            {'value': 'cold', 'label': 'Froide'},
            {'value': 'warm', 'label': 'Tiède'},
            {'value': 'hot', 'label': 'Chaude'},
          ],
          'required': true,
        },
      ],
      'resultUnit': 'litres',
    },
  };
  
  @override
  void initState() {
    super.initState();
    // Initialiser les paramètres par défaut pour l'action sélectionnée
    _initializeParameters();
  }
  
  void _initializeParameters() {
    _actionParameters.clear();
    
    // Préremplir avec les valeurs par défaut
    final parameters = _actionsConfig[_selectedAction]?['parameters'] as List<dynamic>? ?? [];
    for (var param in parameters) {
      if (param['default'] != null) {
        _actionParameters[param['key']] = param['default'];
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculateur d\'impact instantané',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionSelector(),
            const SizedBox(height: 16),
            _buildParameterInputs(),
            const SizedBox(height: 20),
            _buildCalculateButton(),
            if (_impactResult != null) const SizedBox(height: 16),
            if (_impactResult != null) _buildResultDisplay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionSelector() {
    return Container(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _actionsConfig.entries.map((entry) {
          final isSelected = entry.key == _selectedAction;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAction = entry.key;
                _impactResult = null;
                _initializeParameters();
                _resultUnit = entry.value['resultUnit'] ?? 'kg CO₂e';
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (entry.value['color'] as Color).withOpacity(0.2) 
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected 
                      ? entry.value['color'] as Color 
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    entry.value['icon'] as IconData,
                    color: isSelected 
                        ? entry.value['color'] as Color 
                        : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.value['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.textColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildParameterInputs() {
    final parameters = _actionsConfig[_selectedAction]?['parameters'] as List<dynamic>? ?? [];
    
    if (parameters.isEmpty) {
      return const Center(
        child: Text('Aucun paramètre disponible pour cette action'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parameters.map<Widget>((param) {
        final key = param['key'] as String;
        final label = param['label'] as String;
        final type = param['type'] as String;
        
        switch (type) {
          case 'number':
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _actionParameters[key] = double.tryParse(value) ?? 0;
                    });
                  } else {
                    setState(() {
                      _actionParameters.remove(key);
                    });
                  }
                },
              ),
            );
            
          case 'dropdown':
            final options = param['options'] as List<dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: options.map<DropdownMenuItem<String>>((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'] as String,
                    child: Text(option['label'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _actionParameters[key] = value;
                  });
                },
                value: _actionParameters[key] as String?,
              ),
            );
            
          case 'boolean':
            bool isChecked = _actionParameters[key] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        _actionParameters[key] = value;
                      });
                    },
                  ),
                  Text(label),
                ],
              ),
            );
            
          default:
            return const SizedBox.shrink();
        }
      }).toList(),
    );
  }
  
  Widget _buildCalculateButton() {
    final parameters = _actionsConfig[_selectedAction]?['parameters'] as List<dynamic>? ?? [];
    
    // Vérifier si tous les paramètres requis sont remplis
    bool canCalculate = true;
    for (var param in parameters) {
      if (param['required'] == true) {
        final key = param['key'] as String;
        if (!_actionParameters.containsKey(key) || _actionParameters[key] == null) {
          canCalculate = false;
          break;
        }
      }
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canCalculate && !_isCalculating ? _calculateImpact : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isCalculating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Text(
                'Calculer l\'impact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
  
  Widget _buildResultDisplay() {
    Color resultColor = _getResultColor(_impactResult!);
    String impactLevel = _getImpactLevel(_impactResult!);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: resultColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Impact calculé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _impactResult!.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _resultUnit,
                style: TextStyle(
                  fontSize: 16,
                  color: resultColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            impactLevel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildImpactTips(),
        ],
      ),
    );
  }
  
  Widget _buildImpactTips() {
    // Les conseils dépendant du type d'action et du niveau d'impact
    Map<String, List<String>> tips = {
      'transport': [
        'Privilégiez le vélo ou la marche pour les courts trajets',
        'Optez pour les transports en commun quand c\'est possible',
        'Pratiquez le covoiturage pour réduire votre empreinte',
      ],
      'energy': [
        'Éteignez les appareils non utilisés plutôt que de les laisser en veille',
        'Utilisez des appareils économes en énergie (classe A+++)',
        'Envisagez de passer à l\'énergie verte pour votre domicile',
      ],
      'food': [
        'Privilégiez les aliments locaux et de saison',
        'Réduisez votre consommation de viande rouge',
        'Évitez le gaspillage alimentaire',
      ],
      'waste': [
        'Triez vos déchets pour favoriser le recyclage',
        'Privilégiez les produits avec peu d\'emballage',
        'Compostez vos déchets organiques si possible',
      ],
      'water': [
        'Prenez des douches courtes plutôt que des bains',
        'Récupérez l\'eau de pluie pour arroser vos plantes',
        'Réparez rapidement les fuites d\'eau',
      ],
    };
    
    List<String> actionTips = tips[_selectedAction] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment réduire cet impact:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...actionTips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.eco,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  // Calcul de l'impact en fonction des paramètres
  Future<void> _calculateImpact() async {
    setState(() {
      _isCalculating = true;
    });
    
    // Simuler un calcul qui prend un peu de temps
    await Future.delayed(const Duration(milliseconds: 800));
    
    double result = 0;
    
    // Calculs simplifiés pour chaque type d'action
    switch (_selectedAction) {
      case 'transport':
        final distance = _actionParameters['distance'] as double? ?? 0;
        final vehicleType = _actionParameters['vehicleType'] as String? ?? 'petrol_car';
        final passengers = _actionParameters['passengers'] as double? ?? 1;
        
        // Facteurs d'émission simplifiés en kg CO2e/km
        Map<String, double> emissionFactors = {
          'petrol_car': 0.192,
          'diesel_car': 0.171,
          'electric_car': 0.053,
          'bus': 0.105,
          'train': 0.041,
          'plane': 0.255,
        };
        
        result = distance * (emissionFactors[vehicleType] ?? 0.1);
        
        // Si c'est une voiture et qu'il y a plus d'un passager, on divise l'impact
        if (['petrol_car', 'diesel_car', 'electric_car'].contains(vehicleType) && passengers > 1) {
          result = result / passengers;
        }
        break;
        
      case 'energy':
        final consumption = _actionParameters['consumption'] as double? ?? 0;
        final energyType = _actionParameters['energyType'] as String? ?? 'grid';
        
        // Facteurs d'émission simplifiés en kg CO2e/kWh
        Map<String, double> emissionFactors = {
          'grid': 0.216,
          'natural_gas': 0.198,
          'renewable': 0.025,
          'coal': 0.340,
        };
        
        result = consumption * (emissionFactors[energyType] ?? 0.1);
        break;
        
      case 'food':
        final foodType = _actionParameters['foodType'] as String? ?? 'vegetables';
        final quantity = _actionParameters['quantity'] as double? ?? 0;
        final isLocal = _actionParameters['isLocal'] as bool? ?? false;
        
        // Facteurs d'émission simplifiés en kg CO2e/kg
        Map<String, double> emissionFactors = {
          'beef': 27.0,
          'chicken': 6.9,
          'fish': 5.4,
          'vegetables': 2.0,
          'fruits': 1.1,
          'dairy': 13.5,
        };
        
        result = quantity * (emissionFactors[foodType] ?? 1.0);
        
        // Réduction pour les produits locaux
        if (isLocal) {
          result *= 0.8; // 20% de réduction
        }
        break;
        
      case 'waste':
        final wasteType = _actionParameters['wasteType'] as String? ?? 'plastic';
        final quantity = _actionParameters['quantity'] as double? ?? 0;
        final isRecycled = _actionParameters['isRecycled'] as bool? ?? false;
        
        // Facteurs d'émission simplifiés en kg CO2e/kg
        Map<String, double> emissionFactors = {
          'plastic': 6.0,
          'paper': 1.1,
          'glass': 0.9,
          'metal': 4.5,
          'organic': 0.8,
          'electronic': 20.0,
        };
        
        result = quantity * (emissionFactors[wasteType] ?? 1.0);
        
        // Réduction pour le recyclage
        if (isRecycled) {
          result *= 0.3; // 70% de réduction
        }
        break;
        
      case 'water':
        final volume = _actionParameters['volume'] as double? ?? 0;
        final temperature = _actionParameters['temperature'] as String? ?? 'cold';
        
        // Conversion en équivalent CO2, mais nous gardons l'unité en litres d'eau
        result = volume;
        
        // Facteur multiplicateur pour l'eau chaude (énergie nécessaire pour chauffer)
        if (temperature == 'warm') {
          result *= 1.5; // Facteur simplifié pour l'eau tiède
        } else if (temperature == 'hot') {
          result *= 2.5; // Facteur simplifié pour l'eau chaude
        }
        break;
        
      default:
        result = 0;
    }
    
    setState(() {
      _impactResult = result;
      _isCalculating = false;
    });
  }
  
  // Déterminer la couleur en fonction du résultat
  Color _getResultColor(double result) {
    // Les seuils dépendent du type d'action
    Map<String, List<double>> thresholds = {
      'transport': [5, 20, 50],
      'energy': [5, 15, 30],
      'food': [10, 30, 60],
      'waste': [5, 15, 30],
      'water': [50, 150, 300],
    };
    
    List<double> actionThresholds = thresholds[_selectedAction] ?? [5, 20, 50];
    
    if (result < actionThresholds[0]) {
      return Colors.green;
    } else if (result < actionThresholds[1]) {
      return Colors.orange;
    } else if (result < actionThresholds[2]) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
  
  // Obtenir une description de l'impact
  String _getImpactLevel(double result) {
    // Les seuils dépendent du type d'action
    Map<String, List<double>> thresholds = {
      'transport': [5, 20, 50],
      'energy': [5, 15, 30],
      'food': [10, 30, 60],
      'waste': [5, 15, 30],
      'water': [50, 150, 300],
    };
    
    List<double> actionThresholds = thresholds[_selectedAction] ?? [5, 20, 50];
    
    if (result < actionThresholds[0]) {
      return 'Impact faible - Excellent !';
    } else if (result < actionThresholds[1]) {
      return 'Impact modéré - Peut être amélioré';
    } else if (result < actionThresholds[2]) {
      return 'Impact élevé - Améliorations nécessaires';
    } else {
      return 'Impact très élevé - Action urgente recommandée';
    }
  }
} 