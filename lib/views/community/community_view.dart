import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({Key? key}) : super(key: key);

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialiser les contrôleurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final communityController = Provider.of<CommunityController>(context, listen: false);
      communityController.getChallenges();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final communityController = Provider.of<CommunityController>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Défis communautaires'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'À venir'),
            Tab(text: 'Mes défis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet des défis actifs
          _buildActiveChallengesTab(communityController, authController),
          
          // Onglet des défis à venir
          _buildUpcomingChallengesTab(communityController, authController),
          
          // Onglet des défis de l'utilisateur
          _buildUserChallengesTab(communityController, authController),
        ],
      ),
    );
  }

  Widget _buildActiveChallengesTab(CommunityController controller, AuthController authController) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final activeChallenges = controller.getActiveChallenges();
    
    if (activeChallenges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun défi actif pour le moment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeChallenges.length,
      itemBuilder: (context, index) {
        final challenge = activeChallenges[index];
        return _buildChallengeCard(challenge, controller, authController);
      },
    );
  }

  Widget _buildUpcomingChallengesTab(CommunityController controller, AuthController authController) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final upcomingChallenges = controller.getUpcomingChallenges();
    
    if (upcomingChallenges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun défi à venir pour le moment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingChallenges.length,
      itemBuilder: (context, index) {
        final challenge = upcomingChallenges[index];
        return _buildChallengeCard(challenge, controller, authController);
      },
    );
  }

  Widget _buildUserChallengesTab(CommunityController controller, AuthController authController) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (authController.currentUser == null) {
      return const Center(
        child: Text('Vous devez être connecté pour voir vos défis'),
      );
    }
    
    final userChallenges = controller.getUserChallenges(authController.currentUser!.uid);
    
    if (userChallenges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Vous n\'avez pas encore rejoint de défis',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userChallenges.length,
      itemBuilder: (context, index) {
        final challenge = userChallenges[index];
        return _buildChallengeCard(challenge, controller, authController);
      },
    );
  }

  Widget _buildChallengeCard(CommunityChallenge challenge, CommunityController controller, AuthController authController) {
    final bool hasJoined = authController.currentUser != null && 
                          challenge.participants.contains(authController.currentUser!.uid);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du défi
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: challenge.imageUrl.isNotEmpty
                ? Image.network(
                    challenge.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 50,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(challenge.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(challenge.status),
                    style: TextStyle(
                      color: _getStatusColor(challenge.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Titre et description
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  challenge.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dates
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Du ${DateFormat('dd/MM/yyyy').format(challenge.startDate)} au ${DateFormat('dd/MM/yyyy').format(challenge.endDate)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Participants
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${challenge.participantsCount} / ${challenge.targetParticipants} participants',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Récompense
                Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Récompense: ${challenge.carbonPointsReward} points carbone',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Barre de progression
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progression: ${(challenge.participantsCount / challenge.targetParticipants * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: challenge.participantsCount / challenge.targetParticipants,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Bouton pour rejoindre/quitter
                if (authController.currentUser != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasJoined
                          ? () => _leaveChallenge(context, challenge.id, controller, authController)
                          : () => _joinChallenge(context, challenge.id, controller, authController),
                      icon: Icon(hasJoined ? Icons.exit_to_app : Icons.group_add_outlined),
                      label: Text(hasJoined ? 'Quitter le défi' : 'Rejoindre le défi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasJoined ? Colors.red : AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _joinChallenge(BuildContext context, String challengeId, CommunityController controller, AuthController authController) {
    if (authController.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour rejoindre un défi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    controller.joinChallenge(challengeId, authController.currentUser!.uid).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le défi avec succès'),
            backgroundColor: AppColors.secondaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez déjà rejoint ce défi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _leaveChallenge(BuildContext context, String challengeId, CommunityController controller, AuthController authController) {
    if (authController.currentUser == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le défi'),
        content: const Text('Êtes-vous sûr de vouloir quitter ce défi ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.leaveChallenge(challengeId, authController.currentUser!.uid).then((success) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vous avez quitté le défi'),
                      backgroundColor: AppColors.secondaryColor,
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.upcoming:
        return Colors.blue;
      case ChallengeStatus.active:
        return Colors.green;
      case ChallengeStatus.completed:
        return Colors.purple;
    }
  }

  String _getStatusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.upcoming:
        return 'À venir';
      case ChallengeStatus.active:
        return 'En cours';
      case ChallengeStatus.completed:
        return 'Terminé';
    }
  }
}