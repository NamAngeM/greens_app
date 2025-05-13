import 'package:flutter/material.dart';
import 'package:greens_app/services/ar_eco_impact_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/services/product_scan_service.dart';
import 'package:greens_app/services/environmental_impact_service.dart';

class AREnvironmentalImpactView extends StatefulWidget {
  final String? barcode; // Paramètre optionnel pour le code-barres (si déjà scanné)
  
  const AREnvironmentalImpactView({
    Key? key,
    this.barcode,
  }) : super(key: key);

  @override
  State<AREnvironmentalImpactView> createState() => _AREnvironmentalImpactViewState();
}

class _AREnvironmentalImpactViewState extends State<AREnvironmentalImpactView> with WidgetsBindingObserver {
  late AREnvironmentalImpactService _arService;
  bool _isInitialized = false;
  String? _userId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialiser la caméra après le build initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAR();
    });
    
    // Récupérer l'ID utilisateur
    _userId = Provider.of<AuthController>(context, listen: false).currentUser?.uid;
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gérer les changements d'état du cycle de vie de l'application
    final cameraController = _arService.cameraController;
    
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeAR();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }
  
  // Initialise le service AR et la caméra
  Future<void> _initializeAR() async {
    try {
      // Créer le service AR s'il n'existe pas déjà
      if (!_isInitialized) {
        final productScanService = Provider.of<ProductScanService>(context, listen: false);
        final environmentalImpactService = Provider.of<EnvironmentalImpactService>(context, listen: false);
        
        _arService = AREnvironmentalImpactService(
          productScanService: productScanService,
          environmentalImpactService: environmentalImpactService,
        );
        
        // Initialiser la caméra
        await _arService.initializeCamera();
        
        setState(() {
          _isInitialized = true;
        });
        
        // Si un code-barres a été fourni, simuler un scan
        if (widget.barcode != null && _userId != null) {
          await _arService.simulateBarcodeScan(widget.barcode!, _userId!);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de la réalité augmentée: $e');
    }
  }
  
  // Libère les ressources de la caméra
  Future<void> _disposeCamera() async {
    if (_isInitialized) {
      await _arService.disposeCamera();
    }
  }
  
  // Simule un scan de code-barres (pour la démonstration)
  Future<void> _simulateScan() async {
    if (_isInitialized && _userId != null) {
      // Utiliser un code-barres fictif pour la démonstration
      await _arService.simulateBarcodeScan('5449000131805', _userId!);
    }
  }
  
  // Enregistre l'impact environnemental
  Future<void> _saveEnvironmentalImpact() async {
    if (_isInitialized && _userId != null && _arService.visualizationState.detectedProduct != null) {
      final product = _arService.visualizationState.detectedProduct!;
      await _arService.saveEnvironmentalImpact(
        _userId!,
        product.productName,
        product.carbonFootprint.toDouble(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impact environnemental enregistré avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualisation d\'impact AR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Paramètres de visualisation
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showVisualizationSettings,
          ),
        ],
      ),
      body: _isInitialized
          ? _buildARView()
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: _isInitialized 
          ? _buildFloatingActionButtons() 
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  // Construit la vue AR
  Widget _buildARView() {
    final cameraController = _arService.cameraController;
    
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: Text('Erreur lors de l\'initialisation de la caméra'),
      );
    }
    
    return Stack(
      children: [
        // Aperçu de la caméra
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(cameraController),
        ),
        
        // Superposition AR des impacts écologiques
        Consumer<AREnvironmentalImpactService>(
          builder: (context, service, child) {
            final state = service.visualizationState;
            
            // Afficher un message si aucun produit n'est détecté
            if (state.scanMessage != null && state.detectedProduct == null) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.scanMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            
            // Afficher les impacts si un produit est détecté
            if (state.impacts.isNotEmpty) {
              return _buildImpactsOverlay(state);
            }
            
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
  
  // Construit les boutons flottants
  Widget _buildFloatingActionButtons() {
    final state = _arService.visualizationState;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton pour effacer les résultats
          if (state.detectedProduct != null)
            FloatingActionButton(
              heroTag: 'clear',
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
              onPressed: () {
                _arService.clearResults();
              },
            )
          else
            const SizedBox(width: 56), // Espace réservé pour l'alignement
            
          // Bouton principal pour scanner ou enregistrer
          FloatingActionButton.extended(
            heroTag: 'main',
            backgroundColor: state.detectedProduct != null 
                ? Colors.green 
                : AppColors.primaryColor,
            label: Text(
              state.detectedProduct != null 
                  ? 'Enregistrer l\'impact' 
                  : 'Scanner un produit',
            ),
            icon: Icon(
              state.detectedProduct != null 
                  ? Icons.save 
                  : Icons.qr_code_scanner,
            ),
            onPressed: state.detectedProduct != null 
                ? _saveEnvironmentalImpact 
                : _simulateScan,
          ),
          
          // Bouton pour voir l'historique des scans
          FloatingActionButton(
            heroTag: 'history',
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.history),
            onPressed: _showScanHistory,
          ),
        ],
      ),
    );
  }
  
  // Construit la superposition des impacts écologiques en AR
  Widget _buildImpactsOverlay(ARVisualizationState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5 * (state.overlayOpacity ?? 0.8)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Produit détecté
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.detectedProductName ?? 'Produit inconnu',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Impacts environnementaux
          Expanded(
            child: ListView.builder(
              itemCount: state.impacts.length,
              itemBuilder: (context, index) {
                final impact = state.impacts[index];
                return _buildImpactItem(impact);
              },
            ),
          ),
          
          // Score écologique global
          if (state.detectedProduct != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getEcoScoreColor(state.detectedProduct!.ecoScore),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      state.detectedProduct!.ecoScore,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Score Écologique',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.detectedProduct!.ecoImpact ?? 'Impact environnemental non disponible',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Construit un élément d'impact individuel
  Widget _buildImpactItem(AREnvironmentalImpact impact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: impact.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco, // Utiliser une icône dynamique si possible
                  color: impact.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                impact.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            impact.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Valeur et unité
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    impact.value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: impact.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    impact.unit,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: impact.color,
                    ),
                  ),
                ],
              ),
              
              // Badge de comparaison
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: impact.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  impact.comparisonText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: impact.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Affiche les paramètres de visualisation
  void _showVisualizationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paramètres de visualisation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Afficher l'empreinte carbone
                  SwitchListTile(
                    title: const Text('Empreinte carbone'),
                    value: _arService.showCarbonFootprint,
                    onChanged: (value) {
                      setState(() {
                        _arService.updateVisualizationSettings(
                          showCarbonFootprint: value,
                        );
                      });
                    },
                  ),
                  
                  // Afficher la consommation d'eau
                  SwitchListTile(
                    title: const Text('Consommation d\'eau'),
                    value: _arService.showWaterUsage,
                    onChanged: (value) {
                      setState(() {
                        _arService.updateVisualizationSettings(
                          showWaterUsage: value,
                        );
                      });
                    },
                  ),
                  
                  // Afficher l'impact sur la déforestation
                  SwitchListTile(
                    title: const Text('Impact sur la forêt'),
                    value: _arService.showDeforestation,
                    onChanged: (value) {
                      setState(() {
                        _arService.updateVisualizationSettings(
                          showDeforestation: value,
                        );
                      });
                    },
                  ),
                  
                  // Afficher les alternatives
                  SwitchListTile(
                    title: const Text('Afficher les alternatives'),
                    value: _arService.showAlternatives,
                    onChanged: (value) {
                      setState(() {
                        _arService.updateVisualizationSettings(
                          showAlternatives: value,
                        );
                      });
                    },
                  ),
                  
                  // Opacité de la superposition
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Text('Opacité:'),
                        Expanded(
                          child: Slider(
                            value: _arService.visualizationState.overlayOpacity ?? 0.8,
                            min: 0.2,
                            max: 1.0,
                            divisions: 8,
                            onChanged: (value) {
                              setState(() {
                                _arService.updateVisualizationSettings(
                                  overlayOpacity: value,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Affiche l'historique des scans
  void _showScanHistory() {
    final history = _arService.scanHistory;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historique des scans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _arService.clearScanHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Effacer'),
                    ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text('Aucun scan récent'),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final scan = history[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getEcoScoreColor(scan['ecoScore']).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              scan['ecoScore'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getEcoScoreColor(scan['ecoScore']),
                              ),
                            ),
                          ),
                          title: Text(scan['productName']),
                          subtitle: Text(
                            'Scanné le ${_formatDate(DateTime.parse(scan['scanDate']))}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (_userId != null && scan['barcode'] != null) {
                              _arService.simulateBarcodeScan(scan['barcode'], _userId!);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
  
  // Formate la date pour l'affichage
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Obtient la couleur en fonction du score écologique
  Color _getEcoScoreColor(String? score) {
    switch (score) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.amber;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 