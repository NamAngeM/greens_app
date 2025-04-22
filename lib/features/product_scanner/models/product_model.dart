import 'package:flutter/material.dart';

class Product {
  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  
  // Informations environnementales
  final double ecoScore; // Score écologique sur 100
  final double carbonFootprint; // en kg CO2 eq
  final double waterFootprint; // en litres
  final bool recyclablePackaging;
  
  // Informations additionnelles
  final String ingredients;
  final Map<String, dynamic> nutritionalInfo;
  final DateTime scannedAt;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.ecoScore,
    required this.carbonFootprint,
    required this.waterFootprint,
    required this.recyclablePackaging,
    required this.ingredients,
    required this.nutritionalInfo,
    required this.scannedAt,
  });

  String get ecoScoreLabel {
    if (ecoScore >= 80) return 'A';
    if (ecoScore >= 60) return 'B';
    if (ecoScore >= 40) return 'C';
    if (ecoScore >= 20) return 'D';
    return 'E';
  }

  Color get ecoScoreColor {
    if (ecoScore >= 80) return const Color(0xFF1E8E3E); // Vert
    if (ecoScore >= 60) return const Color(0xFF81C784); // Vert clair
    if (ecoScore >= 40) return const Color(0xFFFBC02D); // Jaune
    if (ecoScore >= 20) return const Color(0xFFFF8A65); // Orange
    return const Color(0xFFE53935); // Rouge
  }

  // Méthode pour créer un produit fictif à des fins de test
  factory Product.mock() {
    return Product(
      id: 'mock-id',
      barcode: '3017620422003',
      name: 'Nutella',
      brand: 'Ferrero',
      category: 'Pâtes à tartiner',
      imageUrl: 'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.348.400.jpg',
      ecoScore: 28.5,
      carbonFootprint: 2.5,
      waterFootprint: 1200.0,
      recyclablePackaging: true,
      ingredients: 'Sucre, huile de palme, noisettes 13%, cacao maigre 7,4%, lait écrémé en poudre 6,6%, lactosérum en poudre, émulsifiants : lécithines [soja], vanilline.',
      nutritionalInfo: {
        'calories': 539.0,
        'fat': 30.9,
        'saturatedFat': 10.6,
        'carbohydrates': 57.5,
        'sugars': 56.3,
        'fiber': 3.4,
        'proteins': 6.3,
        'salt': 0.107,
      },
      scannedAt: DateTime.now(),
    );
  }

  // Cloner un produit avec de nouvelles valeurs
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
    String? ingredients,
    Map<String, dynamic>? nutritionalInfo,
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
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  // Converti le produit en Map pour le stockage local
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
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  // Crée un produit à partir d'une Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? 'Produit inconnu',
      brand: map['brand'] ?? 'Marque inconnue',
      category: map['category'] ?? 'Non catégorisé',
      imageUrl: map['imageUrl'] ?? '',
      ecoScore: (map['ecoScore'] ?? 0.0).toDouble(),
      carbonFootprint: (map['carbonFootprint'] ?? 0.0).toDouble(),
      waterFootprint: (map['waterFootprint'] ?? 0.0).toDouble(),
      recyclablePackaging: map['recyclablePackaging'] ?? false,
      ingredients: map['ingredients'] ?? 'Informations non disponibles',
      nutritionalInfo: map['nutritionalInfo'] ?? {},
      scannedAt: map['scannedAt'] != null 
          ? DateTime.parse(map['scannedAt']) 
          : DateTime.now(),
    );
  }

  // Vérifie si deux produits sont identiques
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          barcode == other.barcode;

  @override
  int get hashCode => barcode.hashCode;
} 