import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/eco_tree_widget.dart';

/// Widget de tableau de bord unifié qui regroupe les principales
/// métriques écologiques de l'utilisateur
class UnifiedEcoDashboardWidget extends StatelessWidget {
  // Métriques générales
  final int ecoPoints;
  final int ecoLevel;
  final double progressToNextLevel;
  
  // Métriques de CO2
  final double carbonFootprint;
  final double carbonSaved;
  final List<MapEntry<String, double>> carbonBreakdown;
  
  // Métriques d'eau
  final double waterSaved;
  
  // Métriques de déchets
  final double wasteSaved;
  
  // Statistiques d'activité
  final int completedChallenges;
  final int activeGoals;
  final int streak;
  
  // Historique
  final List<MapEntry<DateTime, double>> carbonHistory;
  
  // Navigation
  final Function(String) onCategoryTap;

  const UnifiedEcoDashboardWidget({
    Key? key,
    required this.ecoPoints,
    required this.ecoLevel,
    required this.progressToNextLevel,
    required this.carbonFootprint,
    required this.carbonSaved,
    required this.carbonBreakdown,
    required this.waterSaved,
    required this.wasteSaved,
    required this.completedChallenges,
    required this.activeGoals,
    required this.streak,
    required this.carbonHistory,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildEcoTree(context),
        const SizedBox(height: 24),
        _buildCarbonSection(context),
        const SizedBox(height: 16),
        _buildResourcesSection(context),
        const SizedBox(height: 16),
        _buildChallengesSection(context),
        const SizedBox(height: 16),
        _buildCarbonHistorySection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tableau de bord écologique',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Votre impact positif sur la planète',
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: AppColors.textDarkColor,
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.eco,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$ecoPoints pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEcoTree(BuildContext context) {
    return GestureDetector(
      onTap: () => onCategoryTap('profile'),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Votre arbre écologique',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Niveau $ecoLevel',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: EcoTreeWidget(
                progress: progressToNextLevel,
                ecoPoints: ecoPoints,
                level: ecoLevel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonSection(BuildContext context) {
    return GestureDetector(
      onTap: () => onCategoryTap('carbon'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Empreinte carbone',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textLightColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetricCard(
                  context,
                  'Empreinte actuelle',
                  '${carbonFootprint.toStringAsFixed(1)} kg',
                  Icons.trending_down,
                  AppColors.errorColor,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  context,
                  'CO₂ économisé',
                  '${carbonSaved.toStringAsFixed(1)} kg',
                  Icons.trending_up,
                  AppColors.successColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (carbonBreakdown.isNotEmpty) _buildCarbonBreakdownChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onCategoryTap('water'),
            child: _buildResourceCard(
              context,
              'Eau économisée',
              '${waterSaved.toStringAsFixed(0)} L',
              Icons.water_drop,
              AppColors.infoColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => onCategoryTap('waste'),
            child: _buildResourceCard(
              context,
              'Déchets évités',
              '${wasteSaved.toStringAsFixed(1)} kg',
              Icons.delete_outline,
              AppColors.warningColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesSection(BuildContext context) {
    return GestureDetector(
      onTap: () => onCategoryTap('challenges'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vos activités',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textLightColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActivityCard(
                  context,
                  'Défis complétés',
                  completedChallenges.toString(),
                  Icons.emoji_events,
                  AppColors.successColor,
                ),
                const SizedBox(width: 8),
                _buildActivityCard(
                  context,
                  'Objectifs actifs',
                  activeGoals.toString(),
                  Icons.flag,
                  AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                _buildActivityCard(
                  context,
                  'Jours consécutifs',
                  streak.toString(),
                  Icons.local_fire_department,
                  AppColors.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonHistorySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution de votre empreinte',
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: carbonHistory.length < 2
                ? Center(
                    child: Text(
                      'Pas assez de données pour afficher le graphique',
                      style: TextStyle(
                        color: AppColors.textLightColor,
                      ),
                    ),
                  )
                : _buildCarbonHistoryChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: 12,
                color: AppColors.successColor,
              ),
              const SizedBox(width: 4),
              Text(
                '+8% cette semaine',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonBreakdownChart(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: carbonBreakdown.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final colors = [
              AppColors.primaryColor,
              AppColors.accentColor,
              AppColors.warningColor,
              AppColors.infoColor,
              AppColors.errorColor,
            ];
            
            return PieChartSectionData(
              color: colors[index % colors.length],
              value: data.value,
              title: '${(data.value / carbonFootprint * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildCarbonHistoryChart(BuildContext context) {
    // Préparer les données pour le graphique linéaire
    final spots = carbonHistory.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;
      return FlSpot(index, data.value);
    }).toList();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
            getTitles: (value) {
              final index = value.toInt();
              if (index >= 0 && index < carbonHistory.length) {
                final date = carbonHistory[index].key;
                return '${date.day}/${date.month}';
              }
              return '';
            },
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
            getTitles: (value) {
              return '${value.toInt()} kg';
            },
            reservedSize: 30,
            margin: 12,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.dividerColor, width: 1),
        ),
        minX: 0,
        maxX: (carbonHistory.length - 1).toDouble(),
        minY: 0,
        maxY: carbonHistory.isEmpty
            ? 100
            : (carbonHistory.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            colors: [AppColors.primaryColor],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: [
                AppColors.primaryColor.withOpacity(0.3),
                AppColors.primaryColor.withOpacity(0.0),
              ],
              gradientColorStops: [0.5, 1.0],
              gradientFrom: const Offset(0, 0),
              gradientTo: const Offset(0, 1),
            ),
          ),
        ],
      ),
    );
  }
} 