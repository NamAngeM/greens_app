import 'package:flutter/material.dart';
import 'package:greens_app/models/environmental_impact_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class EnvironmentalImpactCard extends StatefulWidget {
  final EnvironmentalImpactModel impact;
  final String title;
  final String subtitle;
  final bool showDetails;
  final VoidCallback? onTap;
  
  const EnvironmentalImpactCard({
    Key? key,
    required this.impact,
    this.title = 'Votre impact environnemental',
    this.subtitle = 'Découvrez l\'impact concret de vos actions',
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<EnvironmentalImpactCard> createState() => _EnvironmentalImpactCardState();
}

class _EnvironmentalImpactCardState extends State<EnvironmentalImpactCard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la carte
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const Icon(
                        Icons.eco,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Impact principal (CO2 économisé)
            _buildCarbonSavedSection(),
            
            // Onglets pour différents types d'impact
            if (widget.showDetails) ...[
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryColor,
                tabs: const [
                  Tab(text: 'Arbres'),
                  Tab(text: 'Eau'),
                  Tab(text: 'Plastique'),
                  Tab(text: 'Énergie'),
                ],
              ),
              
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTreesImpact(),
                    _buildWaterImpact(),
                    _buildPlasticsImpact(),
                    _buildEnergyImpact(),
                  ],
                ),
              ),
              
              // Évolution mensuelle
              if (widget.impact.monthlyImpact.isNotEmpty)
                _buildMonthlyChart(),
                
              // Impact communautaire
              _buildCommunityImpact(),
            ],
            
            // Petite barre d'indicateurs si les détails ne sont pas affichés
            if (!widget.showDetails)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniIndicator(
                      Icons.park,
                      '${widget.impact.treeEquivalent.toStringAsFixed(1)} arbres',
                    ),
                    _buildMiniIndicator(
                      Icons.water_drop,
                      '${(widget.impact.waterSaved / 1000).toStringAsFixed(1)} m³ d\'eau',
                    ),
                    _buildMiniIndicator(
                      Icons.battery_charging_full,
                      '${widget.impact.energySaved.toStringAsFixed(0)} kWh',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Section principale du CO2 économisé
  Widget _buildCarbonSavedSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          const Text(
            'CO₂ économisé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.impact.carbonSaved.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'kg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Équivalent à un trajet de ${(widget.impact.carbonSaved * 6).toStringAsFixed(0)} km en voiture',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  // Mini-indicateur pour la version compacte
  Widget _buildMiniIndicator(IconData icon, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Section impact des arbres
  Widget _buildTreesImpact() {
    return _buildImpactDetail(
      icon: Icons.park,
      title: 'Équivalent en arbres',
      value: widget.impact.treeEquivalent.toStringAsFixed(1),
      unit: 'arbres',
      description: 'Un arbre absorbe en moyenne 25 kg de CO₂ par an.',
      color: Colors.green.shade700,
    );
  }
  
  // Section impact de l'eau
  Widget _buildWaterImpact() {
    final waterInCubicMeters = widget.impact.waterSaved / 1000;
    return _buildImpactDetail(
      icon: Icons.water_drop,
      title: 'Eau économisée',
      value: waterInCubicMeters.toStringAsFixed(1),
      unit: 'm³',
      description: 'Équivalent à ${(waterInCubicMeters * 12).toStringAsFixed(0)} douches de 5 minutes.',
      color: Colors.blue.shade600,
    );
  }
  
  // Section impact du plastique
  Widget _buildPlasticsImpact() {
    return _buildImpactDetail(
      icon: Icons.delete_outline,
      title: 'Plastique évité',
      value: widget.impact.plasticsAvoided.toStringAsFixed(1),
      unit: 'kg',
      description: 'Équivalent à ${(widget.impact.plasticsAvoided * 200).toStringAsFixed(0)} sacs plastiques.',
      color: Colors.orange.shade800,
    );
  }
  
  // Section impact de l'énergie
  Widget _buildEnergyImpact() {
    return _buildImpactDetail(
      icon: Icons.bolt,
      title: 'Énergie économisée',
      value: widget.impact.energySaved.toStringAsFixed(0),
      unit: 'kWh',
      description: 'Équivalent à ${(widget.impact.energySaved / 0.5).toStringAsFixed(0)} heures d\'utilisation d\'un ordinateur.',
      color: Colors.amber.shade700,
    );
  }
  
  // Template pour les détails d'impact
  Widget _buildImpactDetail({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 36,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Graphique d'évolution mensuelle
  Widget _buildMonthlyChart() {
    // Convertir les données pour le graphique
    final List<FlSpot> spots = [];
    int index = 0;
    
    final sortedMonths = widget.impact.monthlyImpact.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    for (var month in sortedMonths.take(6)) {
      final value = widget.impact.monthlyImpact[month] ?? 0;
      spots.add(FlSpot(index.toDouble(), value));
      index++;
    }
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution de votre impact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedMonths.length || value.toInt() < 0) {
                          return const Text('');
                        }
                        
                        final monthYear = sortedMonths[value.toInt()];
                        final parts = monthYear.split('-');
                        return Text(
                          '${parts[1]}/${parts[0].substring(2)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.primaryColor,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Section impact communautaire
  Widget _buildCommunityImpact() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impact collectif',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Communauté de ${widget.impact.communityParticipants} personnes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Impact collectif en CO2
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CO₂ économisé ensemble',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.impact.communityCarbonSaved.toStringAsFixed(0)} kg',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arbres équivalents',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${EnvironmentalImpactModel.calculateTreeEquivalent(widget.impact.communityCarbonSaved).toStringAsFixed(0)} arbres',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Votre contribution
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre contribution',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: widget.impact.userContributionPercentage / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.impact.userContributionPercentage.toStringAsFixed(1)}% de l\'impact total',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 