import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/product_database.dart';
import 'dart:async';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../services/product_service.dart';
import '../services/eco_product_api_service.dart';

enum ScannerState {
  initial,
  scanning,
  loading,
  success,
  error,
}

class ScannerController extends ChangeNotifier {
  final ProductDatabase _database;
  final ProductService _productService;
  final EcoProductApiService _ecoProductApiService;
  final ImagePicker _imagePicker;
  
  ScannerState _state = ScannerState.initial;
  ScannerState get state => _state;
  
  Product? _scannedProduct;
  List<Product> _alternatives = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _imageFile;
  
  List<Product> _scanHistory = [];
  List<Product> get scanHistory => _scanHistory;
  
  bool _isHistoryVisible = false;
  bool get isHistoryVisible => _isHistoryVisible;
  
  // Getters
  Product? get scannedProduct => _scannedProduct;
  List<Product> get alternatives => _alternatives;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get imageFile => _imageFile;
  
  ScannerController({
    required ProductService productService,
    ProductDatabase? database,
    EcoProductApiService? ecoProductApiService,
    ImagePicker? imagePicker,
  }) : 
    _productService = productService,
    _database = database ?? ProductDatabase(),
    _ecoProductApiService = ecoProductApiService ?? EcoProductApiService.instance,
    _imagePicker = imagePicker ?? ImagePicker();
  
  void toggleHistoryVisibility() {
    _isHistoryVisible = !_isHistoryVisible;
    notifyListeners();
  }
  
  // Scanner un produit par code-barres
  Future<void> scanBarcode() async {
    try {
      _setState(ScannerState.scanning);
      
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#4CAF50',
        'Annuler',
        true,
        ScanMode.BARCODE,
      );

      if (barcode == '-1') {
        // L'utilisateur a annulé le scan
        _setState(ScannerState.initial);
        return;
      }

      await _fetchProductInfo(barcode);
    } catch (e) {
      _setError('Erreur lors du scan: ${e.toString()}');
    }
  }
  
  // Scanner un produit par image
  Future<void> scanImage() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Prendre une photo avec l'appareil photo
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (pickedFile == null) {
        _setError('Aucune image sélectionnée');
        _setLoading(false);
        return;
      }
      
      _imageFile = File(pickedFile.path);
      
      // Analyser l'image pour identifier le produit
      final product = await _database.getProductByImage(pickedFile.path);
      
      if (product != null) {
        await _processScannedProduct(product);
      } else {
        _setError('Produit non identifié. Essayez de scanner le code-barres.');
      }
    } catch (e) {
      _setError('Erreur lors de l\'analyse de l\'image: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Traiter un produit scanné
  Future<void> _processScannedProduct(Product product) async {
    _scannedProduct = product;
    
    // Enregistrer le produit dans l'historique
    await _database.saveScannedProduct(product);
    
    // Récupérer des alternatives plus écologiques
    _alternatives = await _database.getAlternatives(product);
    
    notifyListeners();
  }
  
  // Obtenir l'historique des produits scannés
  Future<List<Product>> getScannedProductsHistory() async {
    return await _database.getScannedProducts();
  }
  
  // Obtenir le score écologique de l'utilisateur
  Future<double> getUserEcoScore() async {
    return await _database.calculateEcoScore();
  }
  
  // Obtenir des recommandations personnalisées
  Future<List<String>> getPersonalizedRecommendations() async {
    return await _database.generateRecommendations();
  }
  
  // Méthodes utilitaires
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _state = ScannerState.error;
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void reset() {
    _scannedProduct = null;
    _alternatives = [];
    _errorMessage = null;
    _imageFile = null;
    notifyListeners();
  }

  // Méthode exposée pour les tests
  @visibleForTesting
  Future<void> testFetchProductInfo(String barcode) async {
    return _fetchProductInfo(barcode);
  }

  Future<void> _fetchProductInfo(String barcode) async {
    try {
      _setState(ScannerState.loading);
      
      // Utiliser le nouveau service multi-sources pour obtenir des informations plus complètes
      final product = await _ecoProductApiService.getProductInfo(barcode);
      
      // Si le produit n'a pas été trouvé dans les APIs externes, essayer avec le service local
      if (product.name == 'Produit non trouvé') {
        try {
          final localProduct = await _productService.getProductByBarcode(barcode);
          _scannedProduct = localProduct;
        } catch (e) {
          // Si le produit n'est pas trouvé localement non plus, utiliser le produit minimal
          _scannedProduct = product;
        }
      } else {
        _scannedProduct = product;
      }
      
      // Ajouter le produit à l'historique
      _addToHistory(_scannedProduct!);
      
      // Rechercher des alternatives plus écologiques
      await _findAlternatives(_scannedProduct!);
      
      _setState(ScannerState.success);
    } catch (e) {
      _setError('Produit non trouvé ou erreur de connexion: ${e.toString()}');
    }
  }

  // Méthode exposée pour les tests
  @visibleForTesting
  Future<void> testFindAlternatives(Product product) async {
    return _findAlternatives(product);
  }

  // Rechercher des alternatives plus écologiques
  Future<void> _findAlternatives(Product product) async {
    try {
      _alternatives = await _database.getAlternatives(product);
      
      // Si aucune alternative n'est trouvée dans la base de données locale,
      // essayer de rechercher des produits similaires dans la même catégorie
      if (_alternatives.isEmpty) {
        try {
          final similarProducts = await _productService.searchProducts(product.category);
          
          // Filtrer pour ne garder que les produits avec un meilleur eco-score
          _alternatives = similarProducts
              .where((p) => p.ecoScore > product.ecoScore)
              .toList();
          
          // Trier par eco-score décroissant
          _alternatives.sort((a, b) => b.ecoScore.compareTo(a.ecoScore));
          
          // Limiter à 5 alternatives
          if (_alternatives.length > 5) {
            _alternatives = _alternatives.sublist(0, 5);
          }
        } catch (e) {
          debugPrint('Erreur lors de la recherche d\'alternatives: $e');
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'alternatives: $e');
    }
  }

  void _addToHistory(Product product) {
    // Éviter les doublons dans l'historique en vérifiant le code-barres
    if (!_scanHistory.any((p) => p.barcode == product.barcode)) {
      _scanHistory.add(product);
    }
  }

  void clearScannedProduct() {
    _scannedProduct = null;
    _setState(ScannerState.initial);
  }

  void _setState(ScannerState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void mockScan() async {
    _setState(ScannerState.loading);
    await Future.delayed(const Duration(seconds: 1));
    _scannedProduct = Product.mock();
    _addToHistory(_scannedProduct!);
    _setState(ScannerState.success);
  }
}