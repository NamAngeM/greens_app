import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:uuid/uuid.dart';
import 'package:greens_app/services/product_scan_service.dart';

import '../views/blogs/blog_view.dart';

class ProductScanController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductScanService _scanService = ProductScanService();
  final List<ProductScan> _scanHistory = [];
  ProductScan? _lastScan;
  bool _isLoading = false;
  bool _isScanning = false;
  
  List<ProductScan> get scanHistory => _scanHistory;
  ProductScan? get lastScan => _lastScan;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  
  Future<void> getUserScanHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final history = await _scanService.getUserScanHistory(userId);
      _scanHistory.clear();
      _scanHistory.addAll(history);
      
      if (_scanHistory.isNotEmpty) {
        _lastScan = _scanHistory.first;
      }
    } catch (e) {
      print('Error fetching scan history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<ProductScan?> scanBarcode(String barcode, String userId) async {
    _isScanning = true;
    notifyListeners();
    
    try {
      // Vérifier si le produit existe dans la base de données
      final productSnapshot = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      
      if (productSnapshot.docs.isEmpty) {
        return null; // Produit non trouvé
      }
      
      final productData = productSnapshot.docs.first.data();
      
      // Créer un scan
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      
      final scan = ProductScan(
        id: uuid,
        userId: userId,
        barcode: barcode,
        productName: productData['name'] ?? 'Produit inconnu',
        brand: productData['brand'] ?? 'Marque inconnue',
        imageUrl: productData['imageUrl'] ?? '',
        ecoRating: EcoRating.values.firstWhere(
          (e) => e.toString() == 'EcoRating.${productData['ecoRating']}',
          orElse: () => EcoRating.unknown,
        ),
        ecoImpact: productData['ecoImpact'] ?? 'Impact environnemental non disponible',
        ecoTips: List<String>.from(productData['ecoTips'] ?? []),
        alternativeProductIds: List<String>.from(productData['alternativeProductIds'] ?? []),
        scanDate: now,
        ecoScore: productData['ecoScore'] ?? 'C',
        category: productData['category'] ?? 'Non catégorisé',
        ingredients: List<String>.from(productData['ingredients'] ?? []),
        origin: productData['origin'] ?? 'Inconnu',
        carbonFootprint: productData['carbonFootprint'] ?? 3,
        waterFootprint: productData['waterFootprint'] ?? 3,
        deforestationImpact: productData['deforestationImpact'] ?? 3,
        ecoAlternatives: (productData['ecoAlternatives'] as List<dynamic>?)
            ?.map((e) => EcoAlternative.fromJson(e))
            .toList() ?? [],
      );
      
      // Enregistrer le scan dans Firestore
      await _firestore.collection('product_scans').doc(uuid).set(scan.toJson());
      
      // Mettre à jour l'historique local
      _scanHistory.insert(0, scan);
      _lastScan = scan;
      
      notifyListeners();
      
      return scan;
    } catch (e) {
      print('Error scanning barcode: $e');
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
  
  Future<void> scanProduct(String barcode, String? userId) async {
    try {
      _isScanning = true;
      notifyListeners();
      
      // Déterminer la catégorie à partir du code-barres
      String category = _determineCategoryFromBarcode(barcode);
      
      // Obtenir les données du produit scanné depuis le service
      final scan = await _scanService.getProductInfo(
        barcode, 
        userId, 
        category: category
      );
      
      _lastScan = scan;
      _isScanning = false;
      notifyListeners();
      
    } catch (e) {
      print('Erreur lors du scan: $e');
      _isScanning = false;
      notifyListeners();
      rethrow;
    }
  }
  
  void resetLastScan() {
    _lastScan = null;
    notifyListeners();
  }
  
  ProductScan _getMockProductData(String barcode) {
    final uuid = const Uuid().v4();
    final now = DateTime.now();
    
    // Liste d'ingrédients fictifs
    final List<String> mockIngredients = [
      'Eau',
      'Sucre',
      'Colorant naturel',
      'Arôme naturel',
      'Conservateur E330'
    ];
    
    // Liste de conseils écologiques fictifs
    final List<String> mockEcoTips = [
      'Préférez les produits locaux pour réduire l\'empreinte carbone',
      'Recyclez l\'emballage après utilisation',
      'Optez pour des produits avec moins d\'emballage',
      'Privilégiez les produits avec certification écologique'
    ];
    
    // Alternatives écologiques fictives
    final List<EcoAlternative> mockAlternatives = [
      EcoAlternative(
        id: '1',
        name: 'Produit Eco-responsable',
        brand: 'Marque Verte',
        imageUrl: 'https://example.com/eco-product.jpg',
        ecoScore: 'A',
      ),
      EcoAlternative(
        id: '2',
        name: 'Alternative Naturelle',
        brand: 'Bio Nature',
        imageUrl: 'https://example.com/natural-product.jpg',
        ecoScore: 'B',
      ),
    ];
    
    return ProductScan(
      id: uuid,
      userId: 'anonymous',
      barcode: barcode,
      productName: 'Produit #$barcode',
      brand: 'Marque Générique',
      imageUrl: 'https://example.com/product-placeholder.jpg',
      ecoRating: EcoRating.average,
      ecoImpact: 'Ce produit a un impact moyen sur l\'environnement. Il utilise des matériaux partiellement recyclables et son processus de fabrication génère une empreinte carbone modérée.',
      ecoTips: mockEcoTips,
      alternativeProductIds: [],
      scanDate: now,
      ecoScore: 'C',
      category: 'Alimentation',
      ingredients: mockIngredients,
      origin: 'France',
      carbonFootprint: 3,
      waterFootprint: 2,
      deforestationImpact: 1,
      ecoAlternatives: mockAlternatives,
    );
  }
  
  Future<List<ProductModel>> getAlternativeProducts(List<String> productIds) async {
    try {
      final List<ProductModel> alternatives = [];
      
      for (var id in productIds) {
        final doc = await _firestore.collection('products').doc(id).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            data['id'] = doc.id;
            alternatives.add(ProductModel.fromJson(data));
          }
        }
      }
      
      return alternatives;
    } catch (e) {
      print('Error fetching alternative products: $e');
      return [];
    }
  }
  
  Future<bool> deleteScan(String scanId) async {
    try {
      await _firestore.collection('product_scans').doc(scanId).delete();
      
      _scanHistory.removeWhere((scan) => scan.id == scanId);
      if (_lastScan?.id == scanId) {
        _lastScan = _scanHistory.isNotEmpty ? _scanHistory.first : null;
      }
      
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error deleting scan: $e');
      return false;
    }
  }
  
  void clearScanHistory() {
    _scanHistory.clear();
    _lastScan = null;
    notifyListeners();
  }
  
  // Méthode pour détecter la catégorie du produit basée sur le code-barres
  String _determineCategoryFromBarcode(String barcode) {
    if (barcode.startsWith('978') || barcode.startsWith('979'))
      return "Livres & Médias";
    else if (RegExp(r'^(000|00[1-9]|0[1-9][0-9])').hasMatch(barcode))
      return "Électronique";
    else if (RegExp(r'^(45[0-9])').hasMatch(barcode))
      return "Vêtements & Mode";
    else if (RegExp(r'^(35[0-9])').hasMatch(barcode))
      return "Beauté & Cosmétiques";
    else if (RegExp(r'^(50[0-9])').hasMatch(barcode))
      return "Produits Ménagers";
    // Autres catégories spécifiques
    else
      return "Alimentation"; // Catégorie par défaut
  }
  
  // Méthode pour obtenir les champs spécifiques à la catégorie
  List<String> getCategorySpecificFields(String category) {
    switch(category) {
      case "Livres & Médias": 
        return ["Auteur", "Éditeur", "Pages", "ISBN"];
      case "Électronique": 
        return ["Marque", "Modèle", "Spécifications", "Garantie"];
      case "Vêtements & Mode": 
        return ["Marque", "Taille", "Matière", "Entretien"];
      // Autres catégories
      default: 
        return ["Ingrédients", "Nutrition", "Conservation"];
    }
  }
}