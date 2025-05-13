import 'package:flutter/material.dart';

class Product {
  final String id;
  final String? barcode;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final double ecoScore;
  final double carbonFootprint;
  final double waterFootprint;
  final bool recyclablePackaging;
  final List<String> ingredients;
  final Map<String, dynamic> nutritionalInfo;
  final Map<String, dynamic>? environmentalImpact;
  final DateTime scannedAt;
  
  Product({
    required this.id,
    this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl = '',
    required this.ecoScore,
    required this.carbonFootprint,
    required this.waterFootprint,
    this.recyclablePackaging = false,
    this.ingredients = const [],
    this.nutritionalInfo = const {},
    this.environmentalImpact,
    required this.scannedAt,
  });
  
  // Créer une copie avec certaines valeurs modifiées
  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
    double? ecoScore,
    double? carbonFootprint,
    double? waterFootprint,
    bool? recyclablePackaging,
    List<String>? ingredients,
    Map<String, dynamic>? nutritionalInfo,
    Map<String, dynamic>? environmentalImpact,
    DateTime? scannedAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      ecoScore: ecoScore ?? this.ecoScore,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      waterFootprint: waterFootprint ?? this.waterFootprint,
      recyclablePackaging: recyclablePackaging ?? this.recyclablePackaging,
      ingredients: ingredients ?? this.ingredients,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }
  
  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'imageUrl': imageUrl,
      'ecoScore': ecoScore,
      'carbonFootprint': carbonFootprint,
      'waterFootprint': waterFootprint,
      'recyclablePackaging': recyclablePackaging,
      'ingredients': ingredients,
      'nutritionalInfo': nutritionalInfo,
      'environmentalImpact': environmentalImpact,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }
  
  // Créer un produit à partir d'un Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      barcode: map['barcode'],
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ecoScore: map['ecoScore']?.toDouble() ?? 0.0,
      carbonFootprint: map['carbonFootprint']?.toDouble() ?? 0.0,
      waterFootprint: map['waterFootprint']?.toDouble() ?? 0.0,
      recyclablePackaging: map['recyclablePackaging'] ?? false,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      nutritionalInfo: Map<String, dynamic>.from(map['nutritionalInfo'] ?? {}),
      environmentalImpact: map['environmentalImpact'] != null
          ? Map<String, dynamic>.from(map['environmentalImpact'])
          : null,
      scannedAt: map['scannedAt'] != null
          ? DateTime.parse(map['scannedAt'])
          : DateTime.now(),
    );
  }
  
  // Créer un produit fictif pour les tests
  static Product mock() {
    return Product(
      id: 'mock_id',
      barcode: '3000000000000',
      name: 'Produit Exemple',
      brand: 'Marque Bio',
      category: 'Fruits',
      imageUrl: '',
      ecoScore: 8.5,
      carbonFootprint: 0.5,
      waterFootprint: 700.0,
      recyclablePackaging: true,
      ingredients: ['Ingrédient 1', 'Ingrédient 2'],
      nutritionalInfo: {
        'Calories': '80 kcal',
        'Lipides': '0.2g',
        'Glucides': '20g',
        'Protéines': '0.5g',
      },
      environmentalImpact: {
        'carbon': {
          'value': 0.5,
          'details': {
            'production': 0.3,
            'transport': 0.1,
            'packaging': 0.05,
            'processing': 0.05,
          },
          'equivalents': {
            'km_voiture': 2.1,
            'charges_smartphone': 125.0,
            'arbres_necessaires': 0.02,
            'jours_chauffage': 0.03,
          },
        },
        'water': {
          'value': 700.0,
        },
        'ecoScore': 8.5,
        'ecoTips': [
          'Privilégiez les produits locaux et de saison',
          'Achetez des fruits et légumes de saison et produits localement',
        ],
      },
      scannedAt: DateTime.now(),
    );
  }
  
  // Créer un produit fictif avec un code-barres spécifique pour les tests
  static Product mockProduct({required String barcode}) {
    return Product(
      id: 'product_$barcode',
      barcode: barcode,
      name: 'Produit $barcode',
      brand: 'Marque Test',
      category: 'Test',
      imageUrl: '',
      ecoScore: 5.0,
      carbonFootprint: 2.5,
      waterFootprint: 1000.0,
      recyclablePackaging: false,
      ingredients: ['Ingrédient Test'],
      nutritionalInfo: {
        'Calories': '100 kcal',
      },
      environmentalImpact: {
        'carbon': {
          'value': 2.5,
          'details': {
            'production': 1.8,
            'transport': 0.3,
            'packaging': 0.2,
            'processing': 0.2,
          },
        },
        'water': {
          'value': 1000.0,
        },
      },
      scannedAt: DateTime.now(),
    );
  }
} 