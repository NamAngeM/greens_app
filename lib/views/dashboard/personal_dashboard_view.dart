import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/controllers/eco_action_controller.dart' hide ActivityType;
import 'package:greens_app/models/eco_activity.dart';
import 'package:greens_app/services/eco_activity_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/widgets/custom_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';

class PersonalDashboardView extends StatefulWidget {
  const PersonalDashboardView({Key? key}) : super(key: key);

  @override
  _PersonalDashboardViewState createState() => _PersonalDashboardViewState();
}

class _PersonalDashboardViewState extends State<PersonalDashboardView> with SingleTickerProviderStateMixin {
  final EcoActionController _ecoActionController = Get.put(EcoActionController());
  final EcoActivityService _ecoActivityService = Get.find<EcoActivityService>();
  final AuthController _authController = Get.find<AuthController>();
  final EcoBadgeController _badgeController = Get.put(EcoBadgeController());
  late TabController _tabController;
  
  RxBool isLoading = true.obs;
  RxDouble totalCarbonSaved = 0.0.obs;
  RxInt totalActions = 0.obs;
  RxMap<ActivityType, double> impactByType = <ActivityType, double>{}.obs;
  RxList<EcoActivity> recentActivities = <EcoActivity>[].obs;
  
  // Données simulées pour les graphiques
  final List<double> _weeklyImpact = [1.2, 0.8, 1.5, 2.0, 1.7, 1.3, 0.9];
  final List<double> _monthlyProgress = [15, 22, 28, 35, 42, 50, 55, 60, 65, 68, 72, 75];
  final Map<String, double> _impactByCategory = {
    'Transport': 35,
    'Alimentation': 25,
    'Énergie': 20,
    'Déchets': 15,
    'Autre': 5,
  };
  
  RxString _selectedPeriod = 'Semaine'.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Récupérer l'ID utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = _authController.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        _loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    isLoading.value = true;
    
