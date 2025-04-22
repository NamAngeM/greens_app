import 'package:flutter/material.dart';

class TransportFootprintWidget extends StatelessWidget {
  final double distance; // En kilomètres
  final String transportType; // Ex: "camion", "bateau", "avion"
  final String origin; // Pays ou région d'origine
  
  const TransportFootprintWidget({
    Key? key,
    required this.distance,
    required this.transportType,
    required this.origin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTransportIcon(),
                  color: _getTransportColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Empreinte de Transport',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distance parcourue:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${distance.toStringAsFixed(0)} km',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Moyen de transport:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _getTransportLabel(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Origine:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  origin,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getImpactValue(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getTransportColor()),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              _getImpactDescription(),
              style: TextStyle(
                fontSize: 12,
                color: _getTransportColor(),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransportIcon() {
    switch (transportType.toLowerCase()) {
      case 'avion':
        return Icons.airplanemode_active;
      case 'bateau':
        return Icons.directions_boat;
      case 'train':
        return Icons.train;
      case 'camion':
      case 'camions':
        return Icons.local_shipping;
      default:
        return Icons.local_shipping;
    }
  }

  Color _getTransportColor() {
    if (distance < 100) return Colors.green;
    if (distance < 500) return Colors.lightGreen;
    if (distance < 1000) return Colors.amber;
    if (distance < 5000) return Colors.orange;
    return Colors.red;
  }

  double _getImpactValue() {
    // Normalisation de la distance pour obtenir une valeur entre 0 et 1
    if (distance <= 0) return 0.0;
    if (distance > 10000) return 1.0;
    
    double value = distance / 10000;
    return value;
  }

  String _getTransportLabel() {
    switch (transportType.toLowerCase()) {
      case 'avion':
        return 'Avion';
      case 'bateau':
        return 'Transport maritime';
      case 'train':
        return 'Train';
      case 'camion':
      case 'camions':
        return 'Transport routier';
      default:
        return transportType;
    }
  }

  String _getImpactDescription() {
    if (distance < 100) {
      return 'Impact très faible - Transport local';
    } else if (distance < 500) {
      return 'Impact faible - Transport régional';
    } else if (distance < 1000) {
      return 'Impact moyen - Transport national';
    } else if (distance < 5000) {
      return 'Impact élevé - Transport continental';
    } else {
      return 'Impact très élevé - Transport intercontinental';
    }
  }
} 