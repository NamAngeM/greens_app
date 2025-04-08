// Fichier: lib/views/community/community_impact_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/models/eco_badge.dart';
// import 'package:fl_chart/fl_chart.dart';  // Temporarily commented out
import 'package:intl/intl.dart';

class CommunityImpactView extends StatefulWidget {
  final String challengeId;

  const CommunityImpactView({Key? key, required this.challengeId}) : super(key: key);

  @override
  _CommunityImpactViewState createState() => _CommunityImpactViewState();
}

class _CommunityImpactViewState extends State<CommunityImpactView> {
  bool _isLoading = false;
  Map<String, dynamic>? _challengeImpact;
  CommunityChallenge? _challenge;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final communityController = Provider.of<CommunityController>(context, listen: false);
    
    // Récupérer les données du défi
    _challenge = communityController.challenges
        .firstWhere((c) => c.id == widget.challengeId, orElse: () => 
          CommunityChallenge(
            id: widget.challengeId,
            title: 'Défi non trouvé',
            description: 'Ce défi n\'existe pas ou a été supprimé',
            imageUrl: '',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 30)),
            participantsCount: 0,
            targetParticipants: 100,
            status: ChallengeStatus.upcoming,
            carbonPointsReward: 0,
            participants: [],
            createdAt: DateTime.now(),
            goalTarget: 0,
            category: ChallengeCategory.other
          )
        );
    
    if (_challenge != null) {
      // Récupérer l'impact du défi
      _challengeImpact = await communityController.getChallengeImpact(widget.challengeId);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_challenge?.title ?? 'Impact du défi'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _challenge == null
              ? const Center(child: Text('Défi non trouvé'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final totalCarbonSaved = _challengeImpact?['totalCarbonSaved'] ?? 0.0;
    final participantsCount = _challengeImpact?['participantsCount'] ?? 0;
    final contributionsCount = _challengeImpact?['contributionsCount'] ?? 0;
    final averageImpact = _challengeImpact?['averageImpact'] ?? 0.0;
    final completionPercentage = _challengeImpact?['completionPercentage'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec image et description
          _buildChallengeHeader(),
          
          const SizedBox(height: 24),
          
          // Statistiques d'impact
          _buildImpactStats(totalCarbonSaved, participantsCount, contributionsCount),
          
          const SizedBox(height: 24),
          
          // Graphique d'impact
          _buildImpactChart(averageImpact, completionPercentage),
          
          const SizedBox(height: 24),
          
          // Équivalences concrètes avec visualisations
          _buildVisualEquivalences(totalCarbonSaved),
          
          const SizedBox(height: 24),
          
          // Impact cumulatif de la communauté
          _buildCommunityImpact(),
          
          const SizedBox(height: 24),
          
          // Appel à l'action
          _buildCallToAction(),
        ],
      ),
    );
  }

  Widget _buildChallengeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_challenge!.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _challenge!.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          _challenge!.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _challenge!.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildImpactStats(double totalCarbonSaved, int participantsCount, int contributionsCount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact collectif',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${totalCarbonSaved.toStringAsFixed(1)} kg',
                  'CO₂ économisé',
                  Icons.eco,
                  Colors.green,
                ),
                _buildStatItem(
                  '$participantsCount',
                  'Participants',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatItem(
                  '$contributionsCount',
                  'Contributions',
                  Icons.add_task,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImpactChart(double averageImpact, double completionPercentage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression du défi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionPercentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Progression: ${completionPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Impact moyen par participant: ${averageImpact.toStringAsFixed(1)} kg CO₂',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualEquivalences(double totalCarbonSaved) {
    // Calcul des équivalences
    final treeDays = (totalCarbonSaved / 22).round(); // Un arbre absorbe environ 22kg de CO2 par an
    final carKm = (totalCarbonSaved * 6).round(); // Environ 166g de CO2 par km en voiture
    final lightBulbHours = (totalCarbonSaved * 10).round(); // Environ 100g de CO2 par heure d'ampoule

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Équivalences concrètes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEquivalenceItem(
              'Jours d\'absorption d\'un arbre',
              '$treeDays jours',
              Icons.nature,
              Colors.green,
            ),
            const Divider(),
            _buildEquivalenceItem(
              'Kilomètres en voiture',
              '$carKm km',
              Icons.directions_car,
              Colors.blue,
            ),
            const Divider(),
            _buildEquivalenceItem(
              'Heures d\'ampoule allumée',
              '$lightBulbHours heures',
              Icons.lightbulb,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquivalenceItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityImpact() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact communautaire',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'En participant à ce défi, vous rejoignez une communauté engagée pour la planète. Ensemble, nous pouvons faire une différence significative!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_challengeImpact?['recentContributions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contributions récentes',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  // Ici, vous pourriez afficher une liste des contributions récentes
                  // si vous les aviez dans votre modèle de données
                  Text(
                    'Les participants ajoutent régulièrement leurs contributions pour atteindre notre objectif commun.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToAction() {
    return Card(
      elevation: 2,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Participez au défi!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enregistrez vos actions écologiques et contribuez à l\'impact collectif de ce défi.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.challengeContribute,
                  arguments: {'challengeId': widget.challengeId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ajouter ma contribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}