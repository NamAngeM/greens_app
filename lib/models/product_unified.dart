import 'package:flutter/foundation.dart';

class UnifiedProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> categories;
  final bool isEcoFriendly;
  final String? brand;
  final double ecoRating;
  final List<String> certifications;
  final Map<String, dynamic> ecoCriteria;
  final String? merchantUrl;
  
  // Champs optionnels pour des informations détaillées
  final Map<String, dynamic>? nutritionalInfo;
  final Map<String, dynamic>? environmentalImpact;
  final List<String>? ingredients;
  final String? packagingType;
  final bool? isRecyclable;
  final String? origin;
  final double? carbonFootprint;
  final Map<String, dynamic>? manufacturingInfo;

  const UnifiedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categories,
    this.imageUrl,
    this.isEcoFriendly = false,
    this.brand,
    this.ecoRating = 0.0,
    this.certifications = const [],
    this.ecoCriteria = const {},
    this.merchantUrl,
    this.nutritionalInfo,
    this.environmentalImpact,
    this.ingredients,
    this.packagingType,
    this.isRecyclable,
    this.origin,
    this.carbonFootprint,
    this.manufacturingInfo,
  });

  // Création d'un produit à partir d'un Map (pour Firebase)
  factory UnifiedProduct.fromMap(Map<String, dynamic> map, String docId) {
    return UnifiedProduct(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'],
      categories: List<String>.from(map['categories'] ?? []),
      isEcoFriendly: map['isEcoFriendly'] ?? false,
      brand: map['brand'],
      ecoRating: map['ecoRating']?.toDouble() ?? 0.0,
      certifications: List<String>.from(map['certifications'] ?? []),
      ecoCriteria: Map<String, dynamic>.from(map['ecoCriteria'] ?? {}),
      merchantUrl: map['merchantUrl'],
      nutritionalInfo: map['nutritionalInfo'],
      environmentalImpact: map['environmentalImpact'],
      ingredients: map['ingredients'] != null ? List<String>.from(map['ingredients']) : null,
      packagingType: map['packagingType'],
      isRecyclable: map['isRecyclable'],
      origin: map['origin'],
      carbonFootprint: map['carbonFootprint']?.toDouble(),
      manufacturingInfo: map['manufacturingInfo'],
    );
  }

  // Conversion en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categories': categories,
      'isEcoFriendly': isEcoFriendly,
      'brand': brand,
      'ecoRating': ecoRating,
      'certifications': certifications,
      'ecoCriteria': ecoCriteria,
      'merchantUrl': merchantUrl,
      'nutritionalInfo': nutritionalInfo,
      'environmentalImpact': environmentalImpact,
      'ingredients': ingredients,
      'packagingType': packagingType,
      'isRecyclable': isRecyclable,
      'origin': origin,
      'carbonFootprint': carbonFootprint,
      'manufacturingInfo': manufacturingInfo,
    };
  }

  // Créer une copie modifiée du produit
  UnifiedProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? categories,
    bool? isEcoFriendly,
    String? brand,
    double? ecoRating,
    List<String>? certifications,
    Map<String, dynamic>? ecoCriteria,
    String? merchantUrl,
    Map<String, dynamic>? nutritionalInfo,
    Map<String, dynamic>? environmentalImpact,
    List<String>? ingredients,
    String? packagingType,
    bool? isRecyclable,
    String? origin,
    double? carbonFootprint,
    Map<String, dynamic>? manufacturingInfo,
  }) {
    return UnifiedProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      brand: brand ?? this.brand,
      ecoRating: ecoRating ?? this.ecoRating,
      certifications: certifications ?? this.certifications,
      ecoCriteria: ecoCriteria ?? this.ecoCriteria,
      merchantUrl: merchantUrl ?? this.merchantUrl,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      ingredients: ingredients ?? this.ingredients,
      packagingType: packagingType ?? this.packagingType,
      isRecyclable: isRecyclable ?? this.isRecyclable,
      origin: origin ?? this.origin,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      manufacturingInfo: manufacturingInfo ?? this.manufacturingInfo,
    );
  }

  // Getter pour récupérer la catégorie principale
  String get mainCategory => categories.isNotEmpty ? categories[0] : 'Non classé';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 