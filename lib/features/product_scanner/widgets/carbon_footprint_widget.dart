import 'package:flutter/material.dart';

class CarbonFootprintWidget extends StatelessWidget {
  final double value; // valeur en kg CO2 eq
  
  const CarbonFootprintWidget({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                color: _getImpactColor(value),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Empreinte carbone',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${value.toStringAsFixed(1)} ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _getImpactColor(value),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'kg CO₂ eq',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getImpactDescription(value),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getImpactColor(double value) {
    if (value < 1.0) return Colors.green;
    if (value < 3.0) return Colors.lightGreen;
    if (value < 5.0) return Colors.amber;
    if (value < 10.0) return Colors.orange;
    return Colors.red;
  }

  String _getImpactDescription(double value) {
    if (value < 1.0) return 'Impact très faible';
    if (value < 3.0) return 'Impact faible';
    if (value < 5.0) return 'Impact moyen';
    if (value < 10.0) return 'Impact élevé';
    return 'Impact très élevé';
  }
} 