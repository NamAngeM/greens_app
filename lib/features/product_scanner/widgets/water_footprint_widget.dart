import 'package:flutter/material.dart';

class WaterFootprintWidget extends StatelessWidget {
  final double value; // valeur en litres d'eau
  
  const WaterFootprintWidget({Key? key, required this.value}) : super(key: key);

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
                Icons.water_drop_outlined,
                color: _getImpactColor(value),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Empreinte hydrique',
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
                  text: '${value.toStringAsFixed(0)} ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _getImpactColor(value),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'litres',
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
    if (value < 300) return Colors.green;
    if (value < 800) return Colors.lightGreen;
    if (value < 1500) return Colors.amber;
    if (value < 3000) return Colors.orange;
    return Colors.red;
  }

  String _getImpactDescription(double value) {
    if (value < 300) return 'Impact très faible';
    if (value < 800) return 'Impact faible';
    if (value < 1500) return 'Impact moyen';
    if (value < 3000) return 'Impact élevé';
    return 'Impact très élevé';
  }
} 