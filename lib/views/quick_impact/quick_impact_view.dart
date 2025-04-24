import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/controllers/eco_action_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/widgets/custom_widgets.dart';

class QuickImpactView extends StatelessWidget {
  final EcoActionController controller = Get.put(EcoActionController());

  QuickImpactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Impact Rapide',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return Column(
            children: [
              _buildDailyImpactCard(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildActionsList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDailyImpactCard() {
    return Obx(() {
      final dailyImpact = controller.calculateDailyImpact(DateTime.now());
      final activityCount = controller.getTodayActivityCount();
      final weeklyImpact = controller.getWeeklyImpact();
      
      return Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Votre impact d\'aujourd\'hui',
                      style: AppStyles.heading2,
                    ),
                    Icon(
                      Icons.eco,
                      color: AppColors.accentColor,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'CO₂ économisé',
                      '${dailyImpact.toStringAsFixed(1)} kg',
                      Icons.co2,
                    ),
                    _buildStatColumn(
                      'Actions',
                      '$activityCount',
                      Icons.check_circle_outline,
                    ),
                    _buildStatColumn(
                      'Cette semaine',
                      '${weeklyImpact.toStringAsFixed(1)} kg',
                      Icons.date_range,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.secondaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.heading3.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.caption,
        ),
      ],
    );
  }

  Widget _buildActionsList() {
    return Obx(() {
      if (controller.quickActions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nature_people,
                size: 100,
                color: AppColors.accentColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune action rapide disponible pour le moment',
                style: AppStyles.heading3,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.quickActions.length,
        itemBuilder: (context, index) {
          final action = controller.quickActions[index];
          return _buildActionCard(action, context);
        },
      );
    });
  }

  Widget _buildActionCard(QuickAction action, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showActionDetails(action, context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _getColorForType(action.type),
                    radius: 24,
                    child: Icon(
                      action.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          style: AppStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action.description,
                          style: AppStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      'Impact: -${action.carbonImpact.toStringAsFixed(1)} kg CO₂',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppColors.accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.recordAction(action);
                      _showSuccessSnackbar(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return Colors.blue;
      case ActivityType.food:
        return Colors.green;
      case ActivityType.energy:
        return Colors.orange;
      case ActivityType.waste:
        return Colors.brown;
      case ActivityType.water:
        return Colors.lightBlue;
      case ActivityType.other:
        return AppColors.primaryColor;
      default:
        return AppColors.primaryColor;
    }
  }

  void _showActionDetails(QuickAction action, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getColorForType(action.type),
                      radius: 28,
                      child: Icon(
                        action.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        action.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: AppStyles.heading3,
                ),
                const SizedBox(height: 8),
                Text(
                  action.description,
                  style: AppStyles.bodyText,
                ),
                const SizedBox(height: 24),
                Text(
                  'Impact environnemental',
                  style: AppStyles.heading3,
                ),
                const SizedBox(height: 8),
                _buildImpactBox(action),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.recordAction(action);
                      Navigator.pop(context);
                      _showSuccessSnackbar(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'J\'ai fait cette action',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImpactBox(QuickAction action) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.co2,
                color: AppColors.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Réduction de CO₂',
                style: AppStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cette action permet d\'économiser environ ${action.carbonImpact.toStringAsFixed(1)} kg de CO₂.',
            style: AppStyles.caption,
          ),
          const SizedBox(height: 16),
          Text(
            'Équivalent à :',
            style: AppStyles.heading3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildEquivalencyItem(
            Icons.directions_car,
            '${(action.carbonImpact / 0.2).toStringAsFixed(1)} km en voiture',
          ),
          _buildEquivalencyItem(
            Icons.lightbulb,
            '${(action.carbonImpact * 3).toStringAsFixed(1)} heures d\'ampoule LED',
          ),
          _buildEquivalencyItem(
            Icons.restaurant,
            '${(action.carbonImpact / 7).toStringAsFixed(1)} repas végétariens vs carnés',
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalencyItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Action enregistrée ! Merci pour votre contribution.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}