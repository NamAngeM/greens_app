import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_digital_twin_model.dart';
import 'package:greens_app/services/eco_digital_twin_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/widgets/twin_avatar_widget.dart';
import 'package:greens_app/widgets/eco_impact_metric_card.dart';
import 'package:greens_app/widgets/eco_action_history_card.dart';
import 'package:greens_app/widgets/eco_prediction_card.dart';

class EcoDigitalTwinView extends StatefulWidget {
  const EcoDigitalTwinView({Key? key}) : super(key: key);

  @override
  State<EcoDigitalTwinView> createState() => _EcoDigitalTwinViewState();
}

class _EcoDigitalTwinViewState extends State<EcoDigitalTwinView> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDigitalTwin();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Charger le jumeau numérique écologique
  Future<void> _loadDigitalTwin() async {
    final userId = Provider.of<AuthController>(context, listen: false).currentUser?.uid;
    if (userId == null) return;
    
    final twinService = Provider.of<EcoDigitalTwinService>(context, listen: false);
    await twinService.loadOrCreateDigitalTwin(userId);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon jumeau écologique'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigation vers les paramètres du jumeau
              // Navigator.pushNamed(context, AppRoutes.digitalTwinSettings);
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Consumer<EcoDigitalTwinService>(
            builder: (context, twinService, child) {
              final twin = twinService.digitalTwin;
              
              if (twin == null) {
                return const Center(
                  child: Text('Erreur lors du chargement du jumeau écologique'),
                );
              }
              
              return Column(
                children: [
                  // Avatar du jumeau numérique
                  TwinAvatarWidget(
                    twin: twin,
                    statusMessage: twinService.generateStatusMessage(),
                  ),
                  
                  // Onglets pour les différentes sections
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primaryColor,
                      tabs: const [
                        Tab(text: 'Impact'),
                        Tab(text: 'Actions'),
                        Tab(text: 'Prédictions'),
                      ],
                    ),
                  ),
                  
                  // Contenu des onglets
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Onglet Impact
                        _buildImpactTab(twin),
                        
                        // Onglet Actions
                        _buildActionsTab(twin),
                        
                        // Onglet Prédictions
                        _buildPredictionsTab(twin),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
  
  // Onglet Impact
  Widget _buildImpactTab(EcoDigitalTwinModel twin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre impact environnemental',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Cartes d'impact
          EcoImpactMetricCard(
            icon: Icons.eco,
            title: 'CO₂ économisé',
            value: twin.environmentalImpact.carbonSaved,
            unit: 'kg',
            subtitle: 'Impact direct sur le climat',
            color: AppColors.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          EcoImpactMetricCard(
            icon: Icons.park,
            title: 'Arbres équivalents',
            value: twin.environmentalImpact.treeEquivalent,
            unit: 'arbres',
            subtitle: 'Capacité d\'absorption équivalente',
            color: Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          EcoImpactMetricCard(
            icon: Icons.water_drop,
            title: 'Eau économisée',
            value: twin.environmentalImpact.waterSaved / 1000, // Conversion en m³
            unit: 'm³',
            subtitle: 'Économie en ressources hydriques',
            color: Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // Niveau écologique
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Niveau écologique: ${twin.ecoLevel}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: twin.levelProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progression: ${(twin.levelProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Onglet Actions
  Widget _buildActionsTab(EcoDigitalTwinModel twin) {
    // Trier les actions par date, les plus récentes en premier
    final sortedActions = List<EcoAction>.from(twin.ecoActions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sortedActions.isEmpty
      ? const Center(
          child: Text(
            'Aucune action écologique enregistrée.\nCommencez à utiliser l\'application pour voir votre historique !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedActions.length,
          itemBuilder: (context, index) {
            return EcoActionHistoryCard(action: sortedActions[index]);
          },
        );
  }
  
  // Onglet Prédictions
  Widget _buildPredictionsTab(EcoDigitalTwinModel twin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prédictions et projections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Potentiel de réduction carbone
          EcoPredictionCard(
            title: 'Potentiel de réduction carbone',
            value: twin.predictions['carbonReductionPotential'] as double,
            unit: '%',
            description: 'Réduction potentielle de votre empreinte carbone',
            icon: Icons.trending_down,
            color: Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          // Projection pour le mois prochain
          EcoPredictionCard(
            title: 'Projection pour le mois prochain',
            value: twin.predictions['nextMonthProjection'] as double,
            unit: 'kg CO₂',
            description: 'Économies de CO₂ prévues si vous maintenez vos habitudes',
            icon: Icons.calendar_month,
            color: AppColors.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // Amélioration potentielle du score
          EcoPredictionCard(
            title: 'Amélioration du score écologique',
            value: (twin.predictions['ecoScoreImprovement'] as double) * 100,
            unit: '%',
            description: 'Amélioration potentielle de votre niveau écologique',
            icon: Icons.star,
            color: Colors.amber,
          ),
          
          const SizedBox(height: 24),
          
          // Conseil personnalisé
          Consumer<EcoDigitalTwinService>(
            builder: (context, service, child) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lightbulb,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Conseil personnalisé',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service.getPersonalizedTip(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 