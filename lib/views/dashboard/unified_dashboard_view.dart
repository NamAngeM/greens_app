import 'package:flutter/material.dart';
import 'package:greens_app/services/eco_journey_service.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/services/favorites_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class UnifiedDashboardView extends StatelessWidget {
  const UnifiedDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ecoJourneyService = Provider.of<EcoJourneyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon impact écologique'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F3140),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Rafraîchir les données
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données mises à jour')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<int>(
        future: ecoJourneyService.getUserEcoLevel(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }
          
          final ecoLevel = snapshot.data ?? 0;
          final levelTitle = ecoJourneyService.getLevelTitle(ecoLevel);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserLevelCard(context, ecoLevel, levelTitle),
                const SizedBox(height: 16),
                _buildCarbonSummaryCard(context),
                const SizedBox(height: 16),
                _buildDigitalFootprintCard(context),
                const SizedBox(height: 16),
                _buildEcoActionsProgress(context),
                const SizedBox(height: 16),
                _buildCommunityImpact(context),
                const SizedBox(height: 16),
                _buildNextStepsCard(context, ecoJourneyService, userId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserLevelCard(BuildContext context, int level, String levelTitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: level / 15, // Max level assumed to be 15
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nv. $level',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.eco, color: Color(0xFF4CAF50)),
                ],
              ),
              progressColor: const Color(0xFF4CAF50),
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3140),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Votre parcours vers un mode de vie durable progresse bien !',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.goals);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Mes objectifs'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonSummaryCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Empreinte carbone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.carbonDashboard);
                  },
                  child: const Text(
                    'Détails',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 15,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey.shade800,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String text = '';
                          switch (value.toInt()) {
                            case 0:
                              text = 'Transport';
                              break;
                            case 1:
                              text = 'Alimentation';
                              break;
                            case 2:
                              text = 'Logement';
                              break;
                            case 3:
                              text = 'Numérique';
                              break;
                            case 4:
                              text = 'Autres';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return Text(
                            text,
                            style: const TextStyle(
                              color: Color(0xFF1F3140),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String text = '';
                          if (value == 0) {
                            text = '0';
                          } else if (value == 5) {
                            text = '5';
                          } else if (value == 10) {
                            text = '10';
                          } else if (value == 15) {
                            text = '15';
                          }
                          return Text(
                            text,
                            style: const TextStyle(
                              color: Color(0xFF1F3140),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 8.5,
                          color: const Color(0xFF4CAF50),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 6.2,
                          color: const Color(0xFF4CAF50),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 10.5,
                          color: const Color(0xFF4CAF50),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 3.8,
                          color: const Color(0xFF4CAF50),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 5.1,
                          color: const Color(0xFF4CAF50),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCarbonMetric('7.3t', 'Total annuel', Icons.co2),
                _buildCarbonMetric('-12%', 'vs. moy. nationale', Icons.trending_down),
                _buildCarbonMetric('-0.8t', 'vs. trim. dernier', Icons.insights),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
          ],
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

  Widget _buildDigitalFootprintCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Empreinte numérique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDigitalMetricCard(
                    '2.3 Go', 
                    'Données / jour',
                    Icons.data_usage,
                    Colors.blue.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDigitalMetricCard(
                    '128 kg', 
                    'CO2 / an',
                    Icons.cloud_outlined,
                    Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDigitalMetricCard(
                    '4.2h', 
                    'Écran / jour',
                    Icons.smartphone,
                    Colors.purple.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Conseils pour réduire votre empreinte :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
            const SizedBox(height: 8),
            _buildDigitalTipItem(
              'Nettoyer régulièrement vos emails',
              '1 email = 4g de CO2',
            ),
            _buildDigitalTipItem(
              'Réduire le streaming en HD',
              '30 min HD = 1 Go de données',
            ),
            _buildDigitalTipItem(
              'Utiliser le Wifi plutôt que la 4G/5G',
              '4G consomme 4x plus d\'énergie',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalTipItem(String tip, String impact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates,
            color: Colors.amber.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F3140),
                  ),
                ),
                Text(
                  impact,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoActionsProgress(BuildContext context) {
    final goalController = Provider.of<EcoGoalController>(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes actions écologiques',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.goals);
                  },
                  child: const Text(
                    'Gérer',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goalController.userGoals.length > 3 
                ? 3 
                : goalController.userGoals.length,
              itemBuilder: (context, index) {
                final goal = goalController.userGoals[index];
                final progress = goal.currentProgress / goal.target;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F3140),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: progress == 1.0 ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: progress,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: progress == 1.0 
                        ? Colors.green.shade700
                        : progress > 0.7 
                          ? Colors.greenAccent.shade700
                          : Colors.amber.shade600,
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            Visibility(
              visible: goalController.userGoals.isEmpty,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.energy_savings_leaf,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Vous n\'avez pas encore défini d\'objectifs',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.goals);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Créer un objectif'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionStat('3', 'Objectifs en cours'),
                  _buildActionStat('2', 'Objectifs atteints'),
                  _buildActionStat('46kg', 'CO2 évité'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCommunityImpact(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Impact communautaire',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.community);
                  },
                  child: const Text(
                    'Rejoindre',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.groups,
                    size: 32,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zéro Déchets Challenge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rejoignez 324 participants pour réduire vos déchets !',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearPercentIndicator(
                          lineHeight: 8.0,
                          percent: 0.68,
                          backgroundColor: Colors.white,
                          progressColor: Colors.blue.shade700,
                          barRadius: const Radius.circular(4),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '68% complété • 12 jours restants',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Statistiques collectives',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCommunityMetric('1,340', 'participants actifs', Icons.people),
                _buildCommunityMetric('4.2t', 'CO2 économisé', Icons.co2),
                _buildCommunityMetric('253kg', 'déchets évités', Icons.delete_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextStepsCard(BuildContext context, EcoJourneyService ecoJourneyService, String userId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ecoJourneyService.suggestNextAction(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final nextAction = snapshot.data!;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre prochaine étape',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                    child: Icon(
                      nextAction['icon'] as IconData? ?? Icons.eco,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  title: Text(
                    nextAction['message'] as String? ?? 'Continuez votre parcours écologique',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3140),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      nextAction['route'] as String? ?? AppRoutes.home,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 