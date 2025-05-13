import 'package:flutter/material.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';

class AgribalyseDetailsView extends StatefulWidget {
  final ProductScan scan;
  
  const AgribalyseDetailsView({
    Key? key,
    required this.scan,
  }) : super(key: key);

  @override
  State<AgribalyseDetailsView> createState() => _AgribalyseDetailsViewState();
}

class _AgribalyseDetailsViewState extends State<AgribalyseDetailsView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, double> _footprintData = {};
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _initFootprintData();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _initFootprintData() {
    // Ces valeurs viendraient normalement des détails Agribalyse du produit
    // Pour cet exemple, nous utilisons des valeurs fictives basées sur le scan
    final total = widget.scan.carbonFootprint.toDouble();
    
    _footprintData = {
      'Production': total * 0.65, // 65% production
      'Transport': total * 0.15, // 15% transport
      'Emballage': total * 0.12, // 12% emballage
      'Transformation': total * 0.08, // 8% transformation
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Données Agribalyse',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec le produit
            _buildProductHeader(),
            
            const SizedBox(height: 24),
            
            // Badge Agribalyse
            _buildAgribalyseBadge(),
            
            const SizedBox(height: 24),
            
            // Répartition de l'empreinte carbone
            _buildCarbonBreakdown(),
            
            const SizedBox(height: 24),
            
            // Consommation d'eau
            _buildWaterConsumption(),
            
            const SizedBox(height: 24),
            
            // Explications sur Agribalyse
            _buildAgribalyseExplanation(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image du produit
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.scan.imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Informations du produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.scan.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.scan.brand,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEcoScoreColor(widget.scan.ecoScore),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Score: ${widget.scan.ecoScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Catégorie: ${widget.scan.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Origine: ${widget.scan.origin}',
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
  
  Widget _buildAgribalyseBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.7),
            const Color(0xFF1E8E3E).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Données Agribalyse',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Agribalyse est la base de référence française qui fournit des indicateurs d\'impact environnemental des produits alimentaires, basée sur la méthodologie d\'Analyse du Cycle de Vie (ACV).',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarbonBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Répartition de l\'empreinte carbone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Analyse du cycle de vie: ${widget.scan.carbonFootprint.toDouble()} kg CO₂ eq',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        
        // Graphique de répartition
        Container(
          height: 300,
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
              // Graphique en camembert
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sections: _generatePieChartSections(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    startDegreeOffset: 180,
                  ),
                ),
              ),
              
              // Légende
              Expanded(
                flex: 2,
                child: _buildLegend(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Explications
        _buildCarbonExplanation(),
      ],
    );
  }
  
  Widget _buildLegend() {
    final List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFFC107),
      const Color(0xFFFF5722),
    ];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _footprintData.entries.map((entry) {
        final index = _footprintData.keys.toList().indexOf(entry.key);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  List<PieChartSectionData> _generatePieChartSections() {
    final List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFFC107),
      const Color(0xFFFF5722),
    ];
    
    final total = _footprintData.values.fold(0.0, (sum, value) => sum + value);
    
    final List<PieChartSectionData> sections = [];
    int i = 0;
    
    _footprintData.forEach((key, value) {
      final percent = (value / total * 100).round();
      sections.add(
        PieChartSectionData(
          value: value,
          title: '$percent%',
          color: colors[i % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
      i++;
    });
    
    return sections;
  }
  
  Widget _buildCarbonExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comprendre cette répartition',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildExplanationItem(
            'Production',
            'Impact lié à la culture ou à l\'élevage du produit.',
            const Color(0xFF4CAF50),
          ),
          _buildExplanationItem(
            'Transport',
            'Impact lié au transport depuis le lieu de production jusqu\'au point de vente.',
            const Color(0xFF2196F3),
          ),
          _buildExplanationItem(
            'Emballage',
            'Impact lié à la production et au recyclage de l\'emballage.',
            const Color(0xFFFFC107),
          ),
          _buildExplanationItem(
            'Transformation',
            'Impact lié aux processus industriels de transformation du produit.',
            const Color(0xFFFF5722),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExplanationItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWaterConsumption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consommation d\'eau',
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop_outlined,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.scan.waterFootprint * 1000} litres',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        'd\'eau nécessaire à la production',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _calculateWaterRatio(),
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Faible',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    'Moyenne',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    'Élevée',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getWaterConsumptionExplanation(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  double _calculateWaterRatio() {
    // Échelle pour comparaison: 0-500L (0.1), 500-2000L (0.3), 2000-5000L (0.5), 5000-10000L (0.7), >10000L (0.9)
    final waterValue = widget.scan.waterFootprint * 1000.0;
    
    if (waterValue <= 500) return 0.1;
    if (waterValue <= 2000) return 0.3;
    if (waterValue <= 5000) return 0.5;
    if (waterValue <= 10000) return 0.7;
    return 0.9;
  }
  
  String _getWaterConsumptionExplanation() {
    final waterValue = widget.scan.waterFootprint * 1000.0;
    final category = widget.scan.category.toLowerCase();
    
    if (category.contains('viande') || category.contains('poisson')) {
      return 'La production de protéines animales nécessite généralement beaucoup d\'eau, principalement pour la production d\'aliments pour animaux. Ce produit requiert environ $waterValue litres d\'eau pour sa production.';
    } else if (category.contains('fruit') || category.contains('légume')) {
      return 'Les fruits et légumes ont généralement une empreinte eau plus faible que les produits d\'origine animale. Ce produit nécessite environ $waterValue litres d\'eau pour sa production.';
    } else {
      return 'La consommation d\'eau pour ce produit est d\'environ $waterValue litres. Cette eau est utilisée principalement pour la production des matières premières et le processus de fabrication.';
    }
  }
  
  Widget _buildAgribalyseExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos d\'Agribalyse',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Agribalyse est développée par l\'ADEME (Agence de la transition écologique) en France.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Cette base de données fournit des indicateurs d\'impact environnemental pour plus de 2500 produits alimentaires, basés sur leur cycle de vie complet : depuis la production agricole jusqu\'à la préparation du produit, en passant par la transformation et le transport.\n\n'
                'Les données sont issues d\'une méthodologie scientifique rigoureuse d\'Analyse du Cycle de Vie (ACV) qui permet de quantifier les impacts environnementaux d\'un produit tout au long de sa vie.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // Ici, vous pourriez ouvrir un lien vers le site d'Agribalyse
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                child: const Text(
                  'En savoir plus sur Agribalyse',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Color _getEcoScoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF4CAF50);
      case 'B':
        return const Color(0xFF8BC34A);
      case 'C':
        return const Color(0xFFFFEB3B);
      case 'D':
        return const Color(0xFFFF9800);
      case 'E':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }
} 