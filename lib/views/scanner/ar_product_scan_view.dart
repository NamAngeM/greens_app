import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/ar_product_scan_service.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class ARProductScanView extends StatefulWidget {
  const ARProductScanView({Key? key}) : super(key: key);

  @override
  State<ARProductScanView> createState() => _ARProductScanViewState();
}

class _ARProductScanViewState extends State<ARProductScanView> with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _hasCameraPermission = false;
  CameraController? _cameraController;
  ARProductScanService? _scanService;
  ProductScanResult? _lastScanResult;
  String? _error;
  bool _isScanning = false;
  
  // ML Kit detectors
  final ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();
  final BarcodeScanner _barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialiser le service et la caméra
    _initializeARScan();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scanService ??= Provider.of<ARProductScanService>(context, listen: false);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _imageLabeler.close();
    _barcodeScanner.close();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gérer les changements d'état de l'application (pause, reprise, etc.)
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  /// Initialiser le service AR et demander les permissions
  Future<void> _initializeARScan() async {
    try {
      // Vérifier les permissions
      final status = await Permission.camera.request();
      if (status.isGranted) {
        setState(() {
          _hasCameraPermission = true;
        });

        // Initialiser la caméra
        await _initializeCamera();
        
        // Initialiser le service AR
        if (_scanService == null) {
          _scanService = Provider.of<ARProductScanService>(context, listen: false);
        }
        
        final initialized = await _scanService!.initialize();
        if (!initialized) {
          setState(() {
            _error = _scanService!.error ?? "Échec de l'initialisation du service AR";
          });
          return;
        }
        
        setState(() {
          _isInitialized = true;
        });
      } else {
        setState(() {
          _hasCameraPermission = false;
          _error = "Permission de caméra refusée";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur lors de l'initialisation: $e";
      });
    }
  }
  
  /// Initialiser la caméra
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = "Aucune caméra disponible";
        });
        return;
      }
      
      // Utiliser la caméra arrière par défaut
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      if (!mounted) return;
      
      setState(() {});
    } catch (e) {
      setState(() {
        _error = "Erreur d'initialisation de la caméra: $e";
      });
    }
  }
  
  /// Capture d'une image pour analyser le produit
  Future<void> _scanProduct() async {
    if (_isScanning || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      // Capturer une image de la caméra
      final XFile image = await _cameraController!.takePicture();
      
      // Créer un InputImage pour ML Kit à partir du XFile
      final inputImage = InputImage.fromFilePath(image.path);
      
      // Utiliser ML Kit pour analyser l'image (détection d'objets)
      final labels = await _imageLabeler.processImage(inputImage);
      
      // Utiliser ML Kit pour détecter les codes-barres
      final barcodes = await _barcodeScanner.processImage(inputImage);
      
      // Traiter les résultats
      String productName = "Produit Écologique";
      String productBrand = "EcoBrand";
      String? barcode;
      double ecoScore = 8.5;
      
      if (labels.isNotEmpty) {
        // Utiliser les labels pour identifier le produit
        productName = labels.first.label;
      }
      
      if (barcodes.isNotEmpty) {
        barcode = barcodes.first.rawValue;
      }
      
      // En production, on utiliserait ces informations pour chercher le produit 
      // dans une base de données. Ici, nous simulons un résultat.
      
      _lastScanResult = ProductScanResult(
        productId: 'ml-product-${DateTime.now().millisecondsSinceEpoch}',
        productName: productName,
        productBrand: productBrand,
        barcode: barcode,
        ecoScore: ecoScore,
        productDetails: {
          'origine': 'France',
          'matériaux': 'Recyclé à 80%',
          'empreinte_carbone': '0.8kg CO2',
          'certification': 'Écolabel européen',
        },
        ecoTips: [
          'Ce produit est fabriqué à partir de matériaux recyclés',
          'Pensez à recycler l\'emballage après usage',
          'Économisez 30% d\'énergie en utilisant ce produit à basse température'
        ],
        alternatives: [
          'Alternative Bio Premium',
          'EcoProduit Avancé',
          'Produit Zéro Déchet'
        ],
        imageUrl: 'https://example.com/product-image.jpg',
        scanDate: DateTime.now(),
      );
      
      // Afficher les résultats
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        
        // Afficher les détails du produit
        _showProductDetails();
      }
      
      // Supprimer le fichier temporaire
      try {
        final File fileToDelete = File(image.path);
        if (await fileToDelete.exists()) {
          await fileToDelete.delete();
        }
      } catch (e) {
        print('Erreur lors de la suppression du fichier temporaire: $e');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _error = "Erreur lors de l'analyse: $e";
        });
      }
    }
  }
  
  /// Affiche une superposition AR avec les informations du produit
  void _showAROverlay() {
    // Cette méthode serait utilisée pour afficher des informations AR
    // via le service AR, mais nous nous concentrons sur l'UI pour l'exemple
  }
  
  /// Affiche un dialogue avec les détails du produit scanné
  void _showProductDetails() {
    if (_lastScanResult == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _buildProductDetailsSheet(scrollController),
      ),
    );
  }
  
  /// Construit la feuille de détails du produit
  Widget _buildProductDetailsSheet(ScrollController scrollController) {
    final result = _lastScanResult!;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // Poignée de glissement
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Titre du produit
          Text(
            result.productName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            result.productBrand,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Score écologique
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _getEcoScoreColor(result.ecoScore).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  color: _getEcoScoreColor(result.ecoScore),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Éco-Score: ${result.ecoScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getEcoScoreColor(result.ecoScore),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Détails du produit
          const Text(
            'Détails du produit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...result.productDetails.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_capitalizeFirstLetter(entry.key)}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          
          // Conseils écologiques
          const Text(
            'Conseils écologiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...result.ecoTips.map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tip),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          
          // Alternatives
          if (result.alternatives != null && result.alternatives!.isNotEmpty) ...[
            const Text(
              'Alternatives écologiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...result.alternatives!.map((alt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(alt),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          
          // Bouton d'action
          ElevatedButton(
            onPressed: () {
              // Ajouter à la liste de courses, partager, etc.
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Ajouter à mes favoris',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner AR de produits'),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Afficher l'historique des scans
              // TODO: Implémenter l'écran d'historique
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isInitialized && !_isScanning
          ? FloatingActionButton(
              onPressed: _scanProduct,
              backgroundColor: Colors.green,
              child: const Icon(Icons.camera_alt),
            )
          : null,
    );
  }
  
  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeARScan,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    if (!_hasCameraPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              color: Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Permission de caméra nécessaire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous avons besoin d\'accéder à votre caméra pour scanner les produits',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final status = await Permission.camera.request();
                setState(() {
                  _hasCameraPermission = status.isGranted;
                });
                if (status.isGranted) {
                  _initializeARScan();
                }
              },
              child: const Text('Accorder l\'accès'),
            ),
          ],
        ),
      );
    }
    
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Stack(
      children: [
        // Aperçu de la caméra
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
        
        // Overlay AR
        if (_isInitialized)
          Positioned.fill(
            child: _buildAROverlay(),
          ),
        
        // Indicateur de scan
        if (_isScanning)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyse du produit...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Guide visuel pour le scan
        if (!_isScanning)
          Positioned.fill(
            child: _buildScanGuide(),
          ),
      ],
    );
  }
  
  /// Construit l'overlay AR
  Widget _buildAROverlay() {
    // Cette fonction construirait l'overlay AR avec des informations sur le produit
    // Pour l'exemple, on renvoie juste un widget transparent
    return Container(
      color: Colors.transparent,
    );
  }
  
  /// Construit le guide visuel pour le scan
  Widget _buildScanGuide() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_enhance,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pointez la caméra vers un produit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Obtenir la couleur en fonction du score écologique
  Color _getEcoScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.green.shade300;
    if (score >= 4.0) return Colors.orange;
    if (score >= 2.0) return Colors.orange.shade700;
    return Colors.red;
  }
  
  /// Mettre en majuscule la première lettre d'une chaîne
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
} 