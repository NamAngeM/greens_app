import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/models/challenge.dart';
import 'package:greens_app/controllers/community_controller.dart';

class CommunityHubView extends StatefulWidget {
  const CommunityHubView({Key? key}) : super(key: key);

  @override
  _CommunityHubViewState createState() => _CommunityHubViewState();
}

class _CommunityHubViewState extends State<CommunityHubView> with SingleTickerProviderStateMixin {
  final CommunityController _controller = Get.find<CommunityController>();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller.loadChallenges();
    _controller.loadLocalEvents();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Communauté',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Afficher les notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Défis'),
            Tab(text: 'Événements'),
            Tab(text: 'Communauté'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChallengesTab(),
          _buildEventsTab(),
          _buildCommunityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Créer un nouveau défi ou événement
          _showCreateOptions();
        },
        backgroundColor: AppColors.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChallengesTab() {
    return Obx(() {
      if (_controller.isLoadingChallenges.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_controller.challenges.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.group_work_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun défi disponible actuellement',
                style: AppStyles.subtitle1.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateChallengeDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Créer un défi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.challenges.length,
        itemBuilder: (context, index) {
          final challenge = _controller.challenges[index];
          return _buildChallengeCard(challenge);
        },
      );
    });
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;
    final progress = challenge.currentParticipants / challenge.targetParticipants;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showChallengeDetails(challenge),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: challenge.imagePath != null
                    ? DecorationImage(
                        image: NetworkImage(challenge.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: challenge.imagePath == null ? AppColors.primaryColor : null,
              ),
              child: challenge.imagePath == null
                  ? Center(
                      child: Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 48,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: AppStyles.headline.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: daysLeft > 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          daysLeft > 0 ? '$daysLeft jours restants' : 'Terminé',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: AppStyles.body2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${challenge.currentParticipants} participants',
                        style: AppStyles.body2,
                      ),
                      Text(
                        'Objectif: ${challenge.targetParticipants}',
                        style: AppStyles.body2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _controller.joinChallenge(challenge.id),
                        icon: const Icon(Icons.group_add),
                        label: const Text('Rejoindre'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _shareChallengeWithFriends(challenge),
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondaryColor,
                          side: BorderSide(color: AppColors.secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return Obx(() {
      if (_controller.isLoadingEvents.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_controller.localEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun événement local disponible',
                style: AppStyles.subtitle1.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_location),
                label: const Text('Créer un événement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.localEvents.length,
        itemBuilder: (context, index) {
          final event = _controller.localEvents[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.date.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              Text(
                                _getMonthAbbreviation(event.date.month),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: AppStyles.headline.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: AppStyles.body2.copyWith(color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event.startTime} - ${event.endTime}',
                                    style: AppStyles.body2.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: AppStyles.body2,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${event.attendees} participants',
                          style: AppStyles.body2.copyWith(color: Colors.grey),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _controller.joinEvent(event.id),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Participer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: BorderSide(color: AppColors.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCommunityTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_alt_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Fonctionnalité en développement',
            style: AppStyles.headline.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette section permettra de retrouver des utilisateurs\nnear de chez vous et de voir leur impact environnemental',
            style: AppStyles.body1.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active),
            label: const Text('Être notifié quand c\'est prêt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Créer',
              style: AppStyles.headline,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.flag, color: Colors.white),
              ),
              title: const Text('Créer un défi'),
              subtitle: const Text('Impliquez la communauté dans une action collective'),
              onTap: () {
                Navigator.pop(context);
                _showCreateChallengeDialog();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondaryColor,
                child: const Icon(Icons.event, color: Colors.white),
              ),
              title: const Text('Créer un événement local'),
              subtitle: const Text('Organisez une rencontre dans votre région'),
              onTap: () {
                Navigator.pop(context);
                // Afficher le dialogue de création d'événement
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accentColor,
                child: const Icon(Icons.help_outline, color: Colors.white),
              ),
              title: const Text('Demander de l\'aide'),
              subtitle: const Text('Sollicitez la communauté pour un projet écologique'),
              onTap: () {
                Navigator.pop(context);
                // Afficher le dialogue de demande d'aide
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChallengeDialog() {
    // Logique pour créer un nouveau défi
  }

  void _showChallengeDetails(Challenge challenge) {
    // Afficher les détails d'un défi
  }

  void _shareChallengeWithFriends(Challenge challenge) {
    // Partager un défi avec des amis
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Fév';
      case 3: return 'Mar';
      case 4: return 'Avr';
      case 5: return 'Mai';
      case 6: return 'Juin';
      case 7: return 'Juil';
      case 8: return 'Août';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Déc';
      default: return '';
    }
  }
} 