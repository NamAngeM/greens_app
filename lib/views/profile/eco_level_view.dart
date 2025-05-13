import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/eco_level_service.dart';
import 'package:greens_app/models/eco_level_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:greens_app/utils/app_router.dart';

class EcoLevelView extends StatefulWidget {
  const EcoLevelView({Key? key}) : super(key: key);

  @override
  State<EcoLevelView> createState() => _EcoLevelViewState();
}

class _EcoLevelViewState extends State<EcoLevelView> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final levelService = Provider.of<EcoLevelService>(context, listen: false);
    await levelService.initialize();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mon Niveau Écologique',
          style: TextStyle(
            color: Color(0xFF1F3140),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1F3140)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    final levelService = Provider.of<EcoLevelService>(context);
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF4CAF50),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLevelCard(levelService),
            const SizedBox(height: 24),
            _buildLevelProgress(levelService),
            const SizedBox(height: 24),
            _buildBenefits(levelService),
            const SizedBox(height: 24),
            _buildPointsHistory(levelService),
            const SizedBox(height: 24),
            _buildLeaderboard(levelService),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelCard(EcoLevelService levelService) {
    final Color primaryColor = _getLevelColor(levelService.levelColor);
    final level = levelService.userLevel;
    final levelIndex = level.index;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.7),
              primaryColor,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 45.0,
                  lineWidth: 10.0,
                  percent: levelService.progressToNextLevel,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nv. ${levelIndex + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        _getLevelIcon(levelService.levelIcon),
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  progressColor: Colors.white,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelService.userLevelTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        levelService.levelDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${levelService.userPoints} points',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelProgress(EcoLevelService levelService) {
    final nextLevel = levelService.nextLevel;
    final pointsToNext = levelService.pointsToNextLevel;
    final progress = levelService.progressToNextLevel;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nextLevel != null 
                ? 'Progression vers ${EcoLevelSystem.getLevelTitle(nextLevel)}' 
                : 'Félicitations, vous avez atteint le niveau maximum !',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
            const SizedBox(height: 16),
            if (nextLevel != null) ...[
              LinearPercentIndicator(
                lineHeight: 12.0,
                percent: progress,
                backgroundColor: Colors.grey.shade200,
                progressColor: const Color(0xFF4CAF50),
                barRadius: const Radius.circular(6),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    levelService.userLevelTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    EcoLevelSystem.getLevelTitle(nextLevel),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Il vous faut encore $pointsToNext points pour passer au niveau suivant.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expert Écologique',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Continuez à gagner des points pour maintenir votre statut et inspirer les autres.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefits(EcoLevelService levelService) {
    final benefits = levelService.levelBenefits;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avantages du niveau actuel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3140),
              ),
            ),
            const SizedBox(height: 16),
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            
            // Si l'utilisateur n'est pas expert, montrer les avantages du niveau suivant
            if (levelService.nextLevel != null) ...[
              const Divider(height: 32),
              Text(
                'Prochain niveau : ${EcoLevelSystem.getLevelTitle(levelService.nextLevel!)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3140),
                ),
              ),
              const SizedBox(height: 16),
              ...EcoLevelSystem.getLevelBenefits(levelService.nextLevel!).map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
    );
  }
  
  Widget _buildPointsHistory(EcoLevelService levelService) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: levelService.getPointsHistory(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }
        
        final history = snapshot.data ?? [];
        
        if (history.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historique des points',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3140),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigation vers l'historique complet
                      },
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...history.map((entry) {
                  final DateTime timestamp = entry['timestamp']?.toDate() ?? DateTime.now();
                  final String source = entry['source'] ?? 'unknown';
                  final int points = entry['points'] ?? 0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              _getSourceIcon(source),
                              color: const Color(0xFF4CAF50),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getSourceTitle(source),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+$points pts',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLeaderboard(EcoLevelService levelService) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: levelService.getLeaderboard(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }
        
        final leaderboard = snapshot.data ?? [];
        
        if (leaderboard.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Classement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3140),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigation vers le classement complet
                        Navigator.pushNamed(context, AppRoutes.leaderboard);
                      },
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...leaderboard.asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  final bool isCurrentUser = user['userId'] == levelService.currentUserId;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? const Color(0xFF4CAF50).withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: index < 3 
                                ? [Colors.amber, Colors.grey.shade300, Colors.brown.shade300][index].withOpacity(0.2)
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: index < 3 
                                    ? [Colors.amber.shade800, Colors.grey.shade700, Colors.brown.shade700][index]
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (user['photoURL'] != null)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(user['photoURL']),
                          )
                        else
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              user['username'].substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['username'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isCurrentUser ? const Color(0xFF4CAF50) : null,
                                ),
                              ),
                              Text(
                                user['levelTitle'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${user['points']} pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isCurrentUser ? const Color(0xFF4CAF50) : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: levelService.getUserRanking(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Erreur de classement');
                    }
                    
                    final rankingData = snapshot.data!;
                    final rank = rankingData['rank'] ?? 0;
                    final totalUsers = rankingData['totalUsers'] ?? 0;
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Votre position: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '#$rank / $totalUsers',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF4CAF50),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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
  
  Color _getLevelColor(String hexColor) {
    final colorHex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$colorHex', radix: 16));
  }
  
  IconData _getLevelIcon(String iconName) {
    switch (iconName) {
      case 'sprout':
        return Icons.local_florist;
      case 'spa':
        return Icons.spa;
      case 'eco':
        return Icons.eco;
      case 'park':
        return Icons.park;
      case 'forest':
        return Icons.forest;
      default:
        return Icons.eco;
    }
  }
  
  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'challenge':
        return Icons.emoji_events;
      case 'login':
        return Icons.login;
      case 'profile':
        return Icons.person;
      case 'community':
        return Icons.people;
      case 'purchase':
        return Icons.shopping_bag;
      case 'carbon':
        return Icons.co2;
      default:
        return Icons.star;
    }
  }
  
  String _getSourceTitle(String source) {
    switch (source) {
      case 'challenge':
        return 'Défi complété';
      case 'login':
        return 'Connexion quotidienne';
      case 'profile':
        return 'Profil complété';
      case 'community':
        return 'Participation communautaire';
      case 'purchase':
        return 'Achat écologique';
      case 'carbon':
        return 'Réduction empreinte carbone';
      default:
        return 'Points gagnés';
    }
  }
} 