import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/controllers/eco_action_controller.dart';
import 'package:greens_app/services/product_scan_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/widgets/custom_widgets.dart';

class ActionHubView extends StatefulWidget {
  const ActionHubView({Key? key}) : super(key: key);

  @override
  _ActionHubViewState createState() => _ActionHubViewState();
}

class _ActionHubViewState extends State<ActionHubView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EcoActionController _ecoActionController = Get.put(EcoActionController());
  final ProductScanService _productScanService = Get.find<ProductScanService>();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Agir'),
        backgroundColor: AppColors.primaryGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Actions Rapides'),
            Tab(text: 'Scanner Produit'),
            Tab(text: 'Mes Objectifs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickActionsTab(),
          _buildProductScannerTab(),
          _buildGoalsTab(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsTab() {
    return Obx(() {
      if (_ecoActionController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Quotidien',
              style: AppStyles.heading2,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildImpactStat(
                      'Actions aujourd\'hui', 
                      '${_ecoActionController.getTodayActivityCount()}',
                      Icons.check_circle
                    ),
                    _buildImpactStat(
                      'Impact CO₂', 
                      '${_ecoActionController.calculateDailyImpact().toStringAsFixed(1)} kg',
                      Icons.eco
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Actions Rapides',
              style: AppStyles.heading2,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _ecoActionController.quickActions.length,
                itemBuilder: (context, index) {
                  final action = _ecoActionController.quickActions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(action.icon, color: AppColors.primaryGreen),
                      title: Text(action.title),
                      subtitle: Text(action.description),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${action.carbonImpact.toStringAsFixed(1)} kg CO₂'),
                          TextButton(
                            onPressed: () => _ecoActionController.recordAction(action),
                            child: const Text('FAIT !'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImpactStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 30),
        const SizedBox(height: 8),
        Text(value, style: AppStyles.heading3),
        const SizedBox(height: 4),
        Text(title, style: AppStyles.bodySmall),
      ],
    );
  }

  Widget _buildProductScannerTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: AppColors.primaryGreen),
          const SizedBox(height: 20),
          Text(
            'Scanner un produit',
            style: AppStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Scannez le code-barres d\'un produit pour découvrir son impact écologique et des alternatives plus durables.',
            style: AppStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/scan-product'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('SCANNER MAINTENANT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Get.toNamed('/product-history'),
            child: const Text('Voir les produits scannés précédemment'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes Objectifs Écologiques',
            style: AppStyles.heading2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/goals'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('VOIR TOUS MES OBJECTIFS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Suggestions d\'objectifs',
            style: AppStyles.heading3,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildGoalSuggestionCard(
                  'Réduire ma consommation d\'eau',
                  'Économisez 20 litres d\'eau par jour en adoptant de nouvelles habitudes',
                  Icons.water_drop,
                ),
                _buildGoalSuggestionCard(
                  'Zéro déchet plastique',
                  'Éliminez progressivement le plastique à usage unique de votre quotidien',
                  Icons.delete_outline,
                ),
                _buildGoalSuggestionCard(
                  'Alimentation locale',
                  'Privilégiez les produits locaux pour réduire l\'empreinte carbone de votre alimentation',
                  Icons.location_on,
                ),
                _buildGoalSuggestionCard(
                  'Mobilité douce',
                  'Remplacez 50% de vos trajets en voiture par des alternatives écologiques',
                  Icons.directions_bike,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSuggestionCard(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.heading4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppStyles.body,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed('/add-goal', arguments: {'suggestion': title}),
                child: const Text('AJOUTER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 