import 'package:flutter/material.dart';
import 'dart:math' as math;

class EcoChallengeView extends StatefulWidget {
  const EcoChallengeView({Key? key}) : super(key: key);

  @override
  State<EcoChallengeView> createState() => _EcoChallengeViewState();
}

class _EcoChallengeViewState extends State<EcoChallengeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<EcoChallenge> _activeChallenges = [];
  final List<EcoChallenge> _completedChallenges = [];
  final List<EcoChallenge> _availableChallenges = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Simuler le chargement des défis
    _loadMockChallenges();
  }

  void _loadMockChallenges() {
    // Défis actifs
    _activeChallenges.addAll([
      EcoChallenge(
        id: '1',
        title: 'Zéro déchet pendant une semaine',
        description: 'Essayez de ne produire aucun déchet non recyclable pendant 7 jours.',
        category: ChallengeCategory.reduction,
        difficulty: ChallengeDifficulty.medium,
        pointsReward: 150,
        daysLeft: 4,
        progress: 0.42,
        steps: [
          'Utilisez uniquement des contenants réutilisables',
          'Achetez des produits sans emballage',
          'Compostez vos déchets organiques',
          'Refusez les pailles et ustensiles jetables'
        ],
      ),
      EcoChallenge(
        id: '2',
        title: 'Transport écologique',
        description: 'Utilisez uniquement des transports écologiques pour vos déplacements quotidiens.',
        category: ChallengeCategory.transport,
        difficulty: ChallengeDifficulty.easy,
        pointsReward: 100,
        daysLeft: 2,
        progress: 0.75,
        steps: [
          'Utilisez les transports en commun',
          'Privilégiez le vélo pour les courts trajets',
          'Pratiquez le covoiturage',
          'Marchez quand c\'est possible'
        ],
      ),
    ]);

    // Défis complétés
    _completedChallenges.addAll([
      EcoChallenge(
        id: '3',
        title: 'Semaine végétarienne',
        description: 'Adoptez une alimentation végétarienne pendant une semaine entière.',
        category: ChallengeCategory.alimentation,
        difficulty: ChallengeDifficulty.easy,
        pointsReward: 100,
        daysLeft: 0,
        progress: 1.0,
        steps: [
          'Découvrez des recettes végétariennes',
          'Remplacez la viande par des légumineuses',
          'Expérimentez avec des alternatives végétales',
          'Partagez vos repas préférés avec la communauté'
        ],
      ),
    ]);

    // Défis disponibles
    _availableChallenges.addAll([
      EcoChallenge(
        id: '4',
        title: 'Économies d\'énergie',
        description: 'Réduisez votre consommation d\'énergie domestique de 20%.',
        category: ChallengeCategory.energie,
        difficulty: ChallengeDifficulty.hard,
        pointsReward: 200,
        daysLeft: 30,
        progress: 0.0,
        steps: [
          'Utilisez des ampoules LED',
          'Éteignez les appareils en veille',
          'Réduisez l\'utilisation du chauffage/climatisation',
          'Lavez votre linge à basse température'
        ],
      ),
      EcoChallenge(
        id: '5',
        title: 'Jardinage écologique',
        description: 'Créez un petit jardin écologique sur votre balcon ou dans votre jardin.',
        category: ChallengeCategory.biodiversite,
        difficulty: ChallengeDifficulty.medium,
        pointsReward: 150,
        daysLeft: 30,
        progress: 0.0,
        steps: [
          'Choisissez des plantes locales',
          'Créez un compost',
          'Utilisez des méthodes naturelles contre les nuisibles',
          'Récupérez l\'eau de pluie'
        ],
      ),
      EcoChallenge(
        id: '6',
        title: 'Consommation responsable',
        description: 'Achetez uniquement des produits écologiques et éthiques pendant 2 semaines.',
        category: ChallengeCategory.consommation,
        difficulty: ChallengeDifficulty.medium,
        pointsReward: 150,
        daysLeft: 14,
        progress: 0.0,
        steps: [
          'Recherchez les labels écologiques',
          'Privilégiez les produits locaux',
          'Évitez les produits suremballés',
          'Achetez d\'occasion quand c\'est possible'
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startChallenge(EcoChallenge challenge) {
    setState(() {
      _availableChallenges.remove(challenge);
      _activeChallenges.add(challenge);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Défi "${challenge.title}" commencé !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _abandonChallenge(EcoChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner le défi ?'),
        content: Text('Êtes-vous sûr de vouloir abandonner le défi "${challenge.title}" ? Votre progression sera perdue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _activeChallenges.remove(challenge);
                _availableChallenges.add(challenge..progress = 0.0);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Défi abandonné'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }

  void _updateProgress(EcoChallenge challenge, double progress) {
    setState(() {
      challenge.progress = progress;
      if (progress >= 1.0) {
        _activeChallenges.remove(challenge);
        _completedChallenges.add(challenge);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Félicitations ! Vous avez terminé le défi "${challenge.title}" !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Défis Écologiques'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'Complétés'),
            Tab(text: 'Disponibles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChallengeList(_activeChallenges, isActive: true),
          _buildChallengeList(_completedChallenges, isCompleted: true),
          _buildChallengeList(_availableChallenges, isAvailable: true),
        ],
      ),
    );
  }

  Widget _buildChallengeList(List<EcoChallenge> challenges, {bool isActive = false, bool isCompleted = false, bool isAvailable = false}) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.checklist : (isCompleted ? Icons.emoji_events : Icons.add_task),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Aucun défi actif' : (isCompleted ? 'Aucun défi complété' : 'Aucun défi disponible'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (isActive) 
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(2),
                icon: const Icon(Icons.add),
                label: const Text('Commencer un défi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(
          challenge, 
          isActive: isActive, 
          isCompleted: isCompleted, 
          isAvailable: isAvailable,
        );
      },
    );
  }

  Widget _buildChallengeCard(EcoChallenge challenge, {bool isActive = false, bool isCompleted = false, bool isAvailable = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive 
              ? Colors.blue
              : isCompleted 
                  ? Colors.green
                  : Colors.grey[300]!,
          width: isActive || isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChallengeHeader(challenge, isActive, isCompleted),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(challenge.progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Étapes:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...challenge.steps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(step),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          _buildChallengeActions(challenge, isActive, isCompleted, isAvailable),
        ],
      ),
    );
  }

  Widget _buildChallengeHeader(EcoChallenge challenge, bool isActive, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blue.withOpacity(0.1)
            : isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _getCategoryIcon(challenge.category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildDifficultyIndicator(challenge.difficulty),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.pointsReward} pts',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (isActive && challenge.daysLeft > 0) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: challenge.daysLeft < 3 ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Plus que ${challenge.daysLeft} jour${challenge.daysLeft > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: challenge.daysLeft < 3 ? Colors.red : null,
                          fontWeight: challenge.daysLeft < 3 ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeActions(EcoChallenge challenge, bool isActive, bool isCompleted, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isActive) ...[
            OutlinedButton(
              onPressed: () => _abandonChallenge(challenge),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Abandonner'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _showProgressDialog(challenge),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Mettre à jour'),
            ),
          ] else if (isAvailable) ...[
            ElevatedButton(
              onPressed: () => _startChallenge(challenge),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Commencer'),
            ),
          ] else if (isCompleted) ...[
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text('Partager'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDifficultyIndicator(ChallengeDifficulty difficulty) {
    Color color;
    String label;

    switch (difficulty) {
      case ChallengeDifficulty.easy:
        color = Colors.green;
        label = 'Facile';
        break;
      case ChallengeDifficulty.medium:
        color = Colors.orange;
        label = 'Moyen';
        break;
      case ChallengeDifficulty.hard:
        color = Colors.red;
        label = 'Difficile';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getCategoryIcon(ChallengeCategory category) {
    IconData iconData;
    Color color;

    switch (category) {
      case ChallengeCategory.reduction:
        iconData = Icons.delete_outline;
        color = Colors.teal;
        break;
      case ChallengeCategory.transport:
        iconData = Icons.directions_bike;
        color = Colors.blue;
        break;
      case ChallengeCategory.alimentation:
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case ChallengeCategory.energie:
        iconData = Icons.bolt;
        color = Colors.amber;
        break;
      case ChallengeCategory.biodiversite:
        iconData = Icons.park;
        color = Colors.green;
        break;
      case ChallengeCategory.consommation:
        iconData = Icons.shopping_bag;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  void _showProgressDialog(EcoChallenge challenge) {
    double newProgress = challenge.progress;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour la progression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Défi: ${challenge.title}'),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.blue.withOpacity(0.2),
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withOpacity(0.3),
                valueIndicatorColor: Colors.blue,
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              child: Slider(
                value: newProgress,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: '${(newProgress * 100).round()}%',
                onChanged: (value) {
                  newProgress = value;
                  if (context.mounted) {
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(newProgress * 100).round()}% complété',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProgress(challenge, newProgress);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

enum ChallengeDifficulty {
  easy,
  medium,
  hard,
}

enum ChallengeCategory {
  reduction,
  transport,
  alimentation,
  energie,
  biodiversite, 
  consommation,
}

class EcoChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeCategory category;
  final ChallengeDifficulty difficulty;
  final int pointsReward;
  final List<String> steps;
  int daysLeft;
  double progress;

  EcoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.pointsReward,
    required this.daysLeft,
    required this.progress,
    required this.steps,
  });
} 