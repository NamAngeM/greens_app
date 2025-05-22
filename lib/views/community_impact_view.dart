// lib/views/community_impact_view.dart
import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/services/eco_metrics_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:greens_app/utils/chart_fix.dart';
import 'package:provider/provider.dart';

// Classe pour représenter les données du graphique
class ProgressData {
  final int day;
  final double progress;
  
  ProgressData(this.day, this.progress);
}

class CommunityImpactView extends StatefulWidget {
  final String challengeId;
  
  const CommunityImpactView({
    Key? key,
    required this.challengeId,
  }) : super(key: key);

  @override
  _CommunityImpactViewState createState() => _CommunityImpactViewState();
}

class _CommunityImpactViewState extends State<CommunityImpactView> {
  late Future<CommunityChallenge> _challengeFuture;
  late EcoMetricsService _metricsService;
  
  @override
  void initState() {
    super.initState();
    _metricsService = EcoMetricsService();
    _loadChallengeData();
  }
  
  void _loadChallengeData() {
    final communityController = Provider.of<CommunityController>(context, listen: false);
    _challengeFuture = communityController.getChallengeById(widget.challengeId)
        .then((challenge) {
          if (challenge == null) {
            return CommunityChallenge(
              id: 'not_found',
              title: 'Défi non trouvé',
              description: 'Ce défi n\'existe pas ou a été supprimé',
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 1)),
              participants: [],
              participantsCount: 0,
              targetParticipants: 0,
              status: ChallengeStatus.upcoming,
              imageUrl: '',
              carbonPointsReward: 0,
              type: GoalType.waste, // Utiliser une valeur valide de l'enum GoalType
              impactPerParticipant: 0.0,
              createdAt: DateTime.now(),
              category: ChallengeCategory.other,
            );
          }
          return challenge;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Collectif'),
        elevation: 0,
      ),
      body: FutureBuilder<CommunityChallenge>(
        future: _challengeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: AppStyles.bodyText,
              ),
            );
          }
          
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Défi non trouvé'),
            );
          }
          
          final challenge = snapshot.data!;
          final co2Impact = _metricsService.calculateChallengeC02Impact(challenge);
          final treeEquivalent = _metricsService.calculateTreeEquivalent(co2Impact);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du défi
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: AppStyles.heading1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          challenge.description,
                          style: AppStyles.bodyText,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                              context,
                              '${challenge.participantCount}',
                              'Participants',
                              Icons.people,
                            ),
                            _buildInfoItem(
                              context,
                              '${challenge.daysLeft}',
                              'Jours restants',
                              Icons.calendar_today,
                            ),
                            _buildInfoItem(
                              context,
                              '${(challenge.completionPercentage * 100).toStringAsFixed(0)}%',
                              'Complété',
                              Icons.check_circle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Impact CO2
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.lightGreen.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impact Carbone Collectif',
                          style: AppStyles.heading2,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '${co2Impact.toStringAsFixed(2)} kg CO₂e',
                                style: AppStyles.heading1.copyWith(
                                  color: AppColors.successColor,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'économisés ensemble',
                                style: AppStyles.bodyText,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.nature,
                                      color: AppColors.successColor,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$treeEquivalent',
                                      style: AppStyles.heading1.copyWith(
                                        color: AppColors.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'arbres plantés pendant un an',
                                  style: AppStyles.bodyText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Graphique de progression
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progression Hebdomadaire',
                          style: AppStyles.heading2,
                        ),
                        const SizedBox(height: 16),
                        _buildProgressChart(challenge),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Participants les plus actifs
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Contributeurs',
                          style: AppStyles.heading2,
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: challenge.topContributors.length,
                          itemBuilder: (context, index) {
                            final contributor = challenge.topContributors[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(contributor['photoUrl'] ?? ''),
                              ),
                              title: Text(contributor['name'] ?? 'Contributeur'),
                              subtitle: Text('${(contributor['contribution'] ?? 0.0).toStringAsFixed(2)} kg CO₂e'),
                              trailing: Text(
                                '#${index + 1}',
                                style: AppStyles.heading3,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bouton pour contribuer
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/challenge/${challenge.id}/contribute',
                      );
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Ajouter ma contribution'),
                    style: AppStyles.primaryButtonStyle,
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.heading3,
        ),
        Text(
          label,
          style: AppStyles.caption,
        ),
      ],
    );
  }
  
  Widget _buildProgressChart(CommunityChallenge challenge) {
    // Données fictives pour la démonstration
    final weeklyData = [
      ProgressData(1, 10),
      ProgressData(2, 25),
      ProgressData(3, 42),
      ProgressData(4, 58),
      ProgressData(5, 70),
      ProgressData(6, 85),
      ProgressData(7, challenge.participantsCount.toDouble()), // Utiliser une valeur appropriée
    ];
    
    // Créer la série de données
    final series = [
      ChartUtils.createLineSeries<ProgressData>(
        data: weeklyData,
        name: 'Progression',
        color: AppColors.primaryColor,
        xValueMapper: (ProgressData data, int index) => data.day,
        yValueMapper: (ProgressData data, int index) => data.progress,
        enableGradient: true,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          height: 6,
          width: 6,
        ),
      ),
    ];
    
    // Créer le graphique
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      child: SfCartesianChart(
        title: ChartTitle(text: 'Progression hebdomadaire'),
        primaryXAxis: NumericAxis(
          minimum: 1,
          maximum: 7,
          interval: 1,
          labelFormat: '{value}',
          majorGridLines: const MajorGridLines(width: 0),
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            final List<String> weekdays = ['', 'L', 'M', 'M', 'J', 'V', 'S', 'D'];
            final int index = details.value.toInt();
            if (index >= 1 && index <= 7) {
              return ChartAxisLabel(weekdays[index], null);
            }
            return ChartAxisLabel('', null);
          },
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 100,
          interval: 20,
          labelFormat: '{value}%',
        ),
        series: series,
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }
}