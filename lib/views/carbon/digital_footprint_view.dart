import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/digital_carbon_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DigitalFootprintView extends StatefulWidget {
  const DigitalFootprintView({Key? key}) : super(key: key);

  @override
  State<DigitalFootprintView> createState() => _DigitalFootprintViewState();
}

class _DigitalFootprintViewState extends State<DigitalFootprintView> {
  bool _isAnalyzing = false;
  bool _hasAnalysis = false;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    
    // Vérifier si une analyse existe déjà
    final digitalCarbonService = Provider.of<DigitalCarbonService>(context, listen: false);
    if (digitalCarbonService.lastAnalysis != null) {
      _analysis = digitalCarbonService.lastAnalysis;
      _hasAnalysis = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empreinte Numérique'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Consumer<DigitalCarbonService>(
        builder: (context, digitalCarbonService, child) {
          // Mise à jour de l'analyse si le service a de nouvelles données
          if (!_hasAnalysis && digitalCarbonService.lastAnalysis != null) {
            _analysis = digitalCarbonService.lastAnalysis;
            _hasAnalysis = true;
          }
          
          return _buildContent(digitalCarbonService);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isAnalyzing ? null : _analyzeFootprint,
        backgroundColor: _isAnalyzing ? Colors.grey : AppColors.secondaryColor,
        child: _isAnalyzing 
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildContent(DigitalCarbonService service) {
    if (_isAnalyzing) {
      return _buildAnalyzingView();
    } else if (_hasAnalysis) {
      return _buildAnalysisResults();
    } else {
      return _buildInitialView();
    }
  }
  
  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.devices,
              size: 80,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analysez votre empreinte numérique',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Découvrez l\'impact environnemental de votre utilisation des appareils et services numériques.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _analyzeFootprint,
            icon: const Icon(Icons.analytics),
            label: const Text('Analyser maintenant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyzingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyse en cours...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Nous collectons les données d\'utilisation de vos appareils pour calculer votre empreinte numérique.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisResults() {
    if (_analysis == null) return _buildInitialView();
    
    final dailyEmissions = _analysis!['estimatedFootprint']['totalEmissions']['daily'] as double? ?? 0.0;
    final monthlyEmissions = _analysis!['estimatedFootprint']['totalEmissions']['monthly'] as double? ?? 0.0;
    final yearlyEmissions = _analysis!['estimatedFootprint']['totalEmissions']['yearly'] as double? ?? 0.0;
    final unit = _analysis!['estimatedFootprint']['totalEmissions']['unit'] as String? ?? 'kg CO2e';
    
    final breakdown = _analysis!['estimatedFootprint']['breakdown'] as Map<String, dynamic>? ?? {};
    final recommendations = _analysis!['estimatedFootprint']['recommendations'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmissionsSummary(dailyEmissions, monthlyEmissions, yearlyEmissions, unit),
          const SizedBox(height: 20),
          if (breakdown.isNotEmpty) _buildBreakdownChart(breakdown),
          const SizedBox(height: 20),
          _buildScreenTimeAnalysis(),
          const SizedBox(height: 20),
          _buildRecommendations(recommendations),
          const SizedBox(height: 20),
          _buildComparisonMetrics(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildEmissionsSummary(double daily, double monthly, double yearly, String unit) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Votre empreinte numérique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmissionValue('Par jour', daily, unit),
                _buildEmissionValue('Par mois', monthly, unit),
                _buildEmissionValue('Par an', yearly, unit),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmissionValue(String label, double value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _getEmissionColor(value),
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Color _getEmissionColor(double value) {
    // Couleur basée sur l'intensité des émissions (valeurs approximatives)
    if (value < 0.1) return Colors.green;
    if (value < 0.5) return Colors.lightGreen;
    if (value < 1.0) return Colors.amber;
    if (value < 2.0) return Colors.orange;
    return Colors.red;
  }
  
  Widget _buildBreakdownChart(Map<String, dynamic> breakdown) {
    final data = <String, double>{};
    double total = 0;
    
    // Extraire les données pour le graphique
    breakdown.forEach((key, value) {
      if (value is double) {
        data[key] = value;
        total += value;
      }
    });
    
    // Si pas de données ou total nul, afficher un message
    if (data.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }
    
    // Préparer les sections du pie chart
    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    
    int colorIndex = 0;
    data.forEach((key, value) {
      final percentage = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition de votre empreinte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...data.entries.map((entry) {
                          final index = data.keys.toList().indexOf(entry.key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
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
                                    _formatCategoryName(entry.key),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
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
  
  String _formatCategoryName(String name) {
    switch (name) {
      case 'screen':
        return 'Temps d\'écran';
      case 'streaming':
        return 'Streaming vidéo';
      case 'network':
        return 'Utilisation réseau';
      case 'storage':
        return 'Stockage cloud';
      default:
        return name;
    }
  }
  
  Widget _buildScreenTimeAnalysis() {
    final screenTime = _analysis!['screenTime'] as Map<String, dynamic>? ?? {};
    final dailyAverage = screenTime['dailyAverage'] as double? ?? 0.0;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_android, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Temps d\'écran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Moyenne quotidienne',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        dailyAverage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getScreenTimeColor(dailyAverage),
                        ),
                      ),
                      Text(
                        ' heures',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getScreenTimeMessage(dailyAverage),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
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
  
  Color _getScreenTimeColor(double hours) {
    if (hours < 2) return Colors.green;
    if (hours < 4) return Colors.amber;
    if (hours < 6) return Colors.orange;
    return Colors.red;
  }
  
  String _getScreenTimeMessage(double hours) {
    if (hours < 2) {
      return 'Votre utilisation est très raisonnable et a un impact limité sur l\'environnement.';
    } else if (hours < 4) {
      return 'Votre utilisation est dans la moyenne. Pensez à faire des pauses régulières.';
    } else if (hours < 6) {
      return 'Votre utilisation est élevée. Réduire votre temps d\'écran serait bénéfique pour l\'environnement et votre bien-être.';
    } else {
      return 'Votre utilisation est très élevée. Essayez d\'établir des limites et des moments sans écrans.';
    }
  }
  
  Widget _buildRecommendations(List<dynamic> recommendations) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recommandations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) {
              if (recommendation is String) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComparisonMetrics() {
    final comparisonMetrics = _analysis!['estimatedFootprint']['comparisonMetrics'] as Map<String, dynamic>? ?? {};
    final treeMonths = comparisonMetrics['treeMonths'] as double? ?? 0.0;
    final carKm = comparisonMetrics['carKm'] as double? ?? 0.0;
    
    if (comparisonMetrics.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Pour mieux comprendre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.nature,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Un arbre met environ ${treeMonths.toStringAsFixed(1)} mois pour absorber votre empreinte numérique mensuelle',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Votre empreinte numérique quotidienne équivaut à ${carKm.toStringAsFixed(1)} km parcourus en voiture',
                      style: const TextStyle(fontSize: 14),
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
  
  Future<void> _analyzeFootprint() async {
    if (_isAnalyzing) return;
    
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      final service = Provider.of<DigitalCarbonService>(context, listen: false);
      final result = await service.analyzeDigitalFootprintAutomatically();
      
      setState(() {
        _analysis = result;
        _hasAnalysis = result.isNotEmpty;
        _isAnalyzing = false;
      });
    } catch (e) {
      print('Erreur lors de l\'analyse de l\'empreinte numérique: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'analyse: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
} 