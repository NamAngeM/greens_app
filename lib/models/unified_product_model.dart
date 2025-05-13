import 'package:flutter/material.dart';
import 'package:greens_app/models/challenge_enums.dart';

/// Modèle de produit unifié qui combine les fonctionnalités des différents modèles
/// existants dans l'application (ProductModel, Product, etc.)
class UnifiedProduct {
  // Identifiants
  final String id;
  final String? barcode;
  
  // Informations générales
  final String name;
  final String brand;
  final String description;
  final List<String> categories;
  final String? imageUrl;
  
  // Informations commerciales
  final double price;
  final double? discountPercentage;
  final bool hasCoupon;
  final String? merchantUrl;
  final String? merchantName;
  
  // Informations écologiques
  final bool isEcoFriendly;
  final double ecoScore;
  final Map<String, dynamic> environmentalImpact;
  final List<String> ecoTags;
  final List<String> ecoLabels;
  
  // Informations produit
  final List<String> ingredients;
  final String? origin;
  final String? expiryDate;
  final double? weight;
  final String? weightUnit;
  
  // Relations avec d'autres entités
  final List<Map<String, dynamic>> alternatives;
  final List<Map<String, dynamic>> relatedArticles;
  final List<String> relatedChallenges;
  final ChallengeCategory? primaryCategory;
  
  // Horodatage et audits
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? scannedAt;

  const UnifiedProduct({
    required this.id,
    this.barcode,
    required this.name,
    required this.brand,
    required this.description,
    required this.categories,
    this.imageUrl,
    required this.price,
    this.discountPercentage,
    this.hasCoupon = false,
    this.merchantUrl,
    this.merchantName,
    this.isEcoFriendly = false,
    this.ecoScore = 0.0,
    this.environmentalImpact = const {},
    this.ecoTags = const [],
    this.ecoLabels = const [],
    this.ingredients = const [],
    this.origin,
    this.expiryDate,
    this.weight,
    this.weightUnit,
    this.alternatives = const [],
    this.relatedArticles = const [],
    this.relatedChallenges = const [],
    this.primaryCategory,
    this.createdAt,
    this.updatedAt,
    this.scannedAt,
  });

  /// Obtenir la couleur associée au score écologique
  Color get ecoScoreColor {
    if (ecoScore >= 80) return const Color(0xFF1E8E3E); // Vert
    if (ecoScore >= 60) return const Color(0xFF81C784); // Vert clair
    if (ecoScore >= 40) return const Color(0xFFFBC02D); // Jaune
    if (ecoScore >= 20) return const Color(0xFFFF8A65); // Orange
    return const Color(0xFFE53935); // Rouge
  }

  /// Obtenir le label associé au score écologique (A, B, C, D, E)
  String get ecoScoreLabel {
    if (ecoScore >= 80) return 'A';
    if (ecoScore >= 60) return 'B';
    if (ecoScore >= 40) return 'C';
    if (ecoScore >= 20) return 'D';
    return 'E';
  }

  /// Vérifier si un produit contient certains mots-clés
  bool containsKeywords(List<String> keywords) {
    final text = (name + ' ' + description).toLowerCase();
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }

