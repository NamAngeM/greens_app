import 'package:flutter/material.dart';
import '../models/eco_challenge.dart';
import '../services/eco_challenge_service.dart';
import 'package:provider/provider.dart';

class EcoChallengesScreen extends StatelessWidget {
  final EcoChallengeService _challengeService = EcoChallengeService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Défis Écoresponsables'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Défis Actifs'),
              Tab(text: 'Mes Défis'),
              Tab(text: 'Calendrier'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActiveChallengesTab(),
            _MyChallengesTab(),
            _CalendarTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNewChallengeDialog(context),
          child: Icon(Icons.add),
          tooltip: 'Créer un nouveau défi',
        ),
      ),
    );
  }

  void _showNewChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer un nouveau défi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Titre du défi'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: [
                  'Plastique',
                  'Alimentation',
                  'Transport',
                  'Énergie',
                  'Déchets',
                ].map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) {},
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Durée (jours)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement challenge creation
              Navigator.pop(context);
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }
}

class _ActiveChallengesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EcoChallenge>>(
      stream: context.read<EcoChallengeService>().getActiveChallenges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Une erreur est survenue'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final challenges = snapshot.data!;
        if (challenges.isEmpty) {
          return Center(child: Text('Aucun défi actif pour le moment'));
        }

        return ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(challenge.category[0]),
                ),
                title: Text(challenge.title),
                subtitle: Text(challenge.description),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement join challenge
                  },
                  child: Text('Rejoindre'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MyChallengesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement user's active challenges
    return Center(child: Text('Mes défis en cours'));
  }
}

class _CalendarTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement calendar view
    return Center(child: Text('Calendrier des défis'));
  }
} 