import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';

class DigitalCarbonChart extends StatelessWidget {
  final CarbonFootprintModel footprint;
  final bool showDetails;

  const DigitalCarbonChart({
    Key? key,
    required this.footprint,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartition de votre empreinte numérique',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Impact total: ${footprint.digitalScore.toStringAsFixed(2)} kg CO₂e',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.5,
          child: _buildChart(),
        ),
        if (showDetails) ...[
          const SizedBox(height: 24),
          _buildDigitalImpactDetails(),
        ],
      ],
    );
  }

  Widget _buildChart() {
    // Récupérer les détails de l'empreinte numérique depuis le modèle
    final details = footprint.details ?? {};
    final digitalDetails = details['digital'] as Map<String, dynamic>? ?? {};
    
    // Extraire les valeurs pour chaque catégorie
    final streamingEmissions = digitalDetails['streamingEmissions'] as double? ?? 0.0;
    final emailEmissions = digitalDetails['emailEmissions'] as double? ?? 0.0;
    final storageEmissions = digitalDetails['storageEmissions'] as double? ?? 0.0;
    final deviceEmissions = digitalDetails['deviceEmissions'] as double? ?? 0.0;
    
    // Calculer les pourcentages
    final total = streamingEmissions + emailEmissions + storageEmissions + deviceEmissions;
    final streamingPercent = total > 0 ? (streamingEmissions / total) * 100 : 0.0;
    final emailPercent = total > 0 ? (emailEmissions / total) * 100 : 0.0;
    final storagePercent = total > 0 ? (storageEmissions / total) * 100 : 0.0;
    final devicePercent = total > 0 ? (deviceEmissions / total) * 100 : 0.0;
    
    // Créer les sections du graphique
    final sections = [
      PieChartSectionData(
        color: AppColors.primaryColor,
        value: streamingPercent,
        title: '${streamingPercent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppColors.secondaryColor,
        value: emailPercent,
        title: '${emailPercent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.amber,
        value: storagePercent,
        title: '${storagePercent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: devicePercent,
        title: '${devicePercent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
    
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Gérer les interactions avec le graphique si nécessaire
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Streaming', AppColors.primaryColor),
        _buildLegendItem('Emails', AppColors.secondaryColor),
        _buildLegendItem('Stockage', Colors.amber),
        _buildLegendItem('Appareils', Colors.purple),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalImpactDetails() {
    // Récupérer les détails de l'empreinte numérique depuis le modèle
    final details = footprint.details ?? {};
    final digitalDetails = details['digital'] as Map<String, dynamic>? ?? {};
    
    // Extraire les valeurs pour chaque catégorie
    final streamingEmissions = digitalDetails['streamingEmissions'] as double? ?? 0.0;
    final emailEmissions = digitalDetails['emailEmissions'] as double? ?? 0.0;
    final storageEmissions = digitalDetails['storageEmissions'] as double? ?? 0.0;
    final deviceEmissions = digitalDetails['deviceEmissions'] as double? ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détail de votre empreinte numérique',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailItem('Streaming et médias', streamingEmissions, AppColors.primaryColor),
        _buildDetailItem('Emails et messagerie', emailEmissions, AppColors.secondaryColor),
        _buildDetailItem('Stockage cloud', storageEmissions, Colors.amber),
        _buildDetailItem('Utilisation des appareils', deviceEmissions, Colors.purple),
        const SizedBox(height: 16),
        _buildEquivalenceCard(),
      ],
    );
  }

  Widget _buildDetailItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColor,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} kg CO₂e',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalenceCard() {
    // Calculer des équivalences concrètes pour rendre l'impact plus tangible
    final digitalScore = footprint.digitalScore;
    String equivalence;
    
    if (digitalScore < 1) {
      equivalence = '${(digitalScore * 5).toStringAsFixed(1)} km en voiture';
    } else if (digitalScore < 5) {
      equivalence = '${(digitalScore * 3).toStringAsFixed(1)} km en voiture';
    } else if (digitalScore < 20) {
      equivalence = '${(digitalScore / 5).toStringAsFixed(1)} jours de chauffage d\'une maison';
    } else {
      equivalence = '${(digitalScore / 100).toStringAsFixed(2)} vols Paris-Londres';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Équivalence de votre empreinte numérique',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre empreinte numérique équivaut à environ $equivalence',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
