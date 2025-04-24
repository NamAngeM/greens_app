import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/eco_action_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../widgets/custom_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class QuickImpactActionsView extends StatefulWidget {
  const QuickImpactActionsView({Key? key}) : super(key: key);

  @override
  _QuickImpactActionsViewState createState() => _QuickImpactActionsViewState();
}

class _QuickImpactActionsViewState extends State<QuickImpactActionsView> with SingleTickerProviderStateMixin {
  final EcoActionController _ecoActionController = Get.put(EcoActionController());
  late TabController _tabController;
  final List<String> _actionCategories = ['Tous', 'Transport', 'Énergie', 'Alimentation', 'Consommation'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _actionCategories.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions rapides'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _actionCategories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: Column(
        children: [
          _buildDailyImpactHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _actionCategories.map((category) {
                return _buildActionsList(category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyImpactHeader() {
    return Obx(() {
      final dailyImpact = _ecoActionController.calculateDailyImpact(DateTime.now());
      final actionCount = _ecoActionController.getTodayActivityCount();
      
      return Container(
        padding: const EdgeInsets.all(16.0),
        color: AppColors.secondaryColor.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$actionCount',
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 24,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Text(
                  'Actions aujourd\'hui',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '${dailyImpact.toStringAsFixed(1)} kg',
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 24,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Text(
                  'CO₂ économisé',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionsList(String category) {
    return Obx(() {
      if (_ecoActionController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final actions = category == 'Tous'
          ? _ecoActionController.quickActions
          : _ecoActionController.quickActions
              .where((action) => action.type == category.toLowerCase())
              .toList();

      if (actions.isEmpty) {
        return Center(
          child: Text(
            'Aucune action disponible pour $category',
            style: AppStyles.bodyTextStyle,
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              onTap: () {
                _showActionDetailDialog(context, action);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          action.icon,
                          color: AppColors.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.title,
                                style: AppStyles.subheadingStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                action.description,
                                style: AppStyles.bodyTextStyle.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              '-${action.carbonImpact} kg CO₂',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppColors.successColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _ecoActionController.recordAction(action);
                              _showSuccessSnackbar(action);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Je l\'ai fait !'),
                          ),
                        ],
                      ),
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

  void _showActionDetailDialog(BuildContext context, QuickAction action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action.description,
                  style: AppStyles.bodyTextStyle,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Impact environnemental :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Réduction de ${action.carbonImpact} kg de CO₂'),
                const SizedBox(height: 16),
                const Text(
                  'Pourquoi c\'est important :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Chaque petit geste compte dans la lutte contre le changement climatique. Cette action contribue à réduire votre empreinte carbone quotidienne.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _ecoActionController.recordAction(action);
                _showSuccessSnackbar(action);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Je l\'ai fait !'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(QuickAction action) {
    Get.snackbar(
      'Action enregistrée !',
      'Bravo ! Vous avez économisé ${action.carbonImpact} kg de CO₂',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('À propos des actions rapides'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Les actions rapides vous permettent de faire une différence immédiate pour l\'environnement dans votre vie quotidienne.',
                ),
                SizedBox(height: 16),
                Text(
                  'Comment ça marche :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '1. Choisissez une action que vous avez réalisée aujourd\'hui\n'
                  '2. Appuyez sur "Je l\'ai fait !"\n'
                  '3. Votre impact est calculé et ajouté à votre bilan carbone\n'
                  '4. Continuez à faire des actions pour voir votre impact cumulé',
                ),
                SizedBox(height: 16),
                Text(
                  'Les données d\'impact carbone sont basées sur des moyennes et peuvent varier selon votre situation spécifique.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Compris !'),
            ),
          ],
        );
      },
    );
  }
} 