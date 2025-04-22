import 'package:flutter/material.dart';
import 'dart:math' as math;

class DigitalFootprintWidget extends StatelessWidget {
  final double digitalEmissions;
  final int dataUsage;
  final String serverLocation;

  const DigitalFootprintWidget({
    Key? key,
    required this.digitalEmissions,
    required this.dataUsage, 
    required this.serverLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: _getEmissionsColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Empreinte numérique',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${digitalEmissions.toStringAsFixed(2)} kg CO₂e',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getEmissionsColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataUsageInfo(context),
            const SizedBox(height: 12),
            _buildDigitalImpactDescription(),
            const SizedBox(height: 8),
            _buildEcoTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUsageInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utilisation des données',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              _formatDataSize(dataUsage),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serveurs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              serverLocation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitalImpactDescription() {
    String impactDescription;
    if (digitalEmissions <= 0.2) {
      impactDescription = 'Impact numérique faible';
    } else if (digitalEmissions <= 0.5) {
      impactDescription = 'Impact numérique modéré';
    } else {
      impactDescription = 'Impact numérique élevé';
    }

    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          impactDescription,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildEcoTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.eco_outlined,
            color: Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getEcoTip(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.green[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmissionsColor() {
    if (digitalEmissions <= 0.2) {
      return Colors.green;
    } else if (digitalEmissions <= 0.5) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  String _formatDataSize(int kilobytes) {
    if (kilobytes < 1000) {
      return '$kilobytes KB';
    } else {
      double megabytes = kilobytes / 1000;
      return '${megabytes.toStringAsFixed(1)} MB';
    }
  }

  String _getEcoTip() {
    final List<String> tips = [
      'Privilégiez les produits dont les sites web utilisent des hébergeurs verts.',
      'Les produits avec des fiches digitales plus légères ont généralement une empreinte numérique réduite.',
      'Les entreprises qui hébergent leurs données en Europe respectent souvent des normes environnementales plus strictes.',
      'Recherchez des marques qui communiquent sur leur stratégie de réduction de pollution numérique.',
    ];
    
    return tips[math.Random().nextInt(tips.length)];
  }
} 