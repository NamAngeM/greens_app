import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math' as math;

/// Widget pour visualiser l'impact carbone de manière attrayante
class CarbonImpactVisualization extends StatelessWidget {
  final Map<String, dynamic> carbonData;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showDetailedBreakdown;
  final bool showComparisons;
  final VoidCallback? onLearnMorePressed;

  const CarbonImpactVisualization({
    Key? key,
    required this.carbonData,
    this.primaryColor = const Color(0xFF4CAF50),
    this.secondaryColor = const Color(0xFF2E7D32),
    this.showDetailedBreakdown = true,
    this.showComparisons = true,
    this.onLearnMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildMainIndicator(context),
            if (showDetailedBreakdown) ...[
              const SizedBox(height: 24),
              _buildDetailedBreakdown(context),
            ],
            if (showComparisons) ...[
              const SizedBox(height: 24),
              _buildComparisons(context),
            ],
            const SizedBox(height: 16),
            _buildRecommendations(context),
            if (onLearnMorePressed != null) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: onLearnMorePressed,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('En savoir plus sur votre impact'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.eco,
          color: primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          'Votre Impact Carbone',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildMainIndicator(BuildContext context) {
    final totalScore = carbonData['totalScore'] as double? ?? 12.0;
    final tonnesPerYear = carbonData['carbonTonnesPerYear'] as double? ?? 4.4;
    
    // Calculer le score sur une échelle de 0 à 1 (où 0 est le meilleur)
    // Basé sur les objectifs écologiques (1 tonne CO2 par an est idéal, 15 tonnes est mauvais)
    final scorePercentage = math.min(1.0, math.max(0.0, (tonnesPerYear - 1) / 14));
    
    // Inverser pour l'indicateur circulaire (1 est le meilleur)
    final circularPercentage = 1 - scorePercentage;
    
    // Déterminer la couleur en fonction du score
    Color scoreColor;
    String scoreLabel;
    
    if (scorePercentage < 0.3) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent';
    } else if (scorePercentage < 0.5) {
      scoreColor = Colors.lightGreen;
      scoreLabel = 'Bon';
    } else if (scorePercentage < 0.7) {
      scoreColor = Colors.amber;
      scoreLabel = 'Moyen';
    } else if (scorePercentage < 0.9) {
      scoreColor = Colors.orange;
      scoreLabel = 'Élevé';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Critique';
    }
    
    return Center(
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            percent: circularPercentage,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${tonnesPerYear.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                ),
                Text(
                  'tonnes CO₂/an',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            backgroundColor: Colors.grey[200]!,
            progressColor: scoreColor,
            animation: true,
            animationDuration: 1000,
            footer: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'Impact $scoreLabel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "L'empreinte carbone moyenne en France est de 4,4 tonnes CO₂/an",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(BuildContext context) {
    final breakdown = carbonData['detailedBreakdown'] as Map<String, dynamic>? ?? {};
    
    final transport = breakdown['transport'] as double? ?? 4.0;
    final alimentation = breakdown['alimentation'] as double? ?? 3.0;
    final energie = breakdown['energie'] as double? ?? 3.0;
    final consommation = breakdown['consommation'] as double? ?? 2.0;
    
    final totalDaily = transport + alimentation + energie + consommation;
    
    // Convertir en pourcentages
    final transportPerc = transport / totalDaily;
    final alimentationPerc = alimentation / totalDaily;
    final energiePerc = energie / totalDaily;
    final consommationPerc = consommation / totalDaily;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartition de votre empreinte',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildProgressBar(
          context, 
          'Transport', 
          transportPerc, 
          Icons.directions_car, 
          Colors.blue,
          '${(transportPerc * 100).round()}%',
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context, 
          'Alimentation', 
          alimentationPerc, 
          Icons.restaurant, 
          Colors.orange,
          '${(alimentationPerc * 100).round()}%',
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context, 
          'Énergie', 
          energiePerc, 
          Icons.bolt, 
          Colors.amber,
          '${(energiePerc * 100).round()}%',
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context, 
          'Consommation', 
          consommationPerc, 
          Icons.shopping_bag, 
          Colors.purple,
          '${(consommationPerc * 100).round()}%',
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context, 
    String label, 
    double percentage, 
    IconData icon, 
    Color color,
    String valueLabel,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    valueLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearPercentIndicator(
                lineHeight: 10.0,
                percent: percentage,
                backgroundColor: Colors.grey[200],
                progressColor: color,
                barRadius: const Radius.circular(10),
                animation: true,
                animationDuration: 1000,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisons(BuildContext context) {
    final comparisons = carbonData['comparisons'] as Map<String, dynamic>? ?? {};
    
    final vsNational = comparisons['vs_moyenne_nationale'] as double? ?? 1.0;
    final vs2030 = comparisons['vs_objectif_2030'] as double? ?? 1.76;
    final arbres = comparisons['equivalent_arbres'] as int? ?? 220;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparaisons',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildComparisonItem(
              context,
              vsNational.toStringAsFixed(1) + 'x',
              'la moyenne nationale',
              Icons.people,
              vsNational < 0.8 ? Colors.green : (vsNational > 1.2 ? Colors.red : Colors.amber),
            ),
            const SizedBox(width: 16),
            _buildComparisonItem(
              context,
              vs2030.toStringAsFixed(1) + 'x',
              'l\'objectif 2030',
              Icons.calendar_today,
              vs2030 < 1.0 ? Colors.green : (vs2030 > 2.0 ? Colors.red : Colors.amber),
            ),
            const SizedBox(width: 16),
            _buildComparisonItem(
              context,
              arbres.toString(),
              'arbres nécessaires',
              Icons.forest,
              arbres < 150 ? Colors.green : (arbres > 300 ? Colors.red : Colors.amber),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final recommendations = carbonData['recommendations'] as List<dynamic>? ?? [];
    
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommandations personnalisées',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...recommendations.take(3).map((recommendation) => _buildRecommendationItem(context, recommendation)),
        if (recommendations.length > 3)
          Center(
            child: TextButton(
              onPressed: onLearnMorePressed,
              child: const Text('Voir toutes les recommandations'),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendationItem(BuildContext context, String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 