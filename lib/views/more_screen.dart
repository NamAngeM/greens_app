import 'package:flutter/material.dart';
import '../services/eco_activity_service.dart';
import '../services/badge_service.dart';
import '../services/challenge_service.dart';
import '../models/eco_activity.dart';
import '../models/challenge.dart';
import '../models/badge.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final EcoActivityService _ecoActivityService = EcoActivityService();
  final BadgeService _badgeService = BadgeService();
  final ChallengeService _challengeService = ChallengeService();
  String userId = 'current_user_id'; // À remplacer par l'ID de l'utilisateur connecté

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plus'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Empreinte Carbone'),
              Tab(text: 'Badges'),
              Tab(text: 'Défis'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCarbonFootprintTab(),
            _buildBadgesTab(),
            _buildChallengesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintTab() {
    return FutureBuilder<Map<ActivityType, double>>(
      future: _ecoActivityService.getCarbonImpactByType(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final impactByType = snapshot.data ?? {};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImpactCard(
              'Transport',
              impactByType[ActivityType.transport] ?? 0,
              Icons.directions_bike,
            ),
            _buildImpactCard(
              'Alimentation',
              impactByType[ActivityType.food] ?? 0,
              Icons.restaurant,
            ),
            _buildImpactCard(
              'Énergie',
              impactByType[ActivityType.energy] ?? 0,
              Icons.power,
            ),
            _buildImpactCard(
              'Déchets',
              impactByType[ActivityType.waste] ?? 0,
              Icons.delete,
            ),
            _buildImpactCard(
              'Shopping',
              impactByType[ActivityType.shopping] ?? 0,
              Icons.shopping_bag,
            ),
          ],
        );
      },
    );
  }

  Widget _buildImpactCard(String title, double impact, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text('${impact.toStringAsFixed(2)} kg CO2'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigation vers le détail de l'impact
        },
      ),
    );
  }

  Widget _buildBadgesTab() {
    return FutureBuilder<List<Badge>>(
      future: _badgeService.getUserBadges(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final badges = snapshot.data ?? [];
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildBadgeCard(badge);
          },
        );
      },
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 48,
            color: badge.isUnlocked ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (badge.isUnlocked)
            Text(
              'Débloqué le ${badge.unlockedAt?.toString().split(' ')[0] ?? ''}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return FutureBuilder<List<Challenge>>(
      future: _challengeService.getUserChallenges(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final challenges = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return _buildChallengeCard(challenge);
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(challenge.title),
            subtitle: Text(challenge.description),
            trailing: _buildChallengeStatus(challenge.status),
          ),
          LinearProgressIndicator(
            value: challenge.currentValue / challenge.targetValue,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              challenge.status == ChallengeStatus.completed
                  ? Colors.green
                  : Colors.blue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${challenge.currentValue}/${challenge.targetValue}'),
                Text('${challenge.points} points'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeStatus(ChallengeStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case ChallengeStatus.notStarted:
        color = Colors.grey;
        icon = Icons.hourglass_empty;
        text = 'Non commencé';
        break;
      case ChallengeStatus.inProgress:
        color = Colors.blue;
        icon = Icons.play_arrow;
        text = 'En cours';
        break;
      case ChallengeStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Terminé';
        break;
      case ChallengeStatus.failed:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Échoué';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
} 