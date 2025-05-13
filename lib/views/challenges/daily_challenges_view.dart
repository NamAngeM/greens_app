import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:greens_app/services/eco_challenge_service.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';

class DailyChallengesView extends StatefulWidget {
  const DailyChallengesView({Key? key}) : super(key: key);

  @override
  State<DailyChallengesView> createState() => _DailyChallengesViewState();
}

class _DailyChallengesViewState extends State<DailyChallengesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  bool _isLoading = true;
  String _userId = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Initialiser le service de défis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChallengeService();
    });
  }
  
  Future<void> _initializeChallengeService() async {
    final challengeService = Provider.of<EcoChallengeService>(context, listen: false);
    await challengeService.initialize(_userId);
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Défis écologiques'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F3140),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'Défi quotidien'),
            Tab(text: 'Défis hebdomadaires'),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyChallenge(),
                  _buildWeeklyChallenges(),
                ],
              ),
              // Confetti effect when challenge is completed
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                  ],
                ),
              ),
            ],
          ),
      bottomNavigationBar: const CustomMenu(currentIndex: 2),
    );
  }
  
  Widget _buildDailyChallenge() {
    return Consumer<EcoChallengeService>(
      builder: (context, challengeService, child) {
        final dailyChallenge = challengeService.dailyChallenge;
        
        if (dailyChallenge == null) {
          return const Center(
            child: Text(
              'Aucun défi quotidien disponible pour le moment.\nRevenez demain pour un nouveau défi !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChallengeCard(dailyChallenge),
              const SizedBox(height: 24),
              _buildChallengeStats(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildWeeklyChallenges() {
    return Consumer<EcoChallengeService>(
      builder: (context, challengeService, child) {
        final weeklyChallenges = challengeService.weeklyChallenges;
        
        if (weeklyChallenges.isEmpty) {
          return const Center(
            child: Text(
              'Aucun défi hebdomadaire disponible pour le moment.\nRevenez la semaine prochaine pour de nouveaux défis !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...weeklyChallenges.map((challenge) => Column(
                children: [
                  _buildChallengeCard(challenge),
                  const SizedBox(height: 16),
                ],
              )),
              const SizedBox(height: 8),
              _buildChallengeStats(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildChallengeCard(EcoChallenge challenge) {
    final Color cardColor = _getCategoryColor(challenge.category);
    final bool isCompleted = challenge.isCompleted;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted ? Colors.green : Colors.transparent,
          width: isCompleted ? 2 : 0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(challenge.category),
                      color: cardColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(challenge.category),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getLevelName(challenge.level),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Challenge content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Challenge metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      '${challenge.pointsValue} pts',
                      'Points',
                      Icons.stars,
                    ),
                    _buildMetricItem(
                      _formatDuration(challenge.duration),
                      'Durée',
                      Icons.access_time,
                    ),
                    _buildMetricItem(
                      '${challenge.estimatedImpact} kg',
                      'CO₂ évité',
                      Icons.eco,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Progress indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${challenge.progressPercentage.toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 8,
                      percent: challenge.progressPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: isCompleted ? Colors.green : cardColor,
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : () => _updateProgress(challenge, challenge.progressPercentage + 25),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isCompleted ? 'Complété' : 'Progresser',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isCompleted)
                      ElevatedButton(
                        onPressed: () => _completeChallenge(challenge),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Terminer'),
                      ),
                  ],
                ),
                
                // Tips section
                if (challenge.tips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Conseils',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3140),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...challenge.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: cardColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeStats() {
    return Consumer<EcoChallengeService>(
      builder: (context, challengeService, child) {
        final stats = challengeService.getUserChallengeStats();
        
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
                  'Vos statistiques',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      stats['totalCompleted'].toString(),
                      'Défis complétés',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatItem(
                      stats['totalPoints'].toString(),
                      'Points gagnés',
                      Icons.stars,
                      Colors.amber,
                    ),
                    _buildStatItem(
                      '${stats['totalImpact'].toStringAsFixed(1)} kg',
                      'CO₂ économisé',
                      Icons.eco,
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMetricItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
  
  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
  
  void _updateProgress(EcoChallenge challenge, double progress) {
    final challengeService = Provider.of<EcoChallengeService>(context, listen: false);
    
    // Limiter la progression à 100%
    final newProgress = progress > 100 ? 100.0 : progress;
    
    challengeService.updateChallengeProgress(_userId, challenge.id, newProgress);
    
    // Si le défi est complété, afficher les confettis
    if (newProgress >= 100) {
      _confettiController.play();
      
      // Afficher une snackbar de félicitations
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Félicitations ! Vous avez complété le défi "${challenge.title}" !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _completeChallenge(EcoChallenge challenge) {
    final challengeService = Provider.of<EcoChallengeService>(context, listen: false);
    challengeService.completeChallenge(_userId, challenge.id);
    _confettiController.play();
    
    // Afficher une snackbar de félicitations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Félicitations ! Vous avez complété le défi "${challenge.title}" !'),
        backgroundColor: Colors.green,
      ),
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
  
  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.transport:
        return 'Transport';
      case ChallengeCategory.energy:
        return 'Énergie';
      case ChallengeCategory.food:
        return 'Alimentation';
      case ChallengeCategory.waste:
        return 'Déchets';
      case ChallengeCategory.water:
        return 'Eau';
      case ChallengeCategory.digital:
        return 'Numérique';
      case ChallengeCategory.community:
        return 'Communauté';
      case ChallengeCategory.general:
        return 'Général';
    }
  }
  
  String _getLevelName(ChallengeLevel level) {
    switch (level) {
      case ChallengeLevel.beginner:
        return 'Débutant';
      case ChallengeLevel.intermediate:
        return 'Intermédiaire';
      case ChallengeLevel.advanced:
        return 'Avancé';
      case ChallengeLevel.expert:
        return 'Expert';
    }
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} min';
    }
  }
} 