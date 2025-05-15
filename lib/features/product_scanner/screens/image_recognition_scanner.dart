import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/product_recognition_service.dart';
import '../models/product_model.dart';
import 'product_carbon_detail_screen.dart';

class ImageRecognitionScannerScreen extends StatefulWidget {
  const ImageRecognitionScannerScreen({Key? key}) : super(key: key);

  @override
  State<ImageRecognitionScannerScreen> createState() => _ImageRecognitionScannerScreenState();
}

class _ImageRecognitionScannerScreenState extends State<ImageRecognitionScannerScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;
  File? _image;
  final List<String> _recentSearches = [];
  final List<String> _suggestedCategories = [
    'Fruits et légumes',
    'Produits laitiers',
    'Snacks',
    'Boissons',
    'Produits surgelés',
    'Viandes et poissons',
    'Épicerie',
  ];
  
  late ProductRecognitionService _recognitionService;
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _initializeServices();
    _initializeCamera();
  }
  
  Future<void> _initializeServices() async {
    _recognitionService = Provider.of<ProductRecognitionService>(context, listen: false);
    await _recognitionService.initialize();
  }
  
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      print('Erreur d\'initialisation de la caméra: $e');
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        
        // Analyser l'image
        await _recognizeProduct();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caméra non disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _image = File(photo.path);
      });
      
      // Analyser l'image
      await _recognizeProduct();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _recognizeProduct() async {
    if (_image == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Démarrer l'animation
      _animationController.repeat();
      
      final product = await _recognitionService.recognizeProductFromImage(_image!);
      
      if (!mounted) return;
      
      if (product != null) {
        // Ajouter à la recherche récente
        setState(() {
          _recentSearches.insert(0, product.name);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        });
        
        // Naviguer vers la page de détails
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductCarbonDetailScreen(product: product),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Désolé, le produit n\'a pas pu être identifié. Essayez avec une image plus claire ou un autre angle.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la reconnaissance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Arrêter l'animation
      _animationController.stop();
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  void _showCategorySearch(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité en cours de développement'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnaissance de Produits'),
      ),
      body: Column(
        children: [
          // Zone d'image / caméra
          Expanded(
            flex: 3,
            child: _buildImageSection(),
          ),
          
          // Zone d'information
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scannez un produit sans code-barres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Notre outil de reconnaissance d\'image peut identifier de nombreux produits alimentaires, cosmétiques et ménagers pour vous fournir leur impact environnemental.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Boutons de capture
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.photo_camera,
                        label: 'Prendre une photo',
                        onTap: _isProcessing ? null : () => _captureImage(),
                      ),
                      _buildActionButton(
                        icon: Icons.photo_library,
                        label: 'Galerie',
                        onTap: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recherches récentes
                  if (_recentSearches.isNotEmpty) ...[
                    const Text(
                      'Recherches récentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches.map((search) => 
                        Chip(
                          label: Text(search),
                          backgroundColor: Colors.grey[200],
                          avatar: const Icon(Icons.history, size: 16),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _recentSearches.remove(search);
                            });
                          },
                        )
                      ).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Catégories suggérées
                  const Text(
                    'Catégories populaires',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedCategories.map((category) => 
                      ActionChip(
                        label: Text(category),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        avatar: const Icon(Icons.category, size: 16, color: Colors.green),
                        onPressed: () => _showCategorySearch(category),
                      )
                    ).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Astuce
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Astuce : Pour de meilleurs résultats, prenez une photo bien éclairée et cadrée du produit.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageSection() {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/scanning.json',
                controller: _animationController,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Analyse du produit en cours...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous recherchons les informations environnementales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (_image != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _image!,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _image = null;
                });
              },
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    } else if (_cameraController != null && _cameraController!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
          // Overlay avec rectangle guide
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune image sélectionnée',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: width * 0.8,
      height: width * 0.8,
    );
    
    // Dessiner un rectangle semi-transparent sur l'extérieur
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRect(rect);
    
    canvas.drawPath(path, backgroundPaint);
    
    // Dessiner le cadre du scanner
    final scannerPaint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(rect, scannerPaint);
    
    // Ajouter des coins arrondis
    final cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    // Coin supérieur gauche
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerSize),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerSize, rect.top),
      cornerPaint,
    );
    
    // Coin supérieur droit
    canvas.drawLine(
      Offset(rect.right - cornerSize, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerSize),
      cornerPaint,
    );
    
    // Coin inférieur droit
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerSize),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerSize, rect.bottom),
      cornerPaint,
    );
    
    // Coin inférieur gauche
    canvas.drawLine(
      Offset(rect.left + cornerSize, rect.bottom),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerSize),
      cornerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
} 