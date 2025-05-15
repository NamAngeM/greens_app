import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../models/community_challenge_model.dart';
import '../widgets/challenge_card.dart';
import '../widgets/leaderboard_widget.dart';
import '../controllers/community_challenge_controller.dart';
import 'challenge_detail_screen.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class CommunityChallengesScreen extends StatefulWidget {
  const CommunityChallengesScreen({Key? key}) : super(key: key);

  @override
  State<CommunityChallengesScreen> createState() => _CommunityChallengesScreenState();
}

class _CommunityChallengesScreenState extends State<CommunityChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  String _selectedCategory = 'Tous';
  
  final List<String> _categories = [
    'Tous',
    'Alimentation',
    'Transport',
    'Énergie',
    'Déchets',
    'Consommation'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Charger les défis
    Future.microtask(() {
      Provider.of<CommunityChallengeController>(context, listen: false).loadChallenges();
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
    final challengeController = Provider.of<CommunityChallengeController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Défis Communautaires'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Défis'),
            Tab(text: 'Classement'),
            Tab(text: 'Mes défis'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Onglet Défis
              _buildChallengesTab(challengeController),
              
              // Onglet Classement - commented out to fix compilation errors
              Container(
                child: Center(
                  child: Text('Leaderboard temporarily disabled'),
                ),
              ),
              // LeaderboardWidget(
              //   leaderboard: challengeController.leaderboard,
              //   userRanking: challengeController.userRanking,
              // ),
              
              // Onglet Mes défis
              _buildMyChallengesTab(challengeController),
            ],
          ),
          
          // Effet de confetti pour les célébrations
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/community-challenges/create');
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChallengesTab(CommunityChallengeController controller) {
    final filteredChallenges = _selectedCategory == 'Tous'
        ? controller.availableChallenges
        : controller.availableChallenges
            .where((challenge) => challenge.category == _selectedCategory)
            .toList();
    
    return Column(
      children: [
        // Filtres par catégorie
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primaryColor.withOpacity(0.3),
                    checkmarkColor: AppColors.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Liste des défis
        Expanded(
          child: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredChallenges.isEmpty
                  ? const Center(
                      child: Text('Aucun défi disponible dans cette catégorie.'),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.loadChallenges(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredChallenges.length,
                        itemBuilder: (context, index) {
                          final challenge = filteredChallenges[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ChallengeCard(
                              challenge: challenge,
                              onTap: () {
                                _navigateToChallengeDetail(challenge);
                              },
                              onJoin: () {
                                _joinChallenge(challenge);
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMyChallengesTab(CommunityChallengeController controller) {
    final activeChallenges = controller.userChallenges.where((c) => !c.completed).toList();
    final completedChallenges = controller.userChallenges.where((c) => c.completed).toList();
    
    return controller.isLoading
        ? const Center(child: CircularProgressIndicator())
        : controller.userChallenges.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vous n\'avez pas encore rejoint de défis.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _tabController.animateTo(0);
                      },
                      child: const Text('Découvrir les défis'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => controller.loadUserChallenges(),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (activeChallenges.isNotEmpty) ...[
                      const Text(
                        'Défis en cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...activeChallenges.map((challenge) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ChallengeCard(
                          challenge: challenge,
                          onTap: () => _navigateToChallengeDetail(challenge),
                          showJoinButton: false,
                          showProgress: true,
                        ),
                      )),
                    ],
                    
                    if (completedChallenges.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Défis complétés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...completedChallenges.map((challenge) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ChallengeCard(
                          challenge: challenge,
                          onTap: () => _navigateToChallengeDetail(challenge),
                          showJoinButton: false,
                          showProgress: true,
                          isCompleted: true,
                        ),
                      )),
                    ],
                  ],
                ),
              );
  }

  void _navigateToChallengeDetail(CommunityChallenge challenge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challenge: challenge),
      ),
    );
  }

  Future<void> _joinChallenge(CommunityChallenge challenge) async {
    final controller = Provider.of<CommunityChallengeController>(context, listen: false);
    
    try {
      await controller.joinChallenge(challenge.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous avez rejoint le défi: ${challenge.title}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Voir',
              textColor: Colors.white,
              onPressed: () {
                _tabController.animateTo(2); // Aller à l'onglet "Mes défis"
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos des défis'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Relevez des défis écologiques ensemble !',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Les défis communautaires vous permettent de participer à des actions concrètes pour la planète, seul ou avec d\'autres utilisateurs.',
              ),
              SizedBox(height: 8),
              Text(
                'Chaque défi relevé vous rapporte des points et des badges, et contribue à votre impact positif sur l\'environnement.',
              ),
              SizedBox(height: 12),
              Text(
                'Fonctionnement :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Rejoignez un défi existant ou créez le vôtre'),
              Text('• Partagez votre progression avec la communauté'),
              Text('• Gagnez des récompenses en relevant les objectifs'),
              Text('• Invitez vos amis à participer'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris !'),
          ),
        ],
      ),
    );
  }
  
  void showCelebration() {
    _confettiController.play();
  }
} 