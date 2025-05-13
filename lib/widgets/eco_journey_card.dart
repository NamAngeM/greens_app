import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_journey_step.dart';
import 'package:greens_app/models/user_eco_level.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:greens_app/services/eco_journey_service.dart';
import 'package:greens_app/services/eco_challenge_service.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class EcoJourneyCard extends StatefulWidget {
  const EcoJourneyCard({Key? key}) : super(key: key);

  @override
  State<EcoJourneyCard> createState() => _EcoJourneyCardState();
}

class _EcoJourneyCardState extends State<EcoJourneyCard> {
  bool _isLoading = true;
  String _userId = '';
  int _userLevel = 1;
  UserEcoLevel? _levelInfo;
  int _ecoPoints = 0;
  double _journeyProgress = 0.0;
  EcoJourneyStep? _nextStep;
  
  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Initialiser les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }
  
  Future<void> _loadUserData() async {
    final journeyService = Provider.of<EcoJourneyService>(context, listen: false);
    
    final userLevel = await journeyService.getUserEcoLevel(_userId);
    final levelInfo = journeyService.getLevelInfo(userLevel);
    final ecoPoints = await journeyService.getUserEcoPoints(_userId);
    final journeyProgress = await journeyService.getOverallProgress(_userId);
    final nextStep = await journeyService.getNextRecommendedStep(_userId);
    
    setState(() {
      _userLevel = userLevel;
      _levelInfo = levelInfo;
      _ecoPoints = ecoPoints;
      _journeyProgress = journeyProgress;
      _nextStep = nextStep;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Votre parcours écologique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3140),
                ),
              ),
              const SizedBox(height: 16),
              Card(
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
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Nv. $_userLevel',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _levelInfo?.title ?? 'Niveau $_userLevel',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F3140),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_ecoPoints points accumulés',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearPercentIndicator(
                                  lineHeight: 8.0,
                                  percent: _journeyProgress,
                                  progressColor: const Color(0xFF4CAF50),
                                  backgroundColor: Colors.grey.shade200,
                                  barRadius: const Radius.circular(4),
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_journeyProgress * 100).toInt()}% du parcours complété',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      if (_nextStep != null) ...[
                        const Text(
                          'Votre prochaine étape',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F3140),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.trending_up, color: Color(0xFF4CAF50)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nextStep!.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F3140),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _nextStep!.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Félicitations ! Vous avez complété toutes les étapes de votre parcours écologique.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.ecoJourney);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Voir mon parcours complet'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDailyChallenge(),
            ],
          );
  }
  
  Widget _buildDailyChallenge() {
    return Consumer<EcoChallengeService>(
      builder: (context, challengeService, child) {
        final dailyChallenge = challengeService.dailyChallenge;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Défi quotidien',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.challenges);
                  },
                  child: const Text(
                    'Voir tous les défis',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (dailyChallenge == null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.pending_actions,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun défi quotidien disponible pour le moment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Revenez demain pour un nouveau défi !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.challenges);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Voir les défis hebdomadaires'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(dailyChallenge.category).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                _getCategoryIcon(dailyChallenge.category),
                                color: _getCategoryColor(dailyChallenge.category),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dailyChallenge.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F3140),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dailyChallenge.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                          _buildChallengeMetric(
                            '${dailyChallenge.pointsValue} pts',
                            'Points',
                            Icons.stars,
                          ),
                          _buildChallengeMetric(
                            _formatDuration(dailyChallenge.duration),
                            'Durée',
                            Icons.access_time,
                          ),
                          _buildChallengeMetric(
                            '${dailyChallenge.estimatedImpact} kg',
                            'CO₂ évité',
                            Icons.eco,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearPercentIndicator(
                        lineHeight: 8.0,
                        percent: dailyChallenge.progressPercentage / 100,
                        progressColor: _getCategoryColor(dailyChallenge.category),
                        backgroundColor: Colors.grey.shade200,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Progression: ${dailyChallenge.progressPercentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.challenges);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getCategoryColor(dailyChallenge.category),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            dailyChallenge.isCompleted ? 'Défi complété' : 'Voir le détail du défi',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildChallengeMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
  
  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.transport:
        return Colors.blue;
      case ChallengeCategory.energy:
        return Colors.orange;
      case ChallengeCategory.food:
        return Colors.red;
      case ChallengeCategory.waste:
        return Colors.purple;
      case ChallengeCategory.water:
        return Colors.lightBlue;
      case ChallengeCategory.digital:
        return Colors.teal;
      case ChallengeCategory.community:
        return Colors.pink;
      case ChallengeCategory.general:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.transport:
        return Icons.directions_car;
      case ChallengeCategory.energy:
        return Icons.bolt;
      case ChallengeCategory.food:
        return Icons.restaurant;
      case ChallengeCategory.waste:
        return Icons.delete;
      case ChallengeCategory.water:
        return Icons.water_drop;
      case ChallengeCategory.digital:
        return Icons.devices;
      case ChallengeCategory.community:
        return Icons.people;
      case ChallengeCategory.general:
        return Icons.eco;
    }
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} h';
    } else {
      return '${duration.inMinutes} min';
    }
  }
} 