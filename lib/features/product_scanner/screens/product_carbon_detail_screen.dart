import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/product_model.dart';

class ProductCarbonDetailScreen extends StatefulWidget {
  final Product product;
  
  const ProductCarbonDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductCarbonDetailScreen> createState() => _ProductCarbonDetailScreenState();
}

class _ProductCarbonDetailScreenState extends State<ProductCarbonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;
  
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
        title: Text(widget.product.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Empreinte'),
            Tab(text: 'Détails'),
            Tab(text: 'Conseils'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCarbonFootprintTab(),
          _buildDetailsTab(),
          _buildTipsTab(),
        ],
      ),
    );
  }
  
  // Onglet Empreinte Carbone
  Widget _buildCarbonFootprintTab() {
    final carbonValue = widget.product.carbonFootprint;
    final waterValue = widget.product.waterFootprint;
    final ecoScore = widget.product.ecoScore;
    
    // Récupérer les détails et équivalents s'ils existent
    Map<String, dynamic> carbonDetails = {};
    Map<String, dynamic> carbonEquivalents = {};
    
    if (widget.product.environmentalImpact != null && 
        widget.product.environmentalImpact!.containsKey('carbon')) {
      final carbonData = widget.product.environmentalImpact!['carbon'];
      if (carbonData.containsKey('details')) {
        carbonDetails = carbonData['details'];
      }
      if (carbonData.containsKey('equivalents')) {
        carbonEquivalents = carbonData['equivalents'];
      }
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            
            const SizedBox(height: 24),
            
            // Score écologique
            _buildEcoScoreIndicator(ecoScore),
            
            const SizedBox(height: 24),
            
            // Section Empreinte Carbone
            _buildSectionTitle('Empreinte Carbone'),
            
            const SizedBox(height: 8),
            
            _buildCarbonFootprintCard(carbonValue, carbonDetails),
            
            const SizedBox(height: 16),
            
            // Section Équivalences
            if (carbonEquivalents.isNotEmpty) ...[
              _buildSectionTitle('Équivalences'),
              
              const SizedBox(height: 8),
              
              _buildEquivalentsCard(carbonEquivalents),
              
              const SizedBox(height: 16),
            ],
            
            // Section Empreinte Eau
            _buildSectionTitle('Empreinte Eau'),
            
            const SizedBox(height: 8),
            
            _buildWaterFootprintCard(waterValue),
          ],
        ),
      ),
    );
  }
  
  // Onglet Détails
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            
            const SizedBox(height: 24),
            
            // Détails du produit
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails du produit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Catégorie', widget.product.category),
                    _buildDetailRow('Marque', widget.product.brand),
                    _buildDetailRow('Code-barres', widget.product.barcode ?? 'Non disponible'),
                    
                    // Afficher les ingrédients s'ils sont disponibles
                    if (widget.product.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Ingrédients',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.product.ingredients.join(', ')),
                    ],
                    
                    // Afficher les informations nutritionnelles si disponibles
                    if (widget.product.nutritionalInfo.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Informations nutritionnelles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.product.nutritionalInfo.entries.map((entry) => 
                        _buildDetailRow(entry.key, entry.value.toString())
                      ).toList(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Impacts environnementaux détaillés
            if (widget.product.environmentalImpact != null && 
                widget.product.environmentalImpact!.containsKey('carbon') &&
                widget.product.environmentalImpact!['carbon'].containsKey('details')) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détail de l\'empreinte carbone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCarbonDetailsChart(
                        widget.product.environmentalImpact!['carbon']['details']
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Onglet Conseils
  Widget _buildTipsTab() {
    List<String> ecoTips = [];
    
    if (widget.product.environmentalImpact != null && 
        widget.product.environmentalImpact!.containsKey('ecoTips')) {
      ecoTips = List<String>.from(widget.product.environmentalImpact!['ecoTips']);
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            
            const SizedBox(height: 24),
            
            // Conseils écologiques
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conseils pour réduire l\'impact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste des conseils
                    if (ecoTips.isNotEmpty) ...[
                      ...ecoTips.map((tip) => _buildTipItem(tip)).toList(),
                    ] else ...[
                      _buildTipItem("Privilégiez les produits locaux et de saison pour réduire l'impact du transport."),
                      _buildTipItem("Recherchez des produits avec moins d'emballage ou des emballages recyclables."),
                      _buildTipItem("Comparez les produits similaires et choisissez ceux qui ont une meilleure empreinte carbone."),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Alternatives plus écologiques
            Card(
              elevation: 4,
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alternatives plus écologiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Dans la catégorie ${widget.product.category}, recherchez des produits locaux, sans emballage excessif et avec des certifications bio ou éco-responsables.",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image du produit ou placeholder
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.product.imageUrl.isNotEmpty
              ? Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.image_not_supported, size: 50),
                )
              : Icon(
                  Icons.shopping_basket, 
                  size: 50,
                  color: Colors.green.shade700,
                ),
        ),
        const SizedBox(width: 16),
        // Infos du produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.brand,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.category,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildEcoScoreIndicator(double score) {
    final Color color = _getEcoScoreColor(score);
    final String grade = _getEcoScoreGrade(score);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Score Écologique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      grade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getEcoScoreDescription(score),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getEcoScoreExplanation(score),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCarbonFootprintCard(double carbonValue, Map<String, dynamic> details) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Impact CO₂',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'Réduire' : 'Détails',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  carbonValue.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'kg CO₂e',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getCarbonFootprintDescription(carbonValue),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            if (_isExpanded && details.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Détail des émissions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (details.containsKey('production'))
                _buildCarbonDetailRow('Production', details['production']),
              if (details.containsKey('transport'))
                _buildCarbonDetailRow('Transport', details['transport']),
              if (details.containsKey('packaging'))
                _buildCarbonDetailRow('Emballage', details['packaging']),
              if (details.containsKey('processing'))
                _buildCarbonDetailRow('Transformation', details['processing']),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaterFootprintCard(double waterValue) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consommation d\'eau',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  waterValue.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Litres',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getWaterFootprintDescription(waterValue),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquivalentsCard(Map<String, dynamic> equivalents) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cette empreinte carbone équivaut à :',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            if (equivalents.containsKey('km_voiture'))
              _buildEquivalentRow(
                'Voiture',
                'km',
                equivalents['km_voiture'],
                Icons.directions_car,
              ),
            if (equivalents.containsKey('charges_smartphone'))
              _buildEquivalentRow(
                'Charges de smartphone',
                'charges',
                equivalents['charges_smartphone'],
                Icons.phone_android,
              ),
            if (equivalents.containsKey('arbres_necessaires'))
              _buildEquivalentRow(
                'Arbres pour compenser/an',
                'arbres',
                equivalents['arbres_necessaires'],
                Icons.park,
              ),
            if (equivalents.containsKey('jours_chauffage'))
              _buildEquivalentRow(
                'Chauffage d\'un appartement',
                'jours',
                equivalents['jours_chauffage'],
                Icons.home,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquivalentRow(String label, String unit, double value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarbonDetailRow(String label, double value) {
    final percentage = widget.product.carbonFootprint > 0 
        ? (value / widget.product.carbonFootprint * 100).round() 
        : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              Text(
                '${value.toStringAsFixed(2)} kg ($percentage%)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: _getCarbonIntensityColor(percentage / 100),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarbonDetailsChart(Map<String, dynamic> details) {
    List<PieChartSectionData> sections = [];
    
    if (details.containsKey('production')) {
      sections.add(_buildChartSection(
        'Production',
        details['production'],
        Colors.green,
      ));
    }
    
    if (details.containsKey('transport')) {
      sections.add(_buildChartSection(
        'Transport',
        details['transport'],
        Colors.blue,
      ));
    }
    
    if (details.containsKey('packaging')) {
      sections.add(_buildChartSection(
        'Emballage',
        details['packaging'],
        Colors.orange,
      ));
    }
    
    if (details.containsKey('processing')) {
      sections.add(_buildChartSection(
        'Transformation',
        details['processing'],
        Colors.purple,
      ));
    }
    
    return SizedBox(
      height: 200,
      child: sections.isNotEmpty 
          ? PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            )
          : const Center(
              child: Text('Données non disponibles'),
            ),
    );
  }
  
  PieChartSectionData _buildChartSection(String title, double value, Color color) {
    final total = widget.product.carbonFootprint;
    final percentage = total > 0 ? (value / total * 100) : 0;
    
    return PieChartSectionData(
      value: value,
      title: '${percentage.round()}%',
      color: color,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      radius: 80,
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.eco,
            color: Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Utilitaires pour les couleurs et descriptions
  
  Color _getEcoScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.orange;
    if (score >= 2) return Colors.deepOrange;
    return Colors.red;
  }
  
  String _getEcoScoreGrade(double score) {
    if (score >= 8) return 'A';
    if (score >= 6) return 'B';
    if (score >= 4) return 'C';
    if (score >= 2) return 'D';
    return 'E';
  }
  
  String _getEcoScoreDescription(double score) {
    if (score >= 8) return 'Impact très faible';
    if (score >= 6) return 'Impact faible';
    if (score >= 4) return 'Impact modéré';
    if (score >= 2) return 'Impact élevé';
    return 'Impact très élevé';
  }
  
  String _getEcoScoreExplanation(double score) {
    if (score >= 8) return 'Ce produit a un excellent bilan environnemental';
    if (score >= 6) return 'Ce produit a un bon bilan environnemental';
    if (score >= 4) return 'Ce produit a un bilan environnemental moyen';
    if (score >= 2) return 'Ce produit a un bilan environnemental médiocre';
    return 'Ce produit a un très mauvais bilan environnemental';
  }
  
  String _getCarbonFootprintDescription(double value) {
    if (value <= 1.0) {
      return 'Empreinte carbone très faible. Ce produit a un impact limité sur le climat.';
    } else if (value <= 5.0) {
      return 'Empreinte carbone modérée. Ce produit a un impact moyen sur le climat.';
    } else if (value <= 15.0) {
      return 'Empreinte carbone élevée. Ce produit a un impact significatif sur le climat.';
    } else {
      return 'Empreinte carbone très élevée. Ce produit a un impact majeur sur le climat.';
    }
  }
  
  String _getWaterFootprintDescription(double value) {
    if (value <= 500) {
      return 'Consommation d\'eau faible. La production de ce produit nécessite peu d\'eau.';
    } else if (value <= 2000) {
      return 'Consommation d\'eau modérée. La production de ce produit nécessite une quantité moyenne d\'eau.';
    } else if (value <= 10000) {
      return 'Consommation d\'eau élevée. La production de ce produit nécessite beaucoup d\'eau.';
    } else {
      return 'Consommation d\'eau très élevée. La production de ce produit nécessite une quantité d\'eau exceptionnelle.';
    }
  }
  
  Color _getCarbonIntensityColor(double percentage) {
    if (percentage <= 0.2) return Colors.green;
    if (percentage <= 0.4) return Colors.lightGreen;
    if (percentage <= 0.6) return Colors.orange;
    if (percentage <= 0.8) return Colors.deepOrange;
    return Colors.red;
  }
} 