import 'package:flutter/material.dart';
import 'package:greens_app/models/dashboard_stats_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DashboardStatsWidget extends StatelessWidget {
  final DashboardStatsModel stats;

  const DashboardStatsWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserLevelCard(),
        const SizedBox(height: 20),
        _buildStatsGrid(),
      ],
    );
  }

  Widget _buildUserLevelCard() {
    // Calcul du pourcentage de progression vers le niveau suivant
    double progressPercent = 0.0;
    int nextLevelPoints = 0;
    
    switch (stats.currentLevel) {
      case 'Débutant':
        nextLevelPoints = 100;
        progressPercent = stats.totalPoints / nextLevelPoints;
        break;
      case 'Apprenti':
        nextLevelPoints = 500;
        progressPercent = (stats.totalPoints - 100) / (nextLevelPoints - 100);
        break;
      case 'Éco-conscient':
        nextLevelPoints = 1000;
        progressPercent = (stats.totalPoints - 500) / (nextLevelPoints - 500);
        break;
      case 'Éco-responsable':
        nextLevelPoints = 2000;
        progressPercent = (stats.totalPoints - 1000) / (nextLevelPoints - 1000);
        break;
      case 'Éco-expert':
        nextLevelPoints = 5000;
        progressPercent = (stats.totalPoints - 2000) / (nextLevelPoints - 2000);
        break;
      default:
        // Pour les éco-champions (niveau max)
        progressPercent = 1.0;
        nextLevelPoints = stats.totalPoints;
    }
    
    // Limiter le pourcentage entre 0 et 1
    progressPercent = progressPercent.clamp(0.0, 1.0);
    
    // Nombre de points manquants pour le niveau suivant
    final int remainingPoints = progressPercent < 1.0 ? nextLevelPoints - stats.totalPoints : 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 45.0,
                  lineWidth: 8.0,
                  percent: progressPercent,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        stats.totalPoints.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  progressColor: AppColors.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.currentLevel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remainingPoints > 0
                            ? 'Encore $remainingPoints points pour le niveau suivant'
                            : 'Niveau maximum atteint !',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        lineHeight: 8.0,
                        percent: progressPercent,
                        progressColor: AppColors.primaryColor,
                        backgroundColor: Colors.grey.shade200,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Actions', '${stats.actionsCompleted}', Icons.check_circle_outline),
                _buildStat('CO₂ économisé', '${stats.carbonSaved.toStringAsFixed(1)} kg', Icons.eco_outlined),
                _buildStat('Badges', '${stats.totalBadges}', Icons.emoji_events_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Produits scannés',
          stats.productsScanCount.toString(),
          Icons.qr_code_scanner_outlined,
          AppColors.primaryColor,
        ),
        _buildStatCard(
          'Score éco moyen',
          '${stats.avgProductEcoScore.toStringAsFixed(1)}/100',
          Icons.insights_outlined,
          Colors.amber,
        ),
        _buildStatCard(
          'Produits écologiques',
          stats.ecoFriendlyProductCount.toString(),
          Icons.thumb_up_outlined,
          Colors.green,
        ),
        _buildStatCard(
          'Défis participés',
          stats.participatedChallenges.toString(),
          Icons.flag_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
} 