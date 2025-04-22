import 'package:flutter/material.dart';
import '../../user_profile/widgets/eco_habit_card.dart';

class EcoHabitsScreen extends StatelessWidget {
  const EcoHabitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitudes Écologiques'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Développez vos habitudes vertes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Petit à petit, changez votre quotidien pour un impact positif',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildHabitsList(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter une nouvelle habitude
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonctionnalité à venir !'),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context) {
    final List<Map<String, dynamic>> habitsList = [
      {
        'icon': Icons.water_drop_outlined,
        'title': 'Économie d\'eau',
        'description': 'Fermez le robinet pendant le brossage des dents pour économiser jusqu\'à 12 litres d\'eau.',
        'color': Colors.blue.shade50,
      },
      {
        'icon': Icons.eco_outlined,
        'title': 'Compostage',
        'description': 'Commencez à composter vos déchets organiques pour réduire votre empreinte carbone.',
        'color': Colors.green.shade50,
      },
      {
        'icon': Icons.bolt_outlined,
        'title': 'Économie d\'énergie',
        'description': 'Éteignez les lumières et les appareils électroniques lorsque vous quittez une pièce.',
        'color': Colors.yellow.shade50,
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Sacs réutilisables',
        'description': 'Utilisez des sacs en tissu réutilisables pour faire vos courses.',
        'color': Colors.brown.shade50,
      },
      {
        'icon': Icons.pedal_bike_outlined,
        'title': 'Transport écologique',
        'description': 'Privilégiez le vélo ou les transports en commun pour vos déplacements quotidiens.',
        'color': Colors.orange.shade50,
      },
      {
        'icon': Icons.local_dining_outlined,
        'title': 'Alimentation locale',
        'description': 'Achetez des produits locaux et de saison pour réduire l\'impact environnemental.',
        'color': Colors.purple.shade50,
      },
    ];

    return ListView.separated(
      itemCount: habitsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final habit = habitsList[index];
        return EcoHabitCard(
          icon: habit['icon'],
          title: habit['title'],
          description: habit['description'],
          color: habit['color'],
          onTap: () {
            // Action lors du tap sur une habitude
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(habit['title']),
                content: Text('Détails sur l\'habitude écologique "${habit['title']}" à venir prochainement !'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 