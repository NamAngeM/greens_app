import 'package:flutter/material.dart';
import 'package:greens_app/models/quick_impact_action_model.dart';
import 'package:greens_app/services/quick_impact_actions_service.dart';

class QuickImpactActionsWidget extends StatefulWidget {
  final String userId;
  final Function(int, double) onActionCompleted;

  const QuickImpactActionsWidget({
    Key? key,
    required this.userId,
    required this.onActionCompleted,
  }) : super(key: key);

  @override
  State<QuickImpactActionsWidget> createState() => _QuickImpactActionsWidgetState();
}

class _QuickImpactActionsWidgetState extends State<QuickImpactActionsWidget> {
  final QuickImpactActionsService _actionsService = QuickImpactActionsService();
  List<QuickImpactActionModel> _availableActions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final actions = await _actionsService.getRecommendedActionsForUser(widget.userId);
      setState(() {
        _availableActions = actions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gérer l'erreur ici
      print('Erreur lors du chargement des actions: $e');
    }
  }

  Future<void> _completeAction(QuickImpactActionModel action) async {
    try {
      final completed = await _actionsService.completeAction(
        widget.userId,
        action.id,
      );

      if (completed) {
        // Mettre à jour l'interface utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bravo! Vous avez gagné ${action.rewardPoints} points et économisé ${action.estimatedCarbonSaving.toStringAsFixed(1)} kg de CO2.'),
            backgroundColor: Colors.green,
          ),
        );

        // Notifier le parent que l'action a été complétée
        widget.onActionCompleted(action.rewardPoints, action.estimatedCarbonSaving);

        // Recharger les actions disponibles
        _loadActions();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: Impossible de marquer l\'action comme complétée.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableActions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Aucune action disponible pour le moment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadActions,
                child: const Text('Actualiser'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actions à impact rapide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Naviguer vers la page complète des actions
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => QuickImpactActionsPage()));
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: _availableActions.length,
            itemBuilder: (context, index) {
              final action = _availableActions[index];
              return _buildActionCard(context, action);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, QuickImpactActionModel action) {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière colorée avec catégorie et difficulté
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: action.category.color.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              action.category.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              action.category.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            action.difficulty.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+${action.rewardPoints}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Titre et description
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Informations sur l'impact et le temps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    Icons.eco,
                    '${action.estimatedCarbonSaving.toStringAsFixed(1)} kg CO2',
                    Colors.green.shade100,
                  ),
                  _buildInfoChip(
                    Icons.access_time,
                    '${action.estimatedTimeInMinutes} min',
                    Colors.blue.shade100,
                  ),
                ],
              ),
            ),
            // Bouton pour compléter l'action
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeAction(action),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: action.category.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('J\'ai réalisé cette action'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 