  /// Créer une copie avec des modifications
  UnifiedProduct copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? description,
    List<String>? categories,
    String? imageUrl,
    double? price,
    double? discountPercentage,
    bool? hasCoupon,
    String? merchantUrl,
    String? merchantName,
    bool? isEcoFriendly,
    double? ecoScore,
    Map<String, dynamic>? environmentalImpact,
    List<String>? ecoTags,
    List<String>? ecoLabels,
    List<String>? ingredients,
    String? origin,
    String? expiryDate,
    double? weight,
    String? weightUnit,
    List<Map<String, dynamic>>? alternatives,
    List<Map<String, dynamic>>? relatedArticles,
    List<String>? relatedChallenges,
    ChallengeCategory? primaryCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? scannedAt,
  }) {
    return UnifiedProduct(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      hasCoupon: hasCoupon ?? this.hasCoupon,
      merchantUrl: merchantUrl ?? this.merchantUrl,
      merchantName: merchantName ?? this.merchantName,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      ecoScore: ecoScore ?? this.ecoScore,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      ecoTags: ecoTags ?? this.ecoTags,
      ecoLabels: ecoLabels ?? this.ecoLabels,
      ingredients: ingredients ?? this.ingredients,
      origin: origin ?? this.origin,
      expiryDate: expiryDate ?? this.expiryDate,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      alternatives: alternatives ?? this.alternatives,
      relatedArticles: relatedArticles ?? this.relatedArticles,
      relatedChallenges: relatedChallenges ?? this.relatedChallenges,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  /// Convertir depuis un ancien modèle de produit (ProductModel)
  factory UnifiedProduct.fromProductModel(dynamic productModel) {
    return UnifiedProduct(
      id: productModel.id,
      name: productModel.name,
      brand: productModel.brand,
      description: productModel.description,
      price: productModel.price,
      imageUrl: productModel.imageUrl,
      categories: productModel.categories is List<String> 
          ? productModel.categories 
          : [productModel.category ?? 'Non catégorisé'],
      isEcoFriendly: productModel.isEcoFriendly ?? false,
      discountPercentage: productModel.discountPercentage,
      hasCoupon: productModel.hasCoupon ?? false,
      merchantUrl: productModel.merchantUrl,
      ecoScore: productModel.ecoScore ?? 0.0,
      environmentalImpact: productModel.environmentalImpact ?? {},
      barcode: productModel.barcode,
      ingredients: productModel.ingredients is List<String> 
          ? productModel.ingredients 
          : [],
      alternatives: productModel.alternatives is List<Map<String, dynamic>> 
          ? productModel.alternatives 
          : [],
      scannedAt: productModel.scannedAt,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'description': description,
      'categories': categories,
      'imageUrl': imageUrl,
      'price': price,
      'discountPercentage': discountPercentage,
      'hasCoupon': hasCoupon,
      'merchantUrl': merchantUrl,
      'merchantName': merchantName,
      'isEcoFriendly': isEcoFriendly,
      'ecoScore': ecoScore,
      'environmentalImpact': environmentalImpact,
      'ecoTags': ecoTags,
      'ecoLabels': ecoLabels,
      'ingredients': ingredients,
      'origin': origin,
      'expiryDate': expiryDate,
      'weight': weight,
      'weightUnit': weightUnit,
      'alternatives': alternatives,
      'relatedArticles': relatedArticles,
      'relatedChallenges': relatedChallenges,
      'primaryCategory': primaryCategory?.toString(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'scannedAt': scannedAt?.toIso8601String(),
    };
  }

  /// Créer depuis un objet JSON
  factory UnifiedProduct.fromJson(Map<String, dynamic> json) {
    return UnifiedProduct(
      id: json['id'] ?? '',
      barcode: json['barcode'],
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      imageUrl: json['imageUrl'],
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: json['discountPercentage']?.toDouble(),
      hasCoupon: json['hasCoupon'] ?? false,
      merchantUrl: json['merchantUrl'],
      merchantName: json['merchantName'],
      isEcoFriendly: json['isEcoFriendly'] ?? false,
      ecoScore: (json['ecoScore'] ?? 0).toDouble(),
      environmentalImpact: json['environmentalImpact'] ?? {},
      ecoTags: json['ecoTags'] != null 
          ? List<String>.from(json['ecoTags']) 
          : [],
      ecoLabels: json['ecoLabels'] != null 
          ? List<String>.from(json['ecoLabels']) 
          : [],
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients']) 
          : [],
      origin: json['origin'],
      expiryDate: json['expiryDate'],
      weight: json['weight']?.toDouble(),
      weightUnit: json['weightUnit'],
      alternatives: json['alternatives'] != null 
          ? List<Map<String, dynamic>>.from(json['alternatives']) 
          : [],
      relatedArticles: json['relatedArticles'] != null 
          ? List<Map<String, dynamic>>.from(json['relatedArticles']) 
          : [],
      relatedChallenges: json['relatedChallenges'] != null 
          ? List<String>.from(json['relatedChallenges']) 
          : [],
      primaryCategory: json['primaryCategory'] != null 
          ? ChallengeCategory.values.firstWhere(
              (e) => e.toString() == json['primaryCategory'],
              orElse: () => ChallengeCategory.waste,
            )
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      scannedAt: json['scannedAt'] != null 
          ? DateTime.parse(json['scannedAt']) 
          : null,
    );
  }
} 