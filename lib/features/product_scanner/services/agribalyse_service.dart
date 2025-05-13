import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:greens_app/features/product_scanner/models/product_model.dart';

class AgribalyseService {
  // Singleton pattern
  static final AgribalyseService _instance = AgribalyseService._internal();
  factory AgribalyseService() => _instance;
  AgribalyseService._internal();
  
  // Maps pour stocker les données Agribalyse
  Map<String, Map<String, dynamic>> _productsData = {};
  Map<String, Map<String, dynamic>> _carbonData = {};
  Map<String, Map<String, dynamic>> _waterData = {};
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadAgribalyseData();
    _isInitialized = true;
  }
  
  Future<void> _loadAgribalyseData() async {
    // Chargement des 3 fichiers CSV
    try {
      await _loadProductsData();
      await _loadCarbonFootprintData();
      await _loadWaterFootprintData();
      print('Données Agribalyse chargées avec succès');
    } catch (e) {
      print('Erreur lors du chargement des données Agribalyse: $e');
      // Créer des données de base si le chargement échoue
      _initializeDefaultData();
    }
  }
  
  Future<void> _loadProductsData() async {
    final data = await _loadCSV('assets/data/agribalyse_products.csv');
    for (var row in data) {
      if (row.length >= 4 && row[0] != null) {
        String productCode = row[0].toString();
        _productsData[productCode] = {
          'name': row[1],
          'category': row[2],
          'subCategory': row[3],
        };
      }
    }
  }
  
  Future<void> _loadCarbonFootprintData() async {
    final data = await _loadCSV('assets/data/agribalyse_carbon.csv');
    for (var row in data) {
      if (row.length >= 3 && row[0] != null) {
        String productCode = row[0].toString();
        _carbonData[productCode] = {
          'value': double.tryParse(row[1].toString()) ?? 0.0,
          'details': {
            'production': double.tryParse(row[2].toString()) ?? 0.0,
            'transport': double.tryParse(row[3].toString()) ?? 0.0,
            'packaging': double.tryParse(row[4].toString()) ?? 0.0,
            'processing': double.tryParse(row[5].toString()) ?? 0.0,
          }
        };
      }
    }
  }
  
  Future<void> _loadWaterFootprintData() async {
    final data = await _loadCSV('assets/data/agribalyse_water.csv');
    for (var row in data) {
      if (row.length >= 2 && row[0] != null) {
        String productCode = row[0].toString();
        _waterData[productCode] = {
          'value': double.tryParse(row[1].toString()) ?? 0.0,
        };
      }
    }
  }
  
  Future<List<List<dynamic>>> _loadCSV(String assetPath) async {
    try {
      final rawData = await rootBundle.loadString(assetPath);
      final csvTable = const CsvToListConverter().convert(rawData);
      // Ignorer l'en-tête
      return csvTable.sublist(1);
    } catch (e) {
      print('Erreur lors du chargement du CSV $assetPath: $e');
      return [];
    }
  }
  
  void _initializeDefaultData() {
    // Données par défaut si le chargement échoue
    _productsData = {
      '3000000000000': {'name': 'Pomme biologique', 'category': 'Fruits', 'subCategory': 'Fruits frais'},
      '3000000000017': {'name': 'Tomate française', 'category': 'Légumes', 'subCategory': 'Légumes frais'},
      '3000000000024': {'name': 'Boeuf haché', 'category': 'Viandes', 'subCategory': 'Viande bovine'},
      '3000000000031': {'name': 'Fromage blanc', 'category': 'Produits laitiers', 'subCategory': 'Fromages frais'},
      '3000000000048': {'name': 'Pain de campagne', 'category': 'Céréales', 'subCategory': 'Pains'},
    };
    
    _carbonData = {
      '3000000000000': {'value': 0.4, 'details': {'production': 0.3, 'transport': 0.05, 'packaging': 0.03, 'processing': 0.02}},
      '3000000000017': {'value': 0.7, 'details': {'production': 0.5, 'transport': 0.1, 'packaging': 0.07, 'processing': 0.03}},
      '3000000000024': {'value': 27.0, 'details': {'production': 25.0, 'transport': 0.5, 'packaging': 0.5, 'processing': 1.0}},
      '3000000000031': {'value': 3.0, 'details': {'production': 2.5, 'transport': 0.2, 'packaging': 0.2, 'processing': 0.1}},
      '3000000000048': {'value': 1.2, 'details': {'production': 0.8, 'transport': 0.1, 'packaging': 0.1, 'processing': 0.2}},
    };
    
    _waterData = {
      '3000000000000': {'value': 700.0},
      '3000000000017': {'value': 300.0},
      '3000000000024': {'value': 15400.0},
      '3000000000031': {'value': 1000.0},
      '3000000000048': {'value': 1300.0},
    };
  }
  
  // Méthodes pour accéder aux données Agribalyse
  
  Map<String, dynamic>? getProductData(String barcode) {
    if (!_isInitialized) {
      print('AgribalyseService non initialisée, initialisation...');
      initialize();
    }
    
    return _productsData[barcode];
  }
  
  double getCarbonFootprint(String barcode) {
    if (!_carbonData.containsKey(barcode)) {
      return _getCarbonFootprintByCategory(_getProductCategory(barcode));
    }
    return _carbonData[barcode]?['value'] ?? 0.0;
  }
  
  Map<String, double> getCarbonFootprintDetails(String barcode) {
    if (!_carbonData.containsKey(barcode)) {
      return {
        'production': 0.0,
        'transport': 0.0,
        'packaging': 0.0,
        'processing': 0.0,
      };
    }
    
    return Map<String, double>.from(_carbonData[barcode]?['details'] ?? {});
  }
  
  double getWaterFootprint(String barcode) {
    if (!_waterData.containsKey(barcode)) {
      return _getWaterFootprintByCategory(_getProductCategory(barcode));
    }
    return _waterData[barcode]?['value'] ?? 0.0;
  }
  
  String _getProductCategory(String barcode) {
    return _productsData[barcode]?['category'] ?? 'Non catégorisé';
  }
  
  // Obtenir une valeur approximative par catégorie
  double _getCarbonFootprintByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'viandes': 
        return 15.0;
      case 'produits laitiers': 
        return 5.0;
      case 'fruits': 
        return 0.5;
      case 'légumes': 
        return 0.7;
      case 'céréales': 
        return 1.2;
      case 'boissons': 
        return 0.8;
      default: 
        return 2.0;
    }
  }
  
  double _getWaterFootprintByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'viandes': 
        return 10000.0;
      case 'produits laitiers': 
        return 1500.0;
      case 'fruits': 
        return 700.0;
      case 'légumes': 
        return 300.0;
      case 'céréales': 
        return 1300.0;
      case 'boissons': 
        return 500.0;
      default: 
        return 1000.0;
    }
  }
  
  // Recherche approximative de produit par code-barres partiel
  Product? findProductByBarcode(String barcode) {
    // Rechercher une correspondance exacte
    if (_productsData.containsKey(barcode)) {
      final productData = _productsData[barcode]!;
      final carbonValue = getCarbonFootprint(barcode);
      final waterValue = getWaterFootprint(barcode);
      
      return Product(
        id: barcode,
        barcode: barcode,
        name: productData['name'] ?? 'Produit inconnu',
        brand: productData['subCategory'] ?? 'Marque inconnue',
        category: productData['category'] ?? 'Non catégorisé',
        imageUrl: '', // À compléter avec une image par défaut
        ecoScore: _calculateEcoScoreFromCarbonFootprint(carbonValue),
        carbonFootprint: carbonValue,
        waterFootprint: waterValue,
        recyclablePackaging: false, // À déterminer
        ingredients: [],
        nutritionalInfo: {},
        scannedAt: DateTime.now(),
      );
    }
    
    // Si aucune correspondance exacte, chercher par préfixe
    final matchingProducts = _productsData.entries
        .where((entry) => entry.key.startsWith(barcode.substring(0, math.min(8, barcode.length))))
        .toList();
    
    if (matchingProducts.isNotEmpty) {
      // Prendre le premier résultat
      final entry = matchingProducts.first;
      final productData = entry.value;
      final productBarcode = entry.key;
      final carbonValue = getCarbonFootprint(productBarcode);
      final waterValue = getWaterFootprint(productBarcode);
      
      return Product(
        id: productBarcode,
        barcode: productBarcode,
        name: productData['name'] ?? 'Produit inconnu',
        brand: productData['subCategory'] ?? 'Marque inconnue',
        category: productData['category'] ?? 'Non catégorisé',
        imageUrl: '', // À compléter avec une image par défaut
        ecoScore: _calculateEcoScoreFromCarbonFootprint(carbonValue),
        carbonFootprint: carbonValue,
        waterFootprint: waterValue,
        recyclablePackaging: false, // À déterminer
        ingredients: [],
        nutritionalInfo: {},
        scannedAt: DateTime.now(),
      );
    }
    
    return null;
  }
  
  // Calculer un eco-score basé sur l'empreinte carbone
  double _calculateEcoScoreFromCarbonFootprint(double carbonFootprint) {
    if (carbonFootprint <= 1.0) return 90.0; // A
    if (carbonFootprint <= 3.0) return 70.0; // B
    if (carbonFootprint <= 7.0) return 50.0; // C
    if (carbonFootprint <= 12.0) return 30.0; // D
    return 10.0; // E
  }
} 