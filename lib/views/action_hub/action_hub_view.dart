import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/controllers/eco_action_controller.dart';
import 'package:greens_app/services/auth_service.dart';

class ActionHubView extends StatelessWidget {
  final AuthService _authService = Get.find<AuthService>();
  final EcoActionController _ecoActionController = Get.put(EcoActionController());

  ActionHubView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Actions Écologiques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildActionCategories(context),
              const SizedBox(height: 24),
              _buildDailyImpactCard(),
              const SizedBox(height: 24),
              Text(
                'Actions recommandées',
                style: AppStyles.headline,
              ),
              const SizedBox(height: 16),
              _buildRecommendedActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final userName = _authService.currentUser?.displayName ?? 'ami de la nature';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, $userName !',
              style: AppStyles.headline.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Que souhaitez-vous faire aujourd\'hui pour la planète ?',
              style: AppStyles.body1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/quick-impact'),
              icon: const Icon(Icons.flash_on),
              label: const Text('Action rapide'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories d\'actions',
          style: AppStyles.headline,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard(
              context,
              'Alimentation',
              Icons.restaurant,
              Colors.green,
              'food',
            ),
            _buildCategoryCard(
              context,
              'Transport',
              Icons.directions_car,
              Colors.blue,
              'transport',
            ),
            _buildCategoryCard(
              context,
              'Énergie',
              Icons.bolt,
              Colors.orange,
              'energy',
            ),
            _buildCategoryCard(
              context,
              'Recyclage',
              Icons.recycling,
              Colors.teal,
              'recycling',
            ),
            _buildCategoryCard(
              context,
              'Eau',
              Icons.water_drop,
              Colors.lightBlue,
              'water',
            ),
            _buildCategoryCard(
              context,
              'Numérique',
              Icons.devices,
              Colors.indigo,
              'digitalCleanup',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String category,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Naviguer vers la page de catégorie
          Get.toNamed('/category/$category');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyImpactCard() {
    return Obx(() {
      final dailyImpact = _ecoActionController.calculateDailyImpact(DateTime.now());
      final activityCount = _ecoActionController.getTodayActivityCount();
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Votre impact aujourd\'hui',
                    style: AppStyles.headline,
                  ),
                  const Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${dailyImpact.toStringAsFixed(1)} kg',
                        style: AppStyles.headline.copyWith(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CO₂ économisé',
                        style: AppStyles.body2,
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      Text(
                        '$activityCount',
                        style: AppStyles.headline.copyWith(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Actions réalisées',
                        style: AppStyles.body2,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/personal-dashboard'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Voir mes statistiques'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecommendedActions() {
    return Obx(() {
      if (_ecoActionController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_ecoActionController.quickActions.isEmpty) {
        return const Center(
          child: Text('Aucune action recommandée pour le moment'),
        );
      }
      
      // Prendre les 3 premières actions
      final recommendedActions = _ecoActionController.quickActions.take(3).toList();
      
      return Column(
        children: recommendedActions.map((action) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => Get.toNamed('/quick-impact'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getColorForType(action.type),
                      child: Icon(
                        action.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: AppStyles.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            action.description,
                            style: AppStyles.body2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '-${action.carbonImpact.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return Colors.blue;
      case ActivityType.energy:
        return Colors.orange;
      case ActivityType.food:
        return Colors.green;
      case ActivityType.waste:
        return Colors.brown;
      case ActivityType.water:
        return Colors.lightBlue;
      default:
        return Colors.purple;
    }
  }
} 