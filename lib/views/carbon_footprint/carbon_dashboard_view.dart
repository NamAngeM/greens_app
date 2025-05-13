import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class CarbonDashboardView extends StatefulWidget {
  const CarbonDashboardView({Key? key}) : super(key: key);

  @override
  State<CarbonDashboardView> createState() => _CarbonDashboardViewState();
}

class _CarbonDashboardViewState extends State<CarbonDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _communityComparison = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
    
    final authController = Provider.of<AuthController>(context, listen: false);
    final carbonController = Provider.of<CarbonFootprintController>(context, listen: false);
    
    if (authController.currentUser != null) {
      await carbonController.loadUserFootprintData(authController.currentUser!.uid);
      _communityComparison = await carbonController.compareWithCommunity(authController.currentUser!.uid);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final carbonController = Provider.of<CarbonFootprintController>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mon Empreinte Carbone',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Détails'),
            Tab(text: 'Conseils'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Onglet Résumé
                _buildSummaryTab(carbonController),
                
                // Onglet Détails
                _buildDetailsTab(carbonController),
                
                // Onglet Conseils
                _buildTipsTab(carbonController),
              ],
            ),
    );
  }
  
  Widget _buildSummaryTab(CarbonFootprintController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec les totaux
          _buildCarbonSummaryHeader(controller),
          
          const SizedBox(height: 24),
          
          // Graphique de répartition par catégorie
          _buildCategoryBreakdownChart(controller),
          
          const SizedBox(height: 24),
          
          // Comparaison avec la communauté
          _buildCommunityComparison(),
          
          const SizedBox(height: 24),
          
          // Progrès vers l'objectif
          _buildGoalProgress(controller),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildCarbonSummaryHeader(CarbonFootprintController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Votre empreinte carbone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCarbonStat(
                'Cette semaine', 
                '${controller.weeklyTotal.toStringAsFixed(1)} kg',
                Icons.calendar_today_outlined,
              ),
              _buildCarbonStat(
                'Ce mois', 
                '${controller.monthlyTotal.toStringAsFixed(1)} kg',
                Icons.date_range_outlined,
              ),
              _buildCarbonStat(
                'Cette année', 
                '${controller.yearlyTotal.toStringAsFixed(1)} kg',
                Icons.calendar_view_month_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarbonStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryBreakdownChart(CarbonFootprintController controller) {
    final monthlyCarbonStats = controller.monthlyCarbonStats;
    
    if (monthlyCarbonStats.isEmpty) {
      return const Center(
        child: Text(
          'Pas encore de données ce mois-ci',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Impact par catégorie ce mois-ci',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Graphique en barres
              Expanded(
                flex: 7,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calculateMaxY(monthlyCarbonStats),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(showTitles: true),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (value) {
                          final categories = monthlyCarbonStats.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < categories.length) {
                            return _shortenCategory(categories[value.toInt()]);
                          }
                          return '';
                        },
                        rotateAngle: 45,
                      ),
                    ),
                    barGroups: _createBarGroups(monthlyCarbonStats),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  double _calculateMaxY(Map<String, double> stats) {
    double max = 0;
    stats.values.forEach((value) {
      if (value > max) max = value;
    });
    return max * 1.2; // Ajouter 20% d'espace en haut
  }
  
  List<BarChartGroupData> _createBarGroups(Map<String, double> stats) {
    final List<Color> barColors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFFC107),
      const Color(0xFFFF5722),
      const Color(0xFF9C27B0),
    ];
    
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    
    stats.forEach((category, value) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              y: value,
              colors: [barColors[index % barColors.length]],
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
      index++;
    });
    
    return barGroups;
  }
  
  String _shortenCategory(String category) {
    if (category.length <= 4) return category;
    return category.substring(0, 4);
  }
  
  Widget _buildCommunityComparison() {
    if (_communityComparison.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final userTotal = _communityComparison['userTotal'] as double;
    final communityAverage = _communityComparison['communityAverage'] as double;
    final percentile = _communityComparison['percentile'] as int;
    final betterThanAverage = _communityComparison['betterThanAverage'] as bool;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comparaison avec la communauté',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildComparisonItem(
                    'Votre impact',
                    '${userTotal.toStringAsFixed(1)} kg',
                    betterThanAverage ? Colors.green : Colors.orange,
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey.shade200,
                  ),
                  _buildComparisonItem(
                    'Moyenne',
                    '${communityAverage.toStringAsFixed(1)} kg',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Barre de percentile
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vous êtes plus écologique que $percentile% des utilisateurs',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentile / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        betterThanAverage ? Colors.green : Colors.orange,
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildComparisonItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalProgress(CarbonFootprintController controller) {
    // Objectif fictif pour l'exemple (pourrait être configurable par l'utilisateur)
    const monthlyGoal = 100.0;
    final currentProgress = controller.monthlyTotal;
    final progressPercent = (currentProgress / monthlyGoal).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre objectif mensuel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Objectif: 100 kg CO₂',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progressPercent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressPercent < 0.8 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressPercent < 0.8 ? Colors.green : Colors.orange,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Consommation actuelle: ${currentProgress.toStringAsFixed(1)} kg CO₂',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailsTab(CarbonFootprintController controller) {
    final footprints = controller.userFootprints;
    
    if (footprints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/empty_list.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pas encore d\'enregistrements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scannez des produits pour commencer à suivre votre empreinte carbone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: footprints.length,
      itemBuilder: (context, index) {
        final record = footprints[index];
        return _buildFootprintRecordItem(record, controller);
      },
    );
  }
  
  Widget _buildFootprintRecordItem(CarbonFootprintRecord record, CarbonFootprintController controller) {
    // Déterminer l'icône en fonction de la catégorie
    IconData categoryIcon;
    Color iconColor;
    
    switch (record.category.toLowerCase()) {
      case 'alimentation':
        categoryIcon = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'électronique':
        categoryIcon = Icons.devices;
        iconColor = Colors.blue;
        break;
      case 'vêtements & mode':
        categoryIcon = Icons.checkroom;
        iconColor = Colors.purple;
        break;
      case 'beauté & cosmétiques':
        categoryIcon = Icons.spa;
        iconColor = Colors.pink;
        break;
      case 'produits ménagers':
        categoryIcon = Icons.cleaning_services;
        iconColor = Colors.teal;
        break;
      default:
        categoryIcon = Icons.shopping_bag;
        iconColor = Colors.green;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(categoryIcon, color: iconColor),
        ),
        title: Text(
          record.productName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${record.carbonValue.toStringAsFixed(1)} kg CO₂',
              style: TextStyle(
                color: record.carbonValue > 3 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(record.recordDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () {
            // Demander confirmation avant suppression
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Supprimer cet enregistrement ?'),
                content: const Text('Cette action est irréversible.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.deleteFootprintRecord(record.id);
                    },
                    child: const Text('Supprimer'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTipsTab(CarbonFootprintController controller) {
    final tips = controller.getPersonalizedEcoTips();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conseils personnalisés',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Basés sur vos habitudes de consommation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Liste des conseils
          ...tips.map((tip) => _buildTipItem(tip)).toList(),
          
          const SizedBox(height: 30),
          
          // Section des défis
          const Text(
            'Défis du mois',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildChallengeItem(
            'Réduire de 10% mon empreinte alimentaire',
            'Terminez dans 21 jours',
            0.3,
            Colors.green,
          ),
          
          _buildChallengeItem(
            'Privilégier les produits locaux',
            'Terminez dans 14 jours',
            0.6,
            Colors.blue,
          ),
          
          _buildChallengeItem(
            'Éviter les emballages plastiques',
            'Terminez dans 7 jours',
            0.8,
            Colors.orange,
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeItem(String title, String subtitle, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star_outline,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
} 