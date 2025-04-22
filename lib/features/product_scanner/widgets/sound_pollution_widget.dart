import 'package:flutter/material.dart';

class SoundPollutionWidget extends StatelessWidget {
  final double decibelLevel;
  final String deviceType;
  final bool hasNoiseReduction;

  const SoundPollutionWidget({
    Key? key,
    required this.decibelLevel,
    required this.deviceType,
    this.hasNoiseReduction = false,
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
                  Icons.volume_up_outlined,
                  color: _getSoundLevelColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pollution sonore',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${decibelLevel.toStringAsFixed(1)} dB',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getSoundLevelColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getNormalizedDecibelLevel(),
              color: _getSoundLevelColor(),
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            _buildDeviceTypeInfo(context),
            const SizedBox(height: 12),
            _buildSoundImpactDescription(),
            const SizedBox(height: 8),
            _buildHealthTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTypeInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type d\'appareil',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              deviceType,
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
              'Réduction du bruit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              hasNoiseReduction ? 'Oui' : 'Non',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasNoiseReduction ? Colors.green : Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundImpactDescription() {
    String impactDescription;
    if (decibelLevel <= 50) {
      impactDescription = 'Impact sonore faible';
    } else if (decibelLevel <= 75) {
      impactDescription = 'Impact sonore modéré';
    } else {
      impactDescription = 'Impact sonore élevé';
    }

    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            impactDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getHealthTip(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getNormalizedDecibelLevel() {
    // Transformer le niveau de décibels en valeur entre 0 et 1
    // Considérer que 30dB est très silencieux (0.1) et 100dB est très bruyant (1.0)
    double normalized = (decibelLevel - 30) / 70;
    if (normalized < 0) return 0.1;
    if (normalized > 1) return 1.0;
    return normalized;
  }

  Color _getSoundLevelColor() {
    if (decibelLevel <= 50) {
      return Colors.green;
    } else if (decibelLevel <= 75) {
      return Colors.amber;
    } else if (decibelLevel <= 85) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getHealthTip() {
    if (decibelLevel > 85) {
      return 'Une exposition prolongée à ce niveau sonore peut causer des dommages auditifs permanents. Limitez votre exposition à moins de 15 minutes par jour.';
    } else if (decibelLevel > 75) {
      return 'Ce niveau sonore peut provoquer de la fatigue auditive après quelques heures. Prenez des pauses régulières.';
    } else if (decibelLevel > 60) {
      return 'Ce niveau sonore modéré est acceptable pour un usage quotidien mais peut gêner la concentration sur le long terme.';
    } else {
      return 'Ce niveau sonore est confortable pour une utilisation prolongée et respecte votre santé auditive.';
    }
  }
} 