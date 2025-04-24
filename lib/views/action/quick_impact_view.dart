import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/controllers/eco_action_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:greens_app/widgets/custom_widgets.dart';
import 'package:intl/intl.dart';

class QuickImpactView extends StatefulWidget {
  const QuickImpactView({Key? key}) : super(key: key);

  @override
  _QuickImpactViewState createState() => _QuickImpactViewState();
}

class _QuickImpactViewState extends State<QuickImpactView> {
  final EcoActionController _controller = Get.put(EcoActionController());
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showFab) {
        setState(() {
          _showFab = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showFab) {
        setState(() {
          _showFab = true;
        });
      }
    }
  }

  Future<void> _loadData() async {
    await _controller.loadUserActivities();
  }

  void _showQuickActionDetails(QuickAction action) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(action.icon, size: 32, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action.title,
                    style: AppStyles.headingMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              action.description,
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Impact carbone: -${action.carbonImpact.toStringAsFixed(2)} kg CO₂',
                  style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _controller.recordQuickAction(action);
                Get.back();
                _showConfirmationSnackbar(action);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('J\'ai réalisé cette action'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showConfirmationSnackbar(QuickAction action) {
    Get.snackbar(
      'Action enregistrée',
      'Bravo ! Vous avez économisé ${action.carbonImpact.toStringAsFixed(2)} kg de CO₂',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions rapides'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showHistoryDialog();
            },
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: _loadData,
          child: _controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
        );
      }),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                _showWeeklyImpactSummary();
              },
              label: const Text('Mon impact'),
              icon: const Icon(Icons.insights),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTodaysSummary(),
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _controller.quickActions.length,
              itemBuilder: (context, index) {
                final action = _controller.quickActions[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _showQuickActionDetails(action),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getColorForActionType(action.type),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    action.icon,
                                    color: Colors.white,
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
                                        style: AppStyles.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '-${action.carbonImpact.toStringAsFixed(2)} kg CO₂',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysSummary() {
    final todayActions = _controller.userActivities.where(
      (activity) => activity.date.day == DateTime.now().day &&
          activity.date.month == DateTime.now().month &&
          activity.date.year == DateTime.now().year,
    ).toList();

    final todayImpact = todayActions.fold<double>(
      0,
      (sum, activity) => sum + activity.carbonImpact,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aujourd\'hui, ${DateFormat('d MMMM yyyy', 'fr_FR').format(DateTime.now())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impact carbone évité',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${todayImpact.toStringAsFixed(2)} kg CO₂',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Actions réalisées',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${todayActions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique des actions',
              style: AppStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _controller.userActivities.length > 10
                    ? 10
                    : _controller.userActivities.length,
                itemBuilder: (context, index) {
                  final activity = _controller.userActivities[index];
                  return ListTile(
                    leading: Icon(
                      _getIconForActivityType(activity.type),
                      color: _getColorForActionType(activity.type),
                    ),
                    title: Text(activity.description),
                    subtitle: Text(
                      DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(activity.date),
                    ),
                    trailing: Text(
                      '-${activity.carbonImpact.toStringAsFixed(2)} kg',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeeklyImpactSummary() {
    final impactByType = _controller.calculateWeeklyImpactByType();
    double totalImpact = 0;
    impactByType.forEach((key, value) => totalImpact += value);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon impact de la semaine',
              style: AppStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${totalImpact.toStringAsFixed(2)} kg CO₂ évités',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...impactByType.entries.map((entry) {
              final percentage = (entry.value / totalImpact * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForActivityType(entry.key),
                          color: _getColorForActionType(entry.key),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getActivityTypeName(entry.key),
                            style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(2)} kg (${percentage}%)',
                          style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / totalImpact,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getColorForActionType(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Naviguer vers la vue détaillée des statistiques
                // Get.toNamed(Routes.CARBON_DASHBOARD);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Voir tous mes impacts'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForActionType(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return Colors.blue;
      case ActivityType.food:
        return Colors.orange;
      case ActivityType.energy:
        return Colors.amber;
      case ActivityType.waste:
        return Colors.brown;
      case ActivityType.shopping:
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return Icons.directions_car;
      case ActivityType.food:
        return Icons.restaurant;
      case ActivityType.energy:
        return Icons.bolt;
      case ActivityType.waste:
        return Icons.delete;
      case ActivityType.shopping:
        return Icons.shopping_bag;
      default:
        return Icons.eco;
    }
  }

  String _getActivityTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return 'Transport';
      case ActivityType.food:
        return 'Alimentation';
      case ActivityType.energy:
        return 'Énergie';
      case ActivityType.waste:
        return 'Déchets';
      case ActivityType.shopping:
        return 'Achats';
      default:
        return 'Autre';
    }
  }
} 