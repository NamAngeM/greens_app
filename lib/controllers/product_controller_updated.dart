import 'package:flutter/material.dart';
import 'package:greens_app/models/product_unified.dart';
import 'package:greens_app/services/product_service.dart';
import 'package:greens_app/services/mock_data_service.dart';
import 'package:greens_app/services/app_error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DataStatus {
  initial,
  loading,
  loaded,
  error,
  empty
}

class ProductControllerUpdated extends ChangeNotifier {
  final ProductService _productService;
  final MockDataService _mockDataService;
  final AppErrorHandler _errorHandler;
  
  List<UnifiedProduct> _allProducts = [];
  List<UnifiedProduct> _ecoFriendlyProducts = [];
  List<UnifiedProduct> _filteredProducts = [];
  
  String _errorMessage = '';
  DataStatus _status = DataStatus.initial;
  String _selectedCategory = 'All';
  UnifiedProduct? _selectedProduct;
  
  // Getters
  List<UnifiedProduct> get allProducts => _allProducts;
  List<UnifiedProduct> get ecoFriendlyProducts => _ecoFriendlyProducts;
  List<UnifiedProduct> get filteredProducts => _filteredProducts;
  String get errorMessage => _errorMessage;
  DataStatus get status => _status;
  String get selectedCategory => _selectedCategory;
  UnifiedProduct? get selectedProduct => _selectedProduct;
  
  bool get isLoading => _status == DataStatus.loading;
  bool get hasError => _status == DataStatus.error;
  bool get isEmpty => _status == DataStatus.empty;
  bool get isLoaded => _status == DataStatus.loaded;
  
  ProductControllerUpdated({
    required ProductService productService,
    required MockDataService mockDataService,
    required AppErrorHandler errorHandler,
  }) : _productService = productService,
       _mockDataService = mockDataService,
       _errorHandler = errorHandler;
  
  // Charger tous les produits
  Future<void> getAllProducts() async {
    _setStatus(DataStatus.loading);
    
    try {
      final products = await _errorHandler.handleFutureWithRetry(
        () => _productService.getAllProducts()
      );
      
      _allProducts = products;
      _filteredProducts = _allProducts;
      
      if (_allProducts.isEmpty) {
        _setStatus(DataStatus.empty);
      } else {
        _setStatus(DataStatus.loaded);
      }
    } on FirebaseException catch (e) {
      _setErrorStatus(_errorHandler.handleFirestoreError(e));
      
      // Fallback: utiliser les données de test
      _allProducts = _mockDataService.getEcoFriendlyProducts();
      _filteredProducts = _allProducts;
      notifyListeners();
    } catch (e) {
      _setErrorStatus('Erreur lors du chargement des produits: $e');
      
      // Fallback: utiliser les données de test
      _allProducts = _mockDataService.getEcoFriendlyProducts();
      _filteredProducts = _allProducts;
      notifyListeners();
    }
  }
  
  // Charger les produits écologiques
  Future<void> getEcoFriendlyProducts() async {
    _setStatus(DataStatus.loading);
    
    try {
      final products = await _errorHandler.handleFutureWithRetry(
        () => _productService.getEcoFriendlyProducts()
      );
      
      _ecoFriendlyProducts = products;
      
      if (_ecoFriendlyProducts.isEmpty) {
        _setStatus(DataStatus.empty);
        
        // Fallback: utiliser les données de test
        _ecoFriendlyProducts = _mockDataService.getEcoFriendlyProducts();
        notifyListeners();
      } else {
        _setStatus(DataStatus.loaded);
      }
    } on FirebaseException catch (e) {
      _setErrorStatus(_errorHandler.handleFirestoreError(e));
      
      // Fallback: utiliser les données de test
      _ecoFriendlyProducts = _mockDataService.getEcoFriendlyProducts();
      notifyListeners();
    } catch (e) {
      _setErrorStatus('Erreur lors du chargement des produits écologiques: $e');
      
      // Fallback: utiliser les données de test
      _ecoFriendlyProducts = _mockDataService.getEcoFriendlyProducts();
      notifyListeners();
    }
  }
  
  // Charger les produits par catégorie
  Future<void> getProductsByCategory(String category) async {
    _selectedCategory = category;
    _setStatus(DataStatus.loading);
    
    try {
      if (category == 'All') {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where(
          (product) => product.categories.contains(category)
        ).toList();
      }
      
      if (_filteredProducts.isEmpty) {
        _setStatus(DataStatus.empty);
      } else {
        _setStatus(DataStatus.loaded);
      }
    } catch (e) {
      _setErrorStatus('Erreur lors du filtrage des produits: $e');
    }
  }
  
  // Rechercher des produits
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _filteredProducts = _allProducts;
      notifyListeners();
      return;
    }
    
    _setStatus(DataStatus.loading);
    
    try {
      final lowercaseQuery = query.toLowerCase();
      
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(lowercaseQuery) ||
               product.description.toLowerCase().contains(lowercaseQuery) ||
               product.brand?.toLowerCase().contains(lowercaseQuery) == true ||
               product.categories.any((category) => 
                 category.toLowerCase().contains(lowercaseQuery)
               );
      }).toList();
      
      if (_filteredProducts.isEmpty) {
        _setStatus(DataStatus.empty);
      } else {
        _setStatus(DataStatus.loaded);
      }
    } catch (e) {
      _setErrorStatus('Erreur lors de la recherche de produits: $e');
    }
  }
  
  // Sélectionner un produit
  void selectProduct(String productId) {
    _setStatus(DataStatus.loading);
    
    try {
      _selectedProduct = _allProducts.firstWhere(
        (product) => product.id == productId
      );
      _setStatus(DataStatus.loaded);
    } catch (e) {
      _setErrorStatus('Produit non trouvé: $e');
    }
  }
  
  // Helpers
  void _setStatus(DataStatus status) {
    _status = status;
    notifyListeners();
  }
  
  void _setErrorStatus(String message) {
    _status = DataStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
  
  // Réinitialiser le contrôleur
  void reset() {
    _allProducts = [];
    _ecoFriendlyProducts = [];
    _filteredProducts = [];
    _errorMessage = '';
    _status = DataStatus.initial;
    _selectedCategory = 'All';
    _selectedProduct = null;
    notifyListeners();
  }
} 