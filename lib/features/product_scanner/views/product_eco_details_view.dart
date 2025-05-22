import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProductEcoDetailsView extends StatelessWidget {
  final Product product;
  
  const ProductEcoDetailsView({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impact écologique'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader(context),
              const SizedBox(height: 24),
              _buildEcoScoreSection(context),
              const SizedBox(height: 24),
              _buildCarbonFootprintSection(context),
              const SizedBox(height: 24),
              _buildWaterFootprintSection(context),
              const SizedBox(height: 24),
              _buildPackagingSection(context),
              const SizedBox(height: 24),
              _buildEcoTipsSection(context),
              const SizedBox(height: 24),
              _buildDataSourcesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    backgroundColor: _getEcoScoreColor(product.ecoScore),
                    label: Text(
                      'Eco-Score: ${product.ecoScore.toStringAsFixed(1)}/100',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoScoreSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eco-Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 15.0,
                percent: product.ecoScore / 100,
                center: Text(
                  '${product.ecoScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                progressColor: _getEcoScoreColor(product.ecoScore),
                backgroundColor: Colors.grey[200]!,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              ),
            ),
            const SizedBox(height: 16),
            _buildEcoScoreExplanation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoScoreExplanation(BuildContext context) {
    String explanation;
    if (product.ecoScore >= 80) {
      explanation = 'Excellent impact environnemental. Ce produit est parmi les meilleurs choix écologiques.';
    } else if (product.ecoScore >= 60) {
      explanation = 'Bon impact environnemental. Ce produit est un choix écologique responsable.';
    } else if (product.ecoScore >= 40) {
      explanation = 'Impact environnemental moyen. Des alternatives plus écologiques existent.';
    } else if (product.ecoScore >= 20) {
      explanation = 'Impact environnemental élevé. Envisagez des alternatives plus écologiques.';
    } else {
      explanation = 'Impact environnemental très élevé. Il est fortement recommandé de chercher des alternatives.';
    }

    return Text(
      explanation,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCarbonFootprintSection(BuildContext context) {
    final environmentalImpact = product.environmentalImpact;
    final carbonDetails = environmentalImpact?['carbon']?['details'];
    final carbonEquivalents = environmentalImpact?['carbon']?['equivalents'];
    
    // Vérifier si nous avons des données détaillées de CarbonCloud
    final hasCarbonCloudData = environmentalImpact?['carbon_cloud'] != null;
    final carbonCloudDetails = hasCarbonCloudData 
        ? environmentalImpact!['carbon_cloud']['details'] 
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empreinte Carbone',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${product.carbonFootprint.toStringAsFixed(2)} kg CO₂e par kg de produit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getCarbonFootprintColor(product.carbonFootprint),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Afficher le graphique détaillé si nous avons des données
            if (carbonCloudDetails != null || (carbonDetails != null && _hasNonZeroValues(carbonDetails)))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Répartition de l\'empreinte carbone',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    child: _buildCarbonFootprintChart(context, hasCarbonCloudData ? carbonCloudDetails : carbonDetails),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            // Afficher les équivalences si disponibles
            if (carbonEquivalents != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Équivalences',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildCarbonEquivalents(context, carbonEquivalents),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintChart(BuildContext context, Map<String, dynamic> details) {
    final List<MapEntry<String, dynamic>> sortedEntries = details.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    final Map<String, String> labelMap = {
      'production': 'Production',
      'farming': 'Agriculture',
      'processing': 'Transformation',
      'packaging': 'Emballage',
      'transport': 'Transport',
      'retail': 'Distribution',
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: sortedEntries.isNotEmpty ? (sortedEntries.first.value as num) * 1.2 : 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = sortedEntries[groupIndex];
              return BarTooltipItem(
                '${labelMap[entry.key] ?? entry.key}: ${(entry.value as num).toStringAsFixed(2)} kg CO₂e',
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < sortedEntries.length) {
                  final key = sortedEntries[value.toInt()].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labelMap[key] ?? key,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          sortedEntries.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sortedEntries[index].value as double,
                color: _getCarbonCategoryColor(sortedEntries[index].key),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarbonEquivalents(BuildContext context, Map<String, dynamic> equivalents) {
    return Column(
      children: [
        _buildEquivalentItem(
          context, 
          'Kilomètres en voiture', 
          '${equivalents['km_voiture']?.toStringAsFixed(1) ?? "N/A"} km',
          Icons.directions_car,
        ),
        _buildEquivalentItem(
          context, 
          'Charges de smartphone', 
          '${equivalents['charges_smartphone']?.toStringAsFixed(0) ?? "N/A"} charges',
          Icons.phone_android,
        ),
        _buildEquivalentItem(
          context, 
          'Arbres nécessaires pour compenser', 
          '${equivalents['arbres_necessaires']?.toStringAsFixed(2) ?? "N/A"} arbres/an',
          Icons.nature,
        ),
        _buildEquivalentItem(
          context, 
          'Jours de chauffage d\'un appartement', 
          '${equivalents['jours_chauffage']?.toStringAsFixed(2) ?? "N/A"} jours',
          Icons.home,
        ),
      ],
    );
  }

  Widget _buildEquivalentItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterFootprintSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empreinte Eau',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${product.waterFootprint.toStringAsFixed(0)} litres par kg de produit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getWaterFootprintColor(product.waterFootprint),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 20.0,
              percent: _getWaterFootprintPercentage(product.waterFootprint),
              center: Text(
                '${_getWaterFootprintPercentage(product.waterFootprint) * 100}%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: _getWaterFootprintColor(product.waterFootprint),
              backgroundColor: Colors.grey[200]!,
              barRadius: Radius.circular(10),
              animation: true,
              animationDuration: 1200,
            ),
            const SizedBox(height: 16),
            _buildWaterFootprintExplanation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterFootprintExplanation(BuildContext context) {
    String explanation;
    if (product.waterFootprint < 500) {
      explanation = 'Empreinte eau très faible. Ce produit nécessite peu d\'eau pour sa production.';
    } else if (product.waterFootprint < 2000) {
      explanation = 'Empreinte eau faible à modérée. Ce produit a une utilisation d\'eau raisonnable.';
    } else if (product.waterFootprint < 5000) {
      explanation = 'Empreinte eau modérée à élevée. Envisagez des alternatives nécessitant moins d\'eau.';
    } else if (product.waterFootprint < 10000) {
      explanation = 'Empreinte eau élevée. Ce produit nécessite beaucoup d\'eau pour sa production.';
    } else {
      explanation = 'Empreinte eau très élevée. Ce produit a un impact significatif sur les ressources en eau.';
    }

    // Ajouter une comparaison
    String comparison;
    if (product.waterFootprint < 1000) {
      comparison = 'Équivalent à environ ${(product.waterFootprint / 150).toStringAsFixed(0)} douches.';
    } else {
      comparison = 'Équivalent à environ ${(product.waterFootprint / 150).toStringAsFixed(0)} douches ou ${(product.waterFootprint / 5000).toStringAsFixed(1)} piscines.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          explanation,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          comparison,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPackagingSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emballage',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  product.recyclablePackaging 
                      ? Icons.check_circle 
                      : Icons.cancel,
                  color: product.recyclablePackaging 
                      ? Colors.green 
                      : Colors.red,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    product.recyclablePackaging 
                        ? 'Emballage recyclable' 
                        : 'Emballage non recyclable',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: product.recyclablePackaging 
                          ? Colors.green 
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              product.recyclablePackaging 
                  ? 'Cet emballage peut être recyclé. Assurez-vous de le déposer dans le bac de recyclage approprié.' 
                  : 'Cet emballage n\'est pas recyclable. Envisagez des alternatives avec des emballages plus écologiques.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoTipsSection(BuildContext context) {
    final ecoTips = product.environmentalImpact?['ecoTips'] as List<dynamic>?;
    
    if (ecoTips == null || ecoTips.isEmpty) {
      return SizedBox();
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
              'Conseils écologiques',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...ecoTips.map((tip) => _buildTipItem(context, tip.toString())).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourcesSection(BuildContext context) {
    // Déterminer quelles sources de données ont été utilisées
    final environmentalImpact = product.environmentalImpact;
    final hasOpenFoodFactsData = true; // Toujours vrai car c'est la source de base
    final hasEcobalyseData = environmentalImpact?['ecobalyse'] != null;
    final hasCarbonCloudData = environmentalImpact?['carbon_cloud'] != null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sources de données',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (hasOpenFoodFactsData)
              _buildDataSourceItem(
                context,
                'Open Food Facts',
                'Données nutritionnelles et informations générales sur le produit',
                'https://world.openfoodfacts.org',
              ),
            if (hasEcobalyseData)
              _buildDataSourceItem(
                context,
                'Ecobalyse',
                'Données environnementales détaillées et impact écologique',
                'https://ecobalyse.fr',
              ),
            if (hasCarbonCloudData)
              _buildDataSourceItem(
                context,
                'CarbonCloud',
                'Calcul précis de l\'empreinte carbone du produit',
                'https://carboncloud.com',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceItem(BuildContext context, String name, String description, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            url,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  // Fonctions utilitaires pour les couleurs et les calculs
  Color _getEcoScoreColor(double score) {
    if (score >= 80) return Colors.green[700]!;
    if (score >= 60) return Colors.green[400]!;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getCarbonFootprintColor(double footprint) {
    if (footprint < 1.0) return Colors.green[700]!;
    if (footprint < 5.0) return Colors.green[400]!;
    if (footprint < 10.0) return Colors.orange;
    if (footprint < 20.0) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getWaterFootprintColor(double footprint) {
    if (footprint < 500) return Colors.blue[700]!;
    if (footprint < 2000) return Colors.blue[400]!;
    if (footprint < 5000) return Colors.orange;
    if (footprint < 10000) return Colors.deepOrange;
    return Colors.red;
  }

  double _getWaterFootprintPercentage(double footprint) {
    // Normaliser entre 0 et 1 avec un maximum de 15000 litres
    return (footprint / 15000).clamp(0.0, 1.0);
  }

  Color _getCarbonCategoryColor(String category) {
    final colors = {
      'production': Colors.green[700]!,
      'farming': Colors.green[400]!,
      'processing': Colors.blue[400]!,
      'packaging': Colors.orange,
      'transport': Colors.red[400]!,
      'retail': Colors.purple[400]!,
    };
    
    return colors[category] ?? Colors.grey;
  }

  bool _hasNonZeroValues(Map<String, dynamic> map) {
    return map.values.any((value) => (value as num) > 0);
  }
}
