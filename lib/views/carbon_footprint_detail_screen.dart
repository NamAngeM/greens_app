import 'package:flutter/material.dart';
import '../services/eco_activity_service.dart';
import '../models/eco_activity.dart';

class CarbonFootprintDetailScreen extends StatefulWidget {
  final ActivityType activityType;

  const CarbonFootprintDetailScreen({
    Key? key,
    required this.activityType,
  }) : super(key: key);

  @override
  _CarbonFootprintDetailScreenState createState() => _CarbonFootprintDetailScreenState();
}

class _CarbonFootprintDetailScreenState extends State<CarbonFootprintDetailScreen> {
  final EcoActivityService _ecoActivityService = EcoActivityService();
  String userId = 'current_user_id'; // À remplacer par l'ID de l'utilisateur connecté

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getActivityTypeTitle()),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: _buildActivityList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getActivityTypeTitle() {
    switch (widget.activityType) {
      case ActivityType.transport:
        return 'Transport';
      case ActivityType.food:
        return 'Alimentation';
      case ActivityType.energy:
        return 'Énergie';
      case ActivityType.waste:
        return 'Déchets';
      case ActivityType.shopping:
        return 'Shopping';
    }
  }

  Widget _buildSummaryCard() {
    return FutureBuilder<double>(
      future: _calculateTotalImpact(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalImpact = snapshot.data ?? 0.0;
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Impact Total',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalImpact.toStringAsFixed(2)} kg CO2',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildImpactChart(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImpactChart() {
    // TODO: Implémenter un graphique d'évolution de l'impact
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Graphique d\'évolution'),
      ),
    );
  }

  Widget _buildActivityList() {
    return FutureBuilder<List<EcoActivity>>(
      future: _ecoActivityService.getUserActivities(userId, type: widget.activityType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final activities = snapshot.data ?? [];
        if (activities.isEmpty) {
          return const Center(
            child: Text('Aucune activité enregistrée'),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityCard(activity);
          },
        );
      },
    );
  }

  Widget _buildActivityCard(EcoActivity activity) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(activity.description),
        subtitle: Text(
          '${activity.date.toString().split(' ')[0]} - ${activity.carbonImpact.toStringAsFixed(2)} kg CO2',
        ),
        trailing: activity.isVerified
            ? const Icon(Icons.verified, color: Colors.green)
            : const Icon(Icons.pending, color: Colors.orange),
        onTap: () => _showActivityDetails(activity),
      ),
    );
  }

  Future<double> _calculateTotalImpact() async {
    final activities = await _ecoActivityService.getUserActivities(
      userId,
      type: widget.activityType,
    );
    return activities.fold(0.0, (sum, activity) => sum + activity.carbonImpact);
  }

  void _showAddActivityDialog() {
    // TODO: Implémenter le dialogue d'ajout d'activité
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une activité - ${_getActivityTypeTitle()}'),
        content: const Text('Formulaire d\'ajout d\'activité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la sauvegarde
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(EcoActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de l\'activité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${activity.description}'),
            const SizedBox(height: 8),
            Text('Date: ${activity.date.toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            Text('Impact: ${activity.carbonImpact.toStringAsFixed(2)} kg CO2'),
            const SizedBox(height: 8),
            Text('Statut: ${activity.isVerified ? 'Vérifié' : 'En attente de vérification'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
} 