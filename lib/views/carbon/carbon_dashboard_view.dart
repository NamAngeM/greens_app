import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/services/eco_metrics_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/eco_app_bar.dart';
import 'package:greens_app/widgets/eco_loading_indicator.dart';
import 'package:greens_app/utils/date_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CarbonDashboardView extends StatefulWidget {
  const CarbonDashboardView({Key? key}) : super(key: key);

  @override
  _CarbonDashboardViewState createState() => _CarbonDashboardViewState();
}

class _CarbonDashboardViewState extends State<CarbonDashboardView> with SingleTickerProviderStateMixin {
  final EcoMetricsService _ecoMetricsService = EcoMetricsService();
  late TabController _tabController;
  final List<String> _periods = ['Semaine', 'Mois', 'Année'];
  String _selectedPeriod = 'Mois';
  bool _isLoading = false;
  List<CarbonFootprintModel> _footprints = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final controller = Provider.of<CarbonFootprintController>(context, listen: false);
        await controller.getUserFootprintHistory(userId);
        setState(() {
          _footprints = controller.userFootprints;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Tableau de Bord Carbone',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Évolution'),
            Tab(text: 'Conseils'),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: EcoLoadingIndicator()) 
        : TabBarView(
            controller: _tabController,
            children: [
              _buildContent(),
              _buildEvolutionTab(),
              _buildAdviceTab(),
            ],
          ),
    );
  }
  
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Texte d'introduction
              Text(
                'Mesures de Performance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Suivez l\'évolution de votre impact écologique et découvrez comment vous pouvez contribuer à un avenir plus durable.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Sélecteur de période
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              
              // Graphique comparatif principal
              _buildComparisonChart(),
              const SizedBox(height: 32),
              
              // Équivalences concrètes
              _buildConcreteEquivalents(),
              const SizedBox(height: 32),
              
              // Répartition détaillée
              _buildDetailedBreakdown(),
              const SizedBox(height: 32),
              
              // Recommandations personnalisées
              _buildRecommendations(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _periods.map((period) {
            final isSelected = period == _selectedPeriod;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildComparisonChart() {
    if (_footprints.isEmpty) {
      return _buildEmptyState('Aucune donnée disponible pour la période sélectionnée.');
    }
    
    // Filtrer les données selon la période sélectionnée
    final filteredData = _getFilteredData();
    
    // Calculer les données du graphique
    final List<FlSpot> spots = [];
    for (int i = 0; i < filteredData.length; i++) {
      spots.add(FlSpot(i.toDouble(), filteredData[i].totalScore));
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution de votre empreinte carbone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visualisez vos progrès au fil du temps',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: filteredData.length < 2 
                ? _buildEmptyState('Collectez plus de données pour afficher le graphique d\'évolution')
                : _buildLineChart(spots, filteredData),
            ),
            const SizedBox(height: 16),
            _buildCarbonSummary(filteredData),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineChart(List<FlSpot> spots, List<CarbonFootprintModel> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                String text = '';
                if (index >= 0 && index < data.length) {
                  if (_selectedPeriod == 'Semaine') {
                    text = DateFormat('E').format(data[index].date);
                  } else if (_selectedPeriod == 'Mois') {
                    text = DateFormat('d').format(data[index].date);
                  } else {
                    text = DateFormat('MMM').format(data[index].date);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${value.toInt()} kg',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(spots) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => 
                FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primaryColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryColor.withOpacity(0.3),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.0),
                ],
                stops: const [0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarbonSummary(List<CarbonFootprintModel> data) {
    if (data.isEmpty) return const SizedBox();
    
    final latestScore = data.last.totalScore;
    final averageScore = data.fold<double>(0, (sum, item) => sum + item.totalScore) / data.length;
    
    // Calculer la tendance (en pourcentage)
    double trendPercentage = 0;
    if (data.length > 1) {
      final previousScore = data.first.totalScore;
      trendPercentage = (latestScore - previousScore) / previousScore * 100;
    }
    
    final isImproving = trendPercentage < 0;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        
        if (isSmallScreen) {
          // Affichage vertical pour petits écrans
          return Column(
            children: [
              _buildSummaryItem(
                'Dernier enregistrement',
                '${latestScore.toStringAsFixed(1)} kg CO₂',
                Icons.calendar_today,
                AppColors.primaryColor,
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                'Moyenne',
                '${averageScore.toStringAsFixed(1)} kg CO₂',
                Icons.bar_chart,
                Colors.amber,
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                'Tendance',
                '${trendPercentage.abs().toStringAsFixed(1)}%',
                isImproving ? Icons.trending_down : Icons.trending_up,
                isImproving ? Colors.green : Colors.red,
              ),
            ],
          );
        } else {
          // Affichage horizontal pour écrans normaux
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Dernier',
                '${latestScore.toStringAsFixed(1)} kg CO₂',
                Icons.calendar_today,
                AppColors.primaryColor,
              ),
              _buildSummaryItem(
                'Moyenne',
                '${averageScore.toStringAsFixed(1)} kg CO₂',
                Icons.bar_chart,
                Colors.amber,
              ),
              _buildSummaryItem(
                'Tendance',
                '${trendPercentage.abs().toStringAsFixed(1)}%',
                isImproving ? Icons.trending_down : Icons.trending_up,
                isImproving ? Colors.green : Colors.red,
              ),
            ],
          );
        }
      }
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildConcreteEquivalents() {
    if (_footprints.isEmpty) {
      return _buildEmptyState('Ajoutez des données pour voir les équivalences concrètes.');
    }
    
    // Calculer l'impact total sur la période
    final filteredData = _getFilteredData();
    final totalImpact = filteredData.fold<double>(
      0, (sum, item) => sum + item.totalScore);
    
    // Calculer les équivalences
    final treesPlanted = _ecoMetricsService.calculateTreeEquivalent(totalImpact);
    final waterSaved = (totalImpact * 100).round(); // 100L par kg de CO2
    final carKm = (totalImpact * 4).round(); // 4km en voiture = 1kg de CO2
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Réel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre empreinte carbone convertie en équivalents concrets',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 350;
                
                if (isSmallScreen) {
                  // Affichage vertical pour petits écrans
                  return Column(
                    children: [
                      _buildEquivalentItem(
                        'Arbres plantés',
                        treesPlanted.toString(),
                        Icons.forest,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildEquivalentItem(
                        'Litres d\'eau économisés',
                        '$waterSaved L',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildEquivalentItem(
                        'Km en voiture évités',
                        '$carKm km',
                        Icons.directions_car,
                        Colors.orange,
                      ),
                    ],
                  );
                } else {
                  // Affichage horizontal pour écrans normaux
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEquivalentItem(
                        'Arbres plantés',
                        treesPlanted.toString(),
                        Icons.forest,
                        Colors.green,
                      ),
                      _buildEquivalentItem(
                        'Litres d\'eau économisés',
                        '$waterSaved L',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      _buildEquivalentItem(
                        'Km en voiture évités',
                        '$carKm km',
                        Icons.directions_car,
                        Colors.orange,
                      ),
                    ],
                  );
                }
              }
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ces chiffres représentent l\'impact positif de vos actions écologiques.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Naviguer vers une vue de méthodologie explicative
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('En savoir plus'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquivalentItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildDetailedBreakdown() {
    if (_footprints.isEmpty) {
      return _buildEmptyState('Ajoutez des données pour voir la répartition détaillée.');
    }
    
    // Utiliser la dernière empreinte pour la répartition
    final latestFootprint = _footprints.last;
    
    // Calculer les pourcentages pour le graphique
    final total = latestFootprint.totalScore;
    final transportPercent = (latestFootprint.transportScore / total * 100).round();
    final energyPercent = (latestFootprint.energyScore / total * 100).round();
    final foodPercent = (latestFootprint.foodScore / total * 100).round();
    final consumptionPercent = (latestFootprint.consumptionScore / total * 100).round();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition Détaillée',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Découvrez les domaines qui contribuent le plus à votre empreinte',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;
                
                if (isSmallScreen) {
                  // Affichage vertical pour petits écrans
                  return Column(
                    children: [
                      // D'abord les catégories
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBreakdownRow('Transport', transportPercent, Colors.blue),
                          const SizedBox(height: 8),
                          _buildBreakdownRow('Énergie', energyPercent, Colors.orange),
                          const SizedBox(height: 8),
                          _buildBreakdownRow('Alimentation', foodPercent, Colors.green),
                          const SizedBox(height: 8),
                          _buildBreakdownRow('Consommation', consumptionPercent, Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Puis le graphique
                      SizedBox(
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 25,
                            sections: _buildPieSections(
                              transportPercent, energyPercent, 
                              foodPercent, consumptionPercent,
                              latestFootprint
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Affichage horizontal pour écrans normaux
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBreakdownRow('Transport', transportPercent, Colors.blue),
                            const SizedBox(height: 8),
                            _buildBreakdownRow('Énergie', energyPercent, Colors.orange),
                            const SizedBox(height: 8),
                            _buildBreakdownRow('Alimentation', foodPercent, Colors.green),
                            const SizedBox(height: 8),
                            _buildBreakdownRow('Consommation', consumptionPercent, Colors.purple),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 150,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 25,
                              sections: _buildPieSections(
                                transportPercent, energyPercent, 
                                foodPercent, consumptionPercent,
                                latestFootprint
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
            ),
          ],
        ),
      ),
    );
  }
  
  List<PieChartSectionData> _buildPieSections(
    int transportPercent, 
    int energyPercent, 
    int foodPercent, 
    int consumptionPercent,
    CarbonFootprintModel footprint
  ) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: footprint.transportScore,
        title: '$transportPercent%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: footprint.energyScore,
        title: '$energyPercent%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: footprint.foodScore,
        title: '$foodPercent%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: footprint.consumptionScore,
        title: '$consumptionPercent%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
  
  Widget _buildBreakdownRow(String label, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendations() {
    if (_footprints.isEmpty) {
      return _buildEmptyState('Ajoutez des données pour recevoir des recommandations personnalisées.');
    }
    
    // Récupérer les recommandations de la dernière empreinte
    final latestFootprint = _footprints.last;
    final recommendations = latestFootprint.recommendations ?? [
      'Privilégiez les transports en commun ou le vélo pour vos déplacements quotidiens',
      'Réduisez votre consommation de viande rouge à 1-2 fois par semaine',
      'Éteignez les appareils électroniques plutôt que de les laisser en veille',
      'Achetez des produits locaux et de saison pour réduire l\'empreinte de votre alimentation',
    ];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommandations Personnalisées',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Basées sur votre profil écologique',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => _buildRecommendationItem(recommendation)).toList(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Naviguer vers une liste complète de recommandations
                },
                icon: const Icon(Icons.list),
                label: const Text('Voir toutes les recommandations'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.eco,
              color: AppColors.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<CarbonFootprintModel> _getFilteredData() {
    final now = DateTime.now();
    final List<CarbonFootprintModel> filteredData = [];
    
    switch (_selectedPeriod) {
      case 'Semaine':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filteredData.addAll(_footprints.where(
          (footprint) => footprint.date.isAfter(weekStart)
        ));
        break;
      case 'Mois':
        final monthStart = DateTime(now.year, now.month, 1);
        filteredData.addAll(_footprints.where(
          (footprint) => footprint.date.isAfter(monthStart)
        ));
        break;
      case 'Année':
        final yearStart = DateTime(now.year, 1, 1);
        filteredData.addAll(_footprints.where(
          (footprint) => footprint.date.isAfter(yearStart)
        ));
        break;
    }
    
    // Trier par date
    filteredData.sort((a, b) => a.date.compareTo(b.date));
    return filteredData;
  }
  
  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10.0;
    return spots.fold<double>(0, (max, spot) => spot.y > max ? spot.y : max);
  }
  
  Widget _buildEvolutionTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildComparisonChart(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdviceTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }
} 