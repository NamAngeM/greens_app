import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/services/eco_metrics_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Vue qui explique la méthodologie de calcul d'impact écologique
class MethodologyView extends StatelessWidget {
  const MethodologyView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final metricsService = EcoMetricsService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Méthodologie'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notre approche scientifique',
              style: AppStyles.heading1,
            ),
            const SizedBox(height: 16),
            Text(
              'Chez GreenMinds, nous basons nos calculs d\'impact environnemental sur des données scientifiques rigoureuses et des méthodologies reconnues internationalement.',
              style: AppStyles.bodyText,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facteurs d\'émission',
                      style: AppStyles.heading2,
                    ),
                    const SizedBox(height: 16),
                    MarkdownBody(
                      data: metricsService.getMethodologyExplanation(),
                      styleSheet: MarkdownStyleSheet(
                        h1: AppStyles.heading2,
                        h2: AppStyles.heading3,
                        p: AppStyles.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Équivalences concrètes',
                      style: AppStyles.heading2,
                    ),
                    const SizedBox(height: 16),
                    _buildEquivalenceItem(
                      context,
                      '1 kg de CO2e',
                      'Équivaut à 5,2 km parcourus en voiture',
                      Icons.directions_car,
                    ),
                    _buildEquivalenceItem(
                      context,
                      '10 kg de CO2e',
                      'Équivaut à un arbre qui absorbe du CO2 pendant 5 mois',
                      Icons.nature,
                    ),
                    _buildEquivalenceItem(
                      context,
                      '25 kg de CO2e',
                      'Équivaut à la production de 6,25 kg de viande de bœuf',
                      Icons.restaurant,
                    ),
                    _buildEquivalenceItem(
                      context,
                      '100 kg de CO2e',
                      'Équivaut à un vol Paris-Londres aller simple',
                      Icons.flight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nos sources scientifiques',
                      style: AppStyles.heading2,
                    ),
                    const SizedBox(height: 16),
                    _buildSourceItem(
                      'ADEME',
                      'Agence de l\'environnement et de la maîtrise de l\'énergie',
                      '[https://www.ademe.fr](https://www.ademe.fr)',
                    ),
                    _buildSourceItem(
                      'IPCC',
                      'Groupe d\'experts intergouvernemental sur l\'évolution du climat',
                      '[https://www.ipcc.ch](https://www.ipcc.ch)',
                    ),
                    _buildSourceItem(
                      'FAO',
                      'Organisation des Nations unies pour l\'alimentation et l\'agriculture',
                      '[https://www.fao.org](https://www.fao.org)',
                    ),
                    _buildSourceItem(
                      'EPA',
                      'Agence américaine de protection de l\'environnement',
                      '[https://www.epa.gov](https://www.epa.gov)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('J\'ai compris'),
                style: AppStyles.primaryButtonStyle,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquivalenceItem(BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSourceItem(String name, String description, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppStyles.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppStyles.bodyText,
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              // Ouvrir l'URL
            },
            child: Text(
              url,
              style: AppStyles.bodyText.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}