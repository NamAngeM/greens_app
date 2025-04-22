import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/carbon_calculator_service.dart';
import '../widgets/carbon_footprint_chart.dart';

class EcoImpactScreen extends StatefulWidget {
  const EcoImpactScreen({Key? key}) : super(key: key);

  @override
  State<EcoImpactScreen> createState() => _EcoImpactScreenState();
}

class _EcoImpactScreenState extends State<EcoImpactScreen> {
  late final CarbonCalculatorService _calculatorService;
  late final UserProfileModel _userProfile;
  bool _showComparison = false;
  bool _showNationalAverage = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculatorService = CarbonCalculatorService();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Simuler le chargement du profil utilisateur
    await Future.delayed(const Duration(seconds: 1));
    
    // Dans une application réelle, on chargerait le profil depuis une BDD
    _userProfile = UserProfileModel(
      id: '1',
      name: 'Utilisateur Test',
      // Données fictives pour l'exemple
      footprintByCategory: {
        'Transport': 1.8,
        'Alimentation': 2.1,
        'Logement': 1.5,
        'Consommation': 2.3,
      },
      totalCarbonFootprint: 7.7, // Somme des valeurs ci-dessus
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Impact Écologique'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final ecoLevel = _calculatorService.determineEcoLevel(_userProfile);
    final comparisonWithNational = _calculatorService.compareWithNationalAverage(_userProfile);
    final comparisonWithGoal = _calculatorService.compareWithClimateGoal(_userProfile);
    final recommendations = _calculatorService.generateRecommendations(_userProfile);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(ecoLevel),
          const SizedBox(height: 24),
          CarbonFootprintChart(
            userProfile: _userProfile,
            showComparison: _showComparison,
            showNationalAverage: _showNationalAverage,
          ),
          const SizedBox(height: 24),
          _buildChartControls(),
          const SizedBox(height: 24),
          _buildComparisonSection(comparisonWithNational, comparisonWithGoal),
          const SizedBox(height: 24),
          _buildRecommendationsSection(recommendations),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String ecoLevel) {
    final Map<String, Color> levelColors = {
      'Excellent': Colors.green,
      'Bon': Colors.lightGreen,
      'Moyen': Colors.amber,
      'À améliorer': Colors.orange,
      'Préoccupant': Colors.red,
    };
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Niveau écologique',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: levelColors[ecoLevel] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    ecoLevel,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Empreinte carbone totale: ${_userProfile.totalCarbonFootprint.toStringAsFixed(1)} tonnes CO₂/an',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options d\'affichage',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Afficher les comparaisons'),
              value: _showComparison,
              onChanged: (value) {
                setState(() {
                  _showComparison = value;
                });
              },
            ),
            if (_showComparison)
              SwitchListTile(
                title: const Text('Comparer avec la moyenne nationale'),
                subtitle: const Text('Sinon, comparer avec les objectifs durables'),
                value: _showNationalAverage,
                onChanged: (value) {
                  setState(() {
                    _showNationalAverage = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(String nationalComparison, String goalComparison) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparaisons',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Par rapport à la moyenne nationale'),
              subtitle: Text(nationalComparison),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Par rapport aux objectifs climatiques'),
              subtitle: Text(goalComparison),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(List<Recommendation> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommandations personnalisées',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => _buildRecommendationItem(recommendation)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Recommendation recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(
          _getCategoryIcon(recommendation.category),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(recommendation.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.description),
            const SizedBox(height: 4),
            Text(
              'Impact potentiel: réduction de ${recommendation.potentialReduction.toStringAsFixed(1)} tonnes CO₂/an',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transport':
        return Icons.directions_car;
      case 'Alimentation':
        return Icons.restaurant;
      case 'Logement':
        return Icons.home;
      case 'Consommation':
        return Icons.shopping_cart;
      default:
        return Icons.eco;
    }
  }
} 