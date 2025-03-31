import 'package:flutter/material.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/services/product_service.dart';

class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _ecoFriendlyProducts = [];
  List<ProductModel> _filteredProducts = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get ecoFriendlyProducts => _ecoFriendlyProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Récupérer tous les produits
  Future<void> getAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await _productService.getAllProducts();
      _filteredProducts = _allProducts;
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des produits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer les produits écologiques
  Future<void> getEcoFriendlyProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ecoFriendlyProducts = await _productService.getEcoFriendlyProducts();
      _filteredProducts = _ecoFriendlyProducts;
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des produits écologiques: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer les produits par catégorie
  Future<void> getProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _filteredProducts = await _productService.getProductsByCategory(category);
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des produits par catégorie: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer un produit par son ID
  Future<void> getProductById(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(productId);
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération du produit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rechercher des produits
  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = await _productService.searchProducts(query);
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche de produits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Appliquer un coupon à un produit
  Future<bool> applyDiscountCoupon(String productId, double discountPercentage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final discountedProduct = await _productService.applyDiscountCoupon(
        productId, 
        discountPercentage
      );
      
      if (discountedProduct != null) {
        _selectedProduct = discountedProduct;
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'application du coupon: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sélectionne un produit et le définit comme produit actuel
  void selectProduct(ProductModel product) {
    try {
      _selectedProduct = product;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection du produit: $e';
    }
  }
}
