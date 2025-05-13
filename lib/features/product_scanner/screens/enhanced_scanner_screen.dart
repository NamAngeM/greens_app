import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:lottie/lottie.dart';
import '../services/agribalyse_service.dart';
import '../models/product_model.dart';
import 'product_carbon_detail_screen.dart';

class EnhancedScannerScreen extends StatefulWidget {
  const EnhancedScannerScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedScannerScreen> createState() => _EnhancedScannerScreenState();
}

class _EnhancedScannerScreenState extends State<EnhancedScannerScreen> with SingleTickerProviderStateMixin {
  // État du scanner
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _isContinuousScanMode = false;
  
  // Animation
  late AnimationController _animationController;
  
  // Service
  late AgribalyseService _agribalyseService;
  
  // Contrôleur de caméra
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  
  // Minuteur pour le scan continu
  Timer? _scanTimer;
  
  // Historique des scans
  List<Product> _scanHistory = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser l'animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Initialiser le service
    _agribalyseService = AgribalyseService();
    _initializeServices();
    
    // Initialiser la caméra
    _initializeCamera();
  }
  
  Future<void> _initializeServices() async {
    await _agribalyseService.initialize();
  }
  
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Erreur d\'initialisation de la caméra: $e');
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }
  
  // Lancer le scanner de code-barres
  Future<void> _scanBarcode() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#4CAF50',
        'Annuler',
        true,
        ScanMode.BARCODE,
      );
      
      if (!mounted) return;
      
      if (barcode != '-1') {
        await _processBarcode(barcode);
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
  
  // Traiter le code-barres scanné
  Future<void> _processBarcode(String barcode) async {
    setState(() => _isProcessing = true);
    
    try {
      // Simuler un délai de recherche
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Obtenir les informations du produit
      final product = _agribalyseService.findProductByBarcode(barcode);
      
      if (product != null) {
        // Ajouter à l'historique des scans
        setState(() {
          _scanHistory.insert(0, product);
          if (_scanHistory.length > 10) {
            _scanHistory = _scanHistory.sublist(0, 10);
          }
        });
        
        // Naviguer vers l'écran de détails du produit
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductCarbonDetailScreen(product: product),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit non trouvé. Veuillez réessayer.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  // Activer/désactiver le mode de scan continu
  void _toggleContinuousScanMode() {
    setState(() {
      _isContinuousScanMode = !_isContinuousScanMode;
    });
    
    if (_isContinuousScanMode) {
      _startContinuousScan();
    } else {
      _stopContinuousScan();
    }
  }
  
  // Démarrer le scan continu
  void _startContinuousScan() {
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isProcessing) {
        _scanBarcode();
      }
    });
  }
  
  // Arrêter le scan continu
  void _stopContinuousScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Écologique'),
        actions: [
          IconButton(
            icon: Icon(_isContinuousScanMode 
                ? Icons.loop : Icons.loop_outlined),
            onPressed: _toggleContinuousScanMode,
            tooltip: 'Mode scan continu',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildCameraPreviewPlaceholder(),
          ),
          Expanded(
            flex: 2,
            child: _scanHistory.isEmpty 
                ? _buildScanInstructions() 
                : _buildScanHistory(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _scanBarcode,
        label: _isProcessing 
            ? const Text('Analyse en cours...') 
            : const Text('Scanner un produit'),
        icon: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.qr_code_scanner),
        backgroundColor: _isProcessing ? Colors.grey : Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  // Construire un placeholder pour l'aperçu de la caméra
  Widget _buildCameraPreviewPlaceholder() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image stylisée qui simule une vue de caméra
          Lottie.asset(
            'assets/animations/barcode_scanner_idle.json',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Cadre de scan
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Animation de scan
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 
                      125 * _animationController.value * 2 - 125),
                  child: Container(
                    width: 250,
                    height: 2,
                    color: Colors.green.withOpacity(0.8),
                  ),
                );
              },
            ),
          ),
          // Indicateur de scan en cours
          if (_isProcessing)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Lottie.asset(
                  'assets/animations/scan_animation.json',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Instructions pour le scan
  Widget _buildScanInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.eco,
            size: 48,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Découvrez l\'impact environnemental de vos achats',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Scannez un code-barres pour obtenir l\'empreinte carbone du produit et des recommandations écologiques',
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
  
  // Historique des scans
  Widget _buildScanHistory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produits récemment scannés',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _scanHistory.clear();
                  });
                },
                child: const Text('Effacer'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scanHistory.length,
            itemBuilder: (context, index) {
              final product = _scanHistory[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getEcoScoreColor(product.ecoScore),
                  child: Text(
                    _getEcoScoreGrade(product.ecoScore),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(product.name),
                subtitle: Text('${product.category} • ${product.carbonFootprint} kg CO2'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductCarbonDetailScreen(
                        product: product,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Obtenir la couleur correspondant au score écologique
  Color _getEcoScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.orange;
    if (score >= 2) return Colors.deepOrange;
    return Colors.red;
  }
  
  // Obtenir la lettre correspondant au score écologique
  String _getEcoScoreGrade(double score) {
    if (score >= 8) return 'A';
    if (score >= 6) return 'B';
    if (score >= 4) return 'C';
    if (score >= 2) return 'D';
    return 'E';
  }
} 