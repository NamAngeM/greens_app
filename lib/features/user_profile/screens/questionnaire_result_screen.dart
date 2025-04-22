import 'package:flutter/material.dart';
import '../models/environmental_profile.dart';
import '../widgets/carbon_footprint_chart.dart';

class QuestionnaireResultScreen extends StatelessWidget {
  final EnvironmentalProfile profile;

  const QuestionnaireResultScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats du profil environnemental'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreOverview(context),
            const SizedBox(height: 24),
            _buildDigitalSection(context),
            const SizedBox(height: 24),
            _buildSoundPollutionSection(context),
            const SizedBox(height: 24),
            _buildRecommendations(context),
            const SizedBox(height: 24),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreOverview(BuildContext context) {
    final totalCarbonFootprint = profile.carbonFootprint;
    final scoreDescription = _getCarbonScoreDescription(totalCarbonFootprint);
    final scoreLevel = _getCarbonScoreLevel(totalCarbonFootprint);
    final scoreColor = _getCarbonScoreColor(totalCarbonFootprint);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre empreinte carbone totale',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${totalCarbonFootprint.toStringAsFixed(2)} t',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CO₂e/an',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Niveau: $scoreLevel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              scoreDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const CarbonFootprintChart(), // Ce widget reste à définir
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalSection(BuildContext context) {
    final digitalCarbonFootprint = profile.digitalProfile.calculateCarbonFootprint() * 1000; // kg
    final digitalColor = _getDigitalScoreColor(digitalCarbonFootprint);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.computer, color: digitalColor),
                const SizedBox(width: 8),
                Text(
                  'Empreinte numérique',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Graphique de répartition - à remplacer par un widget réel
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Graphique de l\'empreinte numérique'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildKeyMetric(
              context, 
              'Consommation de streaming',
              '${profile.digitalProfile.streamingHoursPerDay} h/jour',
              Icons.play_circle_outline,
              Colors.blue,
            ),
            
            _buildKeyMetric(
              context, 
              'Stockage cloud',
              '${profile.digitalProfile.cloudStorageGB} GB',
              Icons.cloud_upload,
              Colors.purple,
            ),
            
            _buildKeyMetric(
              context, 
              'Appareils électroniques',
              '${profile.digitalProfile.smartphonesOwnedLast5Years + profile.digitalProfile.computersOwnedLast5Years} appareils sur 5 ans',
              Icons.devices,
              Colors.teal,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: digitalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: digitalColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getDigitalTip(digitalCarbonFootprint),
                      style: TextStyle(color: digitalColor.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundPollutionSection(BuildContext context) {
    final soundImpact = profile.digitalProfile.calculateSoundHealthImpact();
    final soundColor = _getSoundImpactColor(soundImpact);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hearing, color: soundColor),
                const SizedBox(width: 8),
                Text(
                  'Impact sonore',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Score de santé auditive
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: soundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score de santé auditive',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: soundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(100 - soundImpact).toStringAsFixed(0)}/100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildKeyMetric(
              context, 
              'Utilisation des écouteurs',
              '${profile.digitalProfile.headphonesUseHoursPerDay} h/jour',
              Icons.headphones,
              Colors.indigo,
            ),
            
            _buildKeyMetric(
              context, 
              'Niveau de volume moyen',
              '${profile.digitalProfile.averageVolumeLevel.toStringAsFixed(0)}%',
              Icons.volume_up,
              Colors.orange,
            ),
            
            _buildKeyMetric(
              context, 
              'Exposition aux environnements bruyants',
              '${profile.digitalProfile.exposureToLoudEnvironmentsHoursPerWeek} h/semaine',
              Icons.campaign,
              Colors.red,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSoundHealthTip(soundImpact),
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Recommandations personnalisées',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ..._getRecommendations().map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(recommendation),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Action à définir - par exemple, afficher plus de détails ou des conseils
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à venir!')),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Découvrir comment réduire mon impact',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getCarbonScoreDescription(double totalFootprint) {
    if (totalFootprint < 5) {
      return 'Votre empreinte carbone est bien inférieure à la moyenne mondiale. Félicitations pour vos efforts environnementaux!';
    } else if (totalFootprint < 10) {
      return 'Votre empreinte carbone est dans la moyenne. Quelques ajustements pourraient encore l\'améliorer.';
    } else {
      return 'Votre empreinte carbone est supérieure à la moyenne mondiale. Consultez nos recommandations pour la réduire.';
    }
  }

  String _getCarbonScoreLevel(double totalFootprint) {
    if (totalFootprint < 5) return 'Excellent';
    if (totalFootprint < 8) return 'Bon';
    if (totalFootprint < 12) return 'Moyen';
    return 'Élevé';
  }

  Color _getCarbonScoreColor(double totalFootprint) {
    if (totalFootprint < 5) return Colors.green;
    if (totalFootprint < 8) return Colors.lightGreen;
    if (totalFootprint < 12) return Colors.amber;
    return Colors.red;
  }

  Color _getDigitalScoreColor(double digitalCarbonKg) {
    if (digitalCarbonKg < 200) return Colors.green;
    if (digitalCarbonKg < 400) return Colors.amber;
    if (digitalCarbonKg < 600) return Colors.orange;
    return Colors.red;
  }

  String _getDigitalTip(double digitalCarbonKg) {
    if (digitalCarbonKg < 200) {
      return 'Excellente gestion numérique! Vous maintenez une empreinte digitale faible.';
    } else if (digitalCarbonKg < 400) {
      return 'Pensez à limiter votre consommation de streaming et à vider régulièrement votre stockage cloud.';
    } else {
      return 'Réduisez votre temps d\'écran et augmentez la durée de vie de vos appareils pour diminuer votre empreinte numérique.';
    }
  }

  Color _getSoundImpactColor(double impact) {
    if (impact < 30) return Colors.green;
    if (impact < 60) return Colors.amber;
    if (impact < 80) return Colors.orange;
    return Colors.red;
  }

  String _getSoundHealthTip(double impact) {
    if (impact < 30) {
      return 'Excellente gestion sonore! Vous préservez bien votre santé auditive.';
    } else if (impact < 60) {
      return 'Essayez de réduire le volume de vos écouteurs. La règle des 60/60: pas plus de 60% du volume maximum pendant 60 minutes.';
    } else {
      return 'Votre exposition sonore présente des risques. Limitez l\'utilisation d\'écouteurs et évitez les environnements bruyants.';
    }
  }

  List<String> _getRecommendations() {
    final List<String> recommendations = [];
    final digitalCarbonFootprint = profile.digitalProfile.calculateCarbonFootprint() * 1000;
    final soundImpact = profile.digitalProfile.calculateSoundHealthImpact();
    
    // Recommandations numériques
    if (profile.digitalProfile.streamingHoursPerDay > 3) {
      recommendations.add('Réduire le temps de streaming à 2 heures par jour pourrait économiser environ ${(profile.digitalProfile.streamingHoursPerDay - 2).toStringAsFixed(1) * 365 * 0.08} kg de CO₂ par an.');
    }
    
    if (profile.digitalProfile.smartphonesOwnedLast5Years > 2) {
      recommendations.add('Prolonger la durée de vie de votre smartphone d\'un an permet d\'économiser environ 80 kg de CO₂.');
    }
    
    if (!profile.digitalProfile.darkModeEnabled) {
      recommendations.add('Activer le mode sombre peut réduire la consommation d\'énergie de votre appareil jusqu\'à 30% sur les écrans OLED.');
    }
    
    // Recommandations sonores
    if (profile.digitalProfile.averageVolumeLevel > 70) {
      recommendations.add('Réduire le volume de vos écouteurs à moins de 70% pour protéger votre audition.');
    }
    
    if (profile.digitalProfile.headphonesUseHoursPerDay > 3) {
      recommendations.add('Limiter l\'utilisation des écouteurs à 3 heures par jour maximum avec des pauses régulières.');
    }
    
    if (profile.digitalProfile.exposureToLoudEnvironmentsHoursPerWeek > 5) {
      recommendations.add('Porter une protection auditive dans les environnements bruyants (concerts, chantiers, etc.).');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Continuez vos bonnes pratiques! Votre profil est déjà très respectueux de l\'environnement et de votre santé.');
    }
    
    return recommendations;
  }
} 