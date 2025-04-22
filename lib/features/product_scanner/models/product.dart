import 'package:flutter/material.dart';

class Product {
  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final double ecoScore;
  final Map<String, dynamic> environmentalImpact;
  final List<String> ingredients;
  final List<Map<String, dynamic>> alternatives;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.ecoScore,
    required this.environmentalImpact,
    required this.ingredients,
    required this.alternatives,
  });

  // Fonction factory pour créer un produit fictif à des fins de démonstration
  factory Product.mockProduct({required String barcode}) {
    return Product(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      barcode: barcode,
      name: 'Shampooing Bio Aloe Vera',
      brand: 'NaturGreen',
      category: 'Hygiène & Beauté',
      imageUrl: 'https://images.unsplash.com/photo-1556227834-09f1de7a7d14',
      ecoScore: 75.0,
      environmentalImpact: {
        'carbonFootprint': 2.3, // en kg CO2e
        'waterUsage': 45.0, // en litres
        'transportDistance': 320.0, // en km
        'transportType': 'camion',
        'origin': 'France',
        'packagingRecyclability': 80.0, // en pourcentage
        'biodegradable': true,
        'sustainablySourced': true,
        'veganFriendly': true,
        'palmOilFree': true,
        'digitalEmissions': 0.35, // en kg CO2e
        'dataUsage': 250, // en MB
        'serverLocation': 'Europe', // localisation des serveurs
        'soundLevel': 65.5, // en décibels (dB)
        'deviceType': 'Appareil électronique',
        'hasNoiseReduction': true,
      },
      ingredients: [
        'Aqua',
        'Aloe Barbadensis Leaf Juice',
        'Sodium Coco-Sulfate',
        'Coco-Glucoside',
        'Glycerin',
        'Citric Acid',
        'Sodium Benzoate',
        'Potassium Sorbate',
        'Parfum',
      ],
      alternatives: [
        {
          'id': 'alt_01',
          'name': 'Shampooing Solide Bio',
          'brand': 'EcoLavande',
          'ecoScore': 92.0,
          'imageUrl': 'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f',
        },
        {
          'id': 'alt_02',
          'name': 'Shampooing Revitalisant Naturel',
          'brand': 'BioPure',
          'ecoScore': 82.0,
          'imageUrl': 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d',
        },
        {
          'id': 'alt_03',
          'name': 'Barre de Shampooing Zéro Déchets',
          'brand': 'NoWaste',
          'ecoScore': 95.0,
          'imageUrl': 'https://images.unsplash.com/photo-1597354984706-fac992d9306f',
        },
      ],
    );
  }

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

  // Cloner un produit avec de nouvelles valeurs
  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
    double? ecoScore,
    Map<String, dynamic>? environmentalImpact,
    List<String>? ingredients,
    List<Map<String, dynamic>>? alternatives,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      ecoScore: ecoScore ?? this.ecoScore,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      ingredients: ingredients ?? this.ingredients,
      alternatives: alternatives ?? this.alternatives,
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
      'environmentalImpact': environmentalImpact,
      'ingredients': ingredients,
      'alternatives': alternatives,
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
      ecoScore: map['ecoScore'] ?? 0.0,
      environmentalImpact: map['environmentalImpact'] ?? {},
      ingredients: List<String>.from(map['ingredients'] ?? []),
      alternatives: List<Map<String, dynamic>>.from(map['alternatives'] ?? []),
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

class Ingredient {
  final String name;
  final bool sustainable;
  final String origin;

  const Ingredient({
    required this.name,
    required this.sustainable,
    required this.origin,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sustainable': sustainable,
      'origin': origin,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      sustainable: map['sustainable'] ?? false,
      origin: map['origin'] ?? 'Origine inconnue',
    );
  }
} 