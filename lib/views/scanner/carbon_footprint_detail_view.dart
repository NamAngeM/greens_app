import 'package:flutter/material.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class CarbonFootprintDetailView extends StatefulWidget {
  final ProductScan scan;
  
  const CarbonFootprintDetailView({
    Key? key,
    required this.scan,
  }) : super(key: key);

  @override
  State<CarbonFootprintDetailView> createState() => _CarbonFootprintDetailViewState();
}

class _CarbonFootprintDetailViewState extends State<CarbonFootprintDetailView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, double> _footprintBreakdown = {};
  bool _isLoading = true;
  List<String> _equivalents = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _loadCarbonFootprintDetails();
    _generateEquivalents();
    
    Future.delayed(const Duration(milliseconds: 500), () {
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
  
  Future<void> _loadCarbonFootprintDetails() async {
    // Dans une application réelle, ces données viendraient du contrôleur
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Simuler une répartition de l'empreinte carbone basée sur la valeur globale
    final carbonFootprint = widget.scan.carbonFootprint.toDouble();
    
    setState(() {
      _footprintBreakdown = {
        'Production': carbonFootprint * 0.6, // 60% de l'empreinte
        'Transport': carbonFootprint * 0.2, // 20% de l'empreinte
        'Emballage': carbonFootprint * 0.15, // 15% de l'empreinte
        'Transformation': carbonFootprint * 0.05, // 5% de l'empreinte
      };
      _isLoading = false;
    });
  }
  
  void _generateEquivalents() {
    final carbonFootprint = widget.scan.carbonFootprint.toDouble();
    final random = math.Random();
    
    // Générer des équivalents parlants pour l'empreinte carbone
    _equivalents = [
      '${(carbonFootprint * 6).toStringAsFixed(1)} km en voiture',
      '${(carbonFootprint * 0.4).toStringAsFixed(1)} jour de chauffage d\'un appartement',
      '${(carbonFootprint * 2).toStringAsFixed(1)} heures de télévision',
      '${(carbonFootprint * 0.8 + random.nextDouble()).toStringAsFixed(1)} kg de papier',
      '${(carbonFootprint * 3 + random.nextDouble()).toStringAsFixed(1)} charges de lave-linge',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Détail de l\'empreinte carbone',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
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
            
            // Visualisation principale de l'empreinte carbone
            _buildCarbonFootprintVisualization(),
            
            const SizedBox(height: 32),
            
            // Répartition détaillée de l'empreinte
            _buildFootprintBreakdown(),
            
            const SizedBox(height: 32),
            
            // Équivalents en termes d'activités quotidiennes
            _buildEquivalents(),
            
            const SizedBox(height: 32),
            
            // Conseils pour réduire l'empreinte
            _buildEcoTips(),
            
            const SizedBox(height: 24),
            
            // Bouton d'action
            _buildActionButton(),
            
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
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCarbonFootprintVisualization() {
    final carbonFootprint = widget.scan.carbonFootprint.toDouble();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Empreinte carbone totale',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Animation de l'empreinte carbone
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: CircularProgressIndicator(
                      value: _animationController.value,
                      strokeWidth: 15,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCarbonFootprintColor(carbonFootprint),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(carbonFootprint * _animationController.value).toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getCarbonFootprintColor(carbonFootprint),
                        ),
                      ),
                      const Text(
                        'kg CO₂ eq',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Explication de l'échelle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScaleItem(const Color(0xFF1E8E3E), 'Faible (0-2)'),
              const SizedBox(width: 12),
              _buildScaleItem(const Color(0xFFFBC02D), 'Moyen (2-4)'),
              const SizedBox(width: 12),
              _buildScaleItem(const Color(0xFFE53935), 'Élevé (4+)'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildScaleItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFootprintBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Répartition de l\'impact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
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
                // Graphique en camembert
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _generatePieChartSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        startDegreeOffset: 180,
                      ),
                    ),
                  ),
                ),
                
                // Légende
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generateLegendItems(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  List<PieChartSectionData> _generatePieChartSections() {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFFC107),
      const Color(0xFFFF5722),
    ];
    
    int i = 0;
    _footprintBreakdown.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: value,
          title: '${(value * 100 / widget.scan.carbonFootprint).toStringAsFixed(0)}%',
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
  
  List<Widget> _generateLegendItems() {
    final List<Widget> items = [];
    final List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFFC107),
      const Color(0xFFFF5722),
    ];
    
    int i = 0;
    _footprintBreakdown.forEach((key, value) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$key: ${value.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      i++;
    });
    
    return items;
  }
  
  Widget _buildEquivalents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équivalents concrets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cette empreinte carbone équivaut à:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        
        // Liste des équivalents
        Column(
          children: _equivalents.map((equivalent) => _buildEquivalentItem(equivalent)).toList(),
        ),
      ],
    );
  }
  
  Widget _buildEquivalentItem(String equivalent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              equivalent,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEcoTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment réduire cette empreinte ?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Liste des conseils écologiques
        ...widget.scan.ecoTips.map((tip) => _buildEcoTipItem(tip)).toList(),
      ],
    );
  }
  
  Widget _buildEcoTipItem(String tip) {
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
  
  Widget _buildActionButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Action pour ajouter à son suivi personnalisé
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empreinte carbone ajoutée à votre suivi personnel'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        },
        icon: const Icon(Icons.add_chart),
        label: const Text('Ajouter à mon suivi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
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
  
  Color _getCarbonFootprintColor(double value) {
    if (value <= 2.0) {
      return const Color(0xFF1E8E3E); // Vert
    } else if (value <= 4.0) {
      return const Color(0xFFFBC02D); // Jaune
    } else {
      return const Color(0xFFE53935); // Rouge
    }
  }
} 