    try {
      // Charger les statistiques
      final userId = _authController.currentUser?.uid ?? '';
      
      // Période pour les statistiques (30 derniers jours)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      
      // Total impact carbone
      totalCarbonSaved.value = await _ecoActivityService.getTotalCarbonImpact(userId);
      
      // Impact par type d'activité
      impactByType.value = await _ecoActivityService.getImpactByActivityType(
        userId, 
        startDate, 
        now
      );
      
      // Activités récentes
      recentActivities.value = await _ecoActivityService.getRecentActivities(userId);
      
      // Total des actions
      totalActions.value = recentActivities.length;
    } catch (e) {
      print('Erreur lors du chargement des données du tableau de bord: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Mon Impact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Activités'),
            Tab(text: 'Statistiques'),
          ],
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return TabBarView(
          controller: _tabController,
          children: [
            _buildSummaryTab(),
            _buildActivitiesTab(),
            _buildStatsTab(),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSummary(),
            const SizedBox(height: 20),
            _buildEcoScore(),
            const SizedBox(height: 20),
            _buildImpactOverTime(),
            const SizedBox(height: 20),
            _buildImpactByTypeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSummary() {
    return Obx(() {
      final user = _authController.currentUser;
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Utilisateur',
                      style: AppStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Éco-Héros • Niveau 3',
                      style: AppStyles.body.copyWith(color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Membre depuis ${user?.metadata?.creationTime?.month}/${user?.metadata?.creationTime?.year}',
                      style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEcoScore() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre Éco-Score',
              style: AppStyles.heading3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreIndicator(
                  score: 78,
                  title: 'Global',
                  color: AppColors.primaryGreen,
                ),
                _buildScoreIndicator(
                  score: 85,
                  title: 'Actions',
                  color: Colors.blue,
                ),
                _buildScoreIndicator(
                  score: 70,
                  title: 'Empreinte',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Vous faites mieux que 72% des utilisateurs dans votre région.',
              style: AppStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator({
    required int score,
    required String title,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '$score',
                  style: AppStyles.heading2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildImpactOverTime() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Impact au fil du temps',
                  style: AppStyles.heading3,
                ),
                Obx(() => DropdownButton<String>(
                  value: _selectedPeriod.value,
                  items: ['Jour', 'Semaine', 'Mois', 'Année']
                      .map((period) => DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedPeriod.value = value;
                    }
                  },
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
                )),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                final data = _selectedPeriod.value == 'Mois'
                    ? _monthlyProgress
                    : _weeklyImpact;
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            String text = '';
                            if (_selectedPeriod.value == 'Semaine') {
                              const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                              if (value.toInt() < days.length) {
                                text = days[value.toInt()];
                              }
                            } else if (_selectedPeriod.value == 'Mois') {
                              if (value.toInt() % 3 == 0 && value.toInt() < 12) {
                                final months = ['Jan', 'Avr', 'Juil', 'Oct'];
                                text = months[value.toInt() ~/ 3];
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                text,
                                style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
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
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(data.length, (index) {
                          return FlSpot(index.toDouble(), data[index]);
                        }),
                        isCurved: true,
                        color: AppColors.primaryGreen,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryGreen.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() => Center(
              child: Text(
                _selectedPeriod.value == 'Semaine'
                    ? 'Impact total cette semaine: 9.4 kg CO₂ évités'
                    : _selectedPeriod.value == 'Mois'
                        ? 'Impact total ce mois: 75 kg CO₂ évités'
                        : 'Impact total aujourd\'hui: 1.3 kg CO₂ évités',
                style: AppStyles.body,
                textAlign: TextAlign.center,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactByTypeCard() {
    if (impactByType.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact par catégorie',
              style: AppStyles.headline,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final entries = impactByType.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    
    return entries.map((entry) {
      final type = entry.key;
      final value = entry.value;
      final color = _getColorForActivityType(type);
      
      return PieChartSectionData(
        value: value,
        title: '${value.toStringAsFixed(1)}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
      );
    }).toList();
  }

  Widget _buildChartLegend() {
    final entries = impactByType.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColorForActivityType(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _getActivityTypeName(entry.key),
              style: AppStyles.body2,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActivitiesTab() {
    if (recentActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune activité enregistrée',
              style: AppStyles.subtitle1.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/quick-impact'),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentActivities.length,
      itemBuilder: (context, index) {
        final activity = recentActivities[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: _getColorForActivityType(activity.type),
              child: Icon(
                _getIconForActivityType(activity.type),
                color: Colors.white,
              ),
            ),
            title: Text(activity.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.description),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(activity.timestamp),
                  style: AppStyles.caption,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${activity.carbonImpact.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'CO₂',
                  style: AppStyles.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(
            'Répartition des Actions',
            _buildCategoryPieChart(),
            'Visualisez la répartition de vos actions écologiques par catégorie.',
          ),
          const SizedBox(height: 24.0),
          _buildStatsCard(
            'Impact Mensuel',
            _buildMonthlyLineChart(),
            'Suivez votre progression d\'impact carbone au fil des mois.',
          ),
          const SizedBox(height: 24.0),
          _buildStatsCard(
            'Objectifs Atteints',
            _buildGoalsProgressChart(),
            'Visualisez votre progression vers vos objectifs écologiques.',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, Widget chart, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.subheadingStyle,
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    return Obx(() {
      final activities = _ecoActionController.userActivities;
      
      if (activities.isEmpty) {
        return const Center(
          child: Text('Pas encore de données disponibles'),
        );
      }
      
      // Count activities by category
      final Map<String, int> categoryCounts = {};
      for (final activity in activities) {
        final category = activity.type.toString().split('.').last;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
      
      final pieData = categoryCounts.entries.map((entry) {
        final color = _getCategoryColor(entry.key);
        return PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${(entry.value / activities.length * 100).toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();
      
      return Column(
        children: [
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: pieData,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryCounts.keys.map((category) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: _getCategoryColor(category),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryDisplayName(category),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return 'Transport';
      case 'alimentation':
        return 'Alimentation';
      case 'energie':
        return 'Énergie';
      case 'consommation':
        return 'Consommation';
      default:
        return 'Autre';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Colors.blue;
      case 'alimentation':
        return Colors.green;
      case 'energie':
        return Colors.orange;
      case 'consommation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMonthlyLineChart() {
    return Obx(() {
      final activities = _ecoActionController.userActivities;
      
      if (activities.isEmpty) {
        return const Center(
          child: Text('Pas encore de données disponibles'),
        );
      }
      
      // Calculate monthly impact for the last 6 months
      final now = DateTime.now();
      final months = <MonthlyImpact>[];
      
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthName = DateFormat('MMM').format(month);
        
        final monthlyActivities = activities.where((activity) {
          final activityDate = activity.timestamp;
          return activityDate.year == month.year && activityDate.month == month.month;
        }).toList();
        
        double impact = 0;
        for (final activity in monthlyActivities) {
          impact += activity.carbonImpact;
        }
        
        months.add(MonthlyImpact(monthName, impact));
      }
      
      final spots = months.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.impact);
      }).toList();
      
      return LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        months[index].month,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGoalsProgressChart() {
    // This would ideally be connected to a goals system
    // For now, we'll show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: 0.75,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.successColor),
            strokeWidth: 10,
          ),
          const SizedBox(height: 16),
          const Text(
            '75% des objectifs atteints',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3 sur 4 objectifs complétés',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForActivityType(ActivityType type) {
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
      case ActivityType.recycling:
        return Colors.teal;
      case ActivityType.community:
        return Colors.purple;
      case ActivityType.digitalCleanup:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return Icons.directions_car;
      case ActivityType.food:
        return Icons.restaurant;
      case ActivityType.energy:
        return Icons.power;
      case ActivityType.waste:
        return Icons.delete;
      case ActivityType.water:
        return Icons.water_drop;
      case ActivityType.recycling:
        return Icons.recycling;
      case ActivityType.community:
        return Icons.people;
      case ActivityType.digitalCleanup:
        return Icons.cleaning_services;
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
      case ActivityType.water:
        return 'Eau';
      case ActivityType.recycling:
        return 'Recyclage';
      case ActivityType.community:
        return 'Communauté';
      case ActivityType.digitalCleanup:
        return 'Numérique';
      default:
        return 'Autre';
    }
  }
}

class DailyImpact {
  final String day;
  final double impact;
  
  DailyImpact(this.day, this.impact);
}

class MonthlyImpact {
  final String month;
  final double impact;
  
  MonthlyImpact(this.month, this.impact);
} 