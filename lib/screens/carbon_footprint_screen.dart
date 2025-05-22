import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/carbon_footprint.dart';
import '../services/carbon_footprint_service.dart';
import 'package:provider/provider.dart';

class CarbonFootprintScreen extends StatelessWidget {
  final CarbonFootprintService _footprintService = CarbonFootprintService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Empreinte Carbone'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Tableau de bord'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DashboardTab(),
            _HistoryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEntryDialog(context),
          child: Icon(Icons.add),
          tooltip: 'Ajouter une entrée',
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une entrée'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Transport (kg CO2)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Alimentation (kg CO2)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Énergie (kg CO2)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Déchets (kg CO2)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement entry creation
              Navigator.pop(context);
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<CarbonFootprintService>().getFootprintStatistics('userId'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Une erreur est survenue'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(stats),
              SizedBox(height: 16.0),
              _buildEmissionsChart(),
              SizedBox(height: 16.0),
              _buildRecommendationsCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            _buildStatRow('Moyenne', '${stats['average'].toStringAsFixed(1)} kg CO2'),
            _buildStatRow('Plus élevé', '${stats['highest'].toStringAsFixed(1)} kg CO2'),
            _buildStatRow('Plus bas', '${stats['lowest'].toStringAsFixed(1)} kg CO2'),
            _buildStatRow(
              'Tendance',
              stats['trend'] > 0 ? '↑ Augmentation' : '↓ Diminution',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmissionsChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Émissions par catégorie',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'Transport',
                      color: Colors.blue,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'Alimentation',
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'Énergie',
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: 'Déchets',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommandations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            _buildRecommendationItem(
              'Utilisez les transports en commun',
              Icons.directions_bus,
            ),
            _buildRecommendationItem(
              'Mangez local et de saison',
              Icons.restaurant,
            ),
            _buildRecommendationItem(
              'Réduisez votre consommation d\'énergie',
              Icons.power,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 16.0),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CarbonFootprint>>(
      stream: context.read<CarbonFootprintService>().getUserFootprintHistory('userId'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Une erreur est survenue'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final footprints = snapshot.data!;
        if (footprints.isEmpty) {
          return Center(child: Text('Aucune donnée disponible'));
        }

        return ListView.builder(
          itemCount: footprints.length,
          itemBuilder: (context, index) {
            final footprint = footprints[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                title: Text('${footprint.date.day}/${footprint.date.month}/${footprint.date.year}'),
                subtitle: Text('Total: ${footprint.totalEmissions.toStringAsFixed(1)} kg CO2'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show detailed view
                },
              ),
            );
          },
        );
      },
    );
  }
} 