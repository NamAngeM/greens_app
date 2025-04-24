import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/controllers/eco_action_controller.dart';
import 'package:greens_app/widgets/custom_widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class QuickImpactActionsPage extends StatelessWidget {
  const QuickImpactActionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EcoActionController controller = Get.put(EcoActionController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions Rapides'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showActivityHistory(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadQuickActions();
            await controller.loadUserActivities();
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildImpactSummary(context, controller),
              const SizedBox(height: 24),
              _buildSectionTitle('Actions quotidiennes'),
              _buildActionsList(
                context, 
                controller.quickActions.where((a) => a.type == 'daily').toList(),
                controller
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Actions hebdomadaires'),
              _buildActionsList(
                context, 
                controller.quickActions.where((a) => a.type == 'weekly').toList(),
                controller
              ),
              const SizedBox(height: 24),
              _buildTipsSection(context),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _suggestRandomAction(context, Get.find<EcoActionController>()),
        child: const Icon(Icons.lightbulb_outline),
        tooltip: 'Suggestion aléatoire',
      ),
    );
  }

  Widget _buildImpactSummary(BuildContext context, EcoActionController controller) {
    final dailyImpact = controller.calculateDailyImpact();
    final weeklyImpact = controller.getWeeklyImpact();
    final todayCount = controller.getTodayActivityCount();
    final maxDaily = 100.0; // Impact maximum quotidien cible
    final dailyProgress = (dailyImpact / maxDaily).clamp(0.0, 1.0);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre impact aujourd\'hui',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 10.0,
                  percent: dailyProgress,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${dailyImpact.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const Text('points', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  progressColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem(
                      context, 
                      'Actions réalisées', 
                      '$todayCount',
                      Icons.check_circle_outline
                    ),
                    const SizedBox(height: 12),
                    _buildStatItem(
                      context, 
                      'Impact hebdo', 
                      '${weeklyImpact.toStringAsFixed(0)} pts',
                      Icons.calendar_today
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: dailyProgress,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              progressColor: Theme.of(context).primaryColor,
              barRadius: const Radius.circular(4),
              animation: true,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              'Objectif quotidien: ${maxDaily.toInt()} points',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionsList(
    BuildContext context, 
    List<QuickAction> actions,
    EcoActionController controller
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showActionDetails(context, action, controller),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getColorForAction(action.type).withOpacity(0.2),
                    radius: 28,
                    child: Icon(
                      action.icon,
                      color: _getColorForAction(action.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${action.carbonImpact.toInt()} pts',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
  }

  void _showActionDetails(
    BuildContext context, 
    QuickAction action,
    EcoActionController controller
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getColorForAction(action.type).withOpacity(0.2),
                  radius: 24,
                  child: Icon(
                    action.icon,
                    color: _getColorForAction(action.type),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    action.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              action.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Impact carbone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.eco,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${action.carbonImpact.toInt()} points',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type d\'action',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.type == 'daily' ? 'Quotidienne' : 'Hebdomadaire',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.recordAction(action);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'J\'ai réalisé cette action',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Annuler'),
            ),
            const SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
          ],
        ),
      ),
    );
  }

  void _showActivityHistory(BuildContext context, EcoActionController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Obx(() {
          final activities = controller.userActivities;
          
          if (activities.isEmpty) {
            return const Center(
              child: Text('Aucune activité enregistrée pour le moment'),
            );
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Historique de vos actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final DateTime date = DateTime.parse(activity.date);
                    final bool isToday = _isToday(date);
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorForAction(activity.type).withOpacity(0.2),
                        child: Icon(
                          _getIconForActivity(activity.title),
                          color: _getColorForAction(activity.type),
                        ),
                      ),
                      title: Text(activity.title),
                      subtitle: Text(
                        isToday 
                            ? 'Aujourd\'hui à ${_formatTime(date)}'
                            : 'Le ${_formatDate(date)}',
                      ),
                      trailing: Text(
                        '+${activity.impactPoints.toInt()} pts',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  void _suggestRandomAction(BuildContext context, EcoActionController controller) {
    if (controller.quickActions.isEmpty) return;
    
    final random = controller.quickActions[DateTime.now().millisecond % controller.quickActions.length];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Action suggérée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: _getColorForAction(random.type).withOpacity(0.2),
              radius: 36,
              child: Icon(
                random.icon,
                color: _getColorForAction(random.type),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              random.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              random.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Impact: ${random.carbonImpact.toInt()} points',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.recordAction(random);
              Navigator.pop(context);
            },
            child: const Text('Je le fais !'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conseil du jour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Économiser l\'eau',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saviez-vous qu\'un robinet qui fuit peut gaspiller jusqu\'à 120 litres d\'eau par jour? Vérifiez régulièrement vos robinets et réparez les fuites rapidement.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
    );
  }

  Color _getColorForAction(String type) {
    switch (type) {
      case 'daily':
        return Colors.green;
      case 'weekly':
        return Colors.blue;
      case 'monthly':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  IconData _getIconForActivity(String title) {
    if (title.contains('Transport')) return Icons.directions_bike;
    if (title.contains('Douche')) return Icons.shower;
    if (title.contains('Chauffage')) return Icons.thermostat;
    if (title.contains('Marché')) return Icons.shopping_basket;
    if (title.contains('Déchet')) return Icons.delete_outline;
    if (title.contains('Eau')) return Icons.water_drop;
    if (title.contains('Électricité')) return Icons.electric_bolt;
    if (title.contains('Alimentation')) return Icons.restaurant;
    return Icons.eco;
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatDate(DateTime date) {
    final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}