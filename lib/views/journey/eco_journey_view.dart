import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_journey_step.dart';
import 'package:greens_app/models/user_eco_level.dart';
import 'package:greens_app/services/eco_journey_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EcoJourneyView extends StatefulWidget {
  const EcoJourneyView({Key? key}) : super(key: key);

  @override
  State<EcoJourneyView> createState() => _EcoJourneyViewState();
}

class _EcoJourneyViewState extends State<EcoJourneyView> {
  bool _isLoading = true;
  String _userId = '';
  List<Map<String, dynamic>> _journeySteps = [];
  int _userLevel = 1;
  UserEcoLevel? _levelInfo;
  int _ecoPoints = 0;
  double _journeyProgress = 0.0;
  
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
    final journeySteps = await journeyService.getUserJourneyProgress(_userId);
    final journeyProgress = await journeyService.getOverallProgress(_userId);
    
    setState(() {
      _userLevel = userLevel;
      _levelInfo = levelInfo;
      _ecoPoints = ecoPoints;
      _journeySteps = journeySteps;
      _journeyProgress = journeyProgress;
      _isLoading = false;
    });
  }
  
  Future<void> _completeStep(String stepId) async {
    final journeyService = Provider.of<EcoJourneyService>(context, listen: false);
    await journeyService.completeJourneyStep(_userId, stepId);
    await _loadUserData(); // Rafraîchir les données
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre parcours écologique'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F3140),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserLevelCard(),
                  const SizedBox(height: 24),
                  _buildJourneyProgress(),
                  const SizedBox(height: 24),
                  _buildJourneyTimeline(),
                ],
              ),
            ),
      bottomNavigationBar: const CustomMenu(currentIndex: 2),
    );
  }
  
  Widget _buildUserLevelCard() {
    final nextLevelInfo = _userLevel < 10
        ? Provider.of<EcoJourneyService>(context).getLevelInfo(_userLevel + 1)
        : null;
    
    final pointsToNextLevel = nextLevelInfo != null
        ? nextLevelInfo.pointsRequired - _ecoPoints
        : 0;
    
    final progress = nextLevelInfo != null
        ? (_ecoPoints - _levelInfo!.pointsRequired) / 
          (nextLevelInfo.pointsRequired - _levelInfo!.pointsRequired)
        : 1.0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 10.0,
                  percent: _userLevel >= 10 ? 1.0 : progress,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nv. $_userLevel',
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
                        _levelInfo?.title ?? 'Niveau $_userLevel',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3140),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _levelInfo?.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Points: $_ecoPoints',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      if (nextLevelInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Prochain niveau: ${pointsToNextLevel} points restants',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (nextLevelInfo != null) ...[
              const SizedBox(height: 16),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: progress,
                progressColor: const Color(0xFF4CAF50),
                backgroundColor: Colors.grey.shade200,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildJourneyProgress() {
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
              'Progression globale',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearPercentIndicator(
                    lineHeight: 16.0,
                    percent: _journeyProgress,
                    center: Text(
                      '${(_journeyProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    progressColor: const Color(0xFF4CAF50),
                    backgroundColor: Colors.grey.shade200,
                    barRadius: const Radius.circular(8),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(_journeySteps.where((step) => step['isCompleted'] == true).length)} / ${_journeySteps.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Complétez toutes les étapes pour devenir un expert en écologie !',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildJourneyTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étapes du parcours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_journeySteps.length, (index) {
          final stepData = _journeySteps[index];
          final step = stepData['step'] as EcoJourneyStep;
          final isCompleted = stepData['isCompleted'] as bool;
          
          return _buildTimelineTile(
            step,
            isFirst: index == 0,
            isLast: index == _journeySteps.length - 1,
            isCompleted: isCompleted,
          );
        }),
        const SizedBox(height: 16),
        const Text(
          'Vos statistiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineTile(
    EcoJourneyStep step, {
    required bool isFirst,
    required bool isLast,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: LineStyle(
          color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          thickness: 3,
        ),
        afterLineStyle: LineStyle(
          color: Colors.grey.shade300,
          thickness: 3,
        ),
        indicatorStyle: IndicatorStyle(
          width: 30,
          height: 30,
          indicator: Container(
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : Icons.eco,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          padding: const EdgeInsets.all(8),
        ),
        endChild: Card(
          margin: const EdgeInsets.only(left: 16, right: 0),
          elevation: isCompleted ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
              width: isCompleted ? 1 : 0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF1F3140),
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Complété',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tâches:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                ),
                const SizedBox(height: 8),
                ...step.tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task,
                          style: TextStyle(
                            fontSize: 14,
                            color: isCompleted ? Colors.grey.shade700 : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                if (!isCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _completeStep(step.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Compléter cette étape'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 