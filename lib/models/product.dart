// lib/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String brand;
  final String category;
  final double ecoRating;
  final List<String> certifications;
  final Map<String, double> ecoCriteria;
  final String imageUrl;
  final String? imageAsset;
  final Map<String, dynamic> nutritionalInfo;
  final Map<String, dynamic> environmentalImpact;
  final List<String> ingredients;
  final String packagingType;
  final bool isRecyclable;
  final bool isEcoFriendly;
  final String origin;
  final double carbonFootprint;
  final Map<String, dynamic> manufacturingInfo;
  final double price;
  final String? merchantUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    this.brand = '',
    required this.category,
    this.ecoRating = 0.0,
    this.certifications = const [],
    this.ecoCriteria = const {},
    this.imageUrl = '',
    this.imageAsset,
    this.nutritionalInfo = const {},
    this.environmentalImpact = const {},
    this.ingredients = const [],
    this.packagingType = '',
    this.isRecyclable = false,
    this.isEcoFriendly = false,
    this.origin = '',
    this.carbonFootprint = 0.0,
    this.manufacturingInfo = const {},
    this.price = 0.0,
    this.merchantUrl,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      ecoRating: (data['ecoRating'] ?? 0.0).toDouble(),
      certifications: List<String>.from(data['certifications'] ?? []),
      ecoCriteria: Map<String, double>.from(data['ecoCriteria'] ?? {}),
      imageUrl: data['imageUrl'] ?? '',
      imageAsset: data['imageAsset'],
      nutritionalInfo: data['nutritionalInfo'] ?? {},
      environmentalImpact: data['environmentalImpact'] ?? {},
      ingredients: List<String>.from(data['ingredients'] ?? []),
      packagingType: data['packagingType'] ?? '',
      isRecyclable: data['isRecyclable'] ?? false,
      isEcoFriendly: data['isEcoFriendly'] ?? false,
      origin: data['origin'] ?? '',
      carbonFootprint: (data['carbonFootprint'] ?? 0.0).toDouble(),
      manufacturingInfo: data['manufacturingInfo'] ?? {},
      price: (data['price'] ?? 0.0).toDouble(),
      merchantUrl: data['merchantUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'brand': brand,
      'category': category,
      'ecoRating': ecoRating,
      'certifications': certifications,
      'ecoCriteria': ecoCriteria,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
      'nutritionalInfo': nutritionalInfo,
      'environmentalImpact': environmentalImpact,
      'ingredients': ingredients,
      'packagingType': packagingType,
      'isRecyclable': isRecyclable,
      'isEcoFriendly': isEcoFriendly,
      'origin': origin,
      'carbonFootprint': carbonFootprint,
      'manufacturingInfo': manufacturingInfo,
      'price': price,
      'merchantUrl': merchantUrl,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? brand,
    String? category,
    double? ecoRating,
    List<String>? certifications,
    Map<String, double>? ecoCriteria,
    String? imageUrl,
    String? imageAsset,
    Map<String, dynamic>? nutritionalInfo,
    Map<String, dynamic>? environmentalImpact,
    List<String>? ingredients,
    String? packagingType,
    bool? isRecyclable,
    bool? isEcoFriendly,
    String? origin,
    double? carbonFootprint,
    Map<String, dynamic>? manufacturingInfo,
    double? price,
    String? merchantUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      ecoRating: ecoRating ?? this.ecoRating,
      certifications: certifications ?? this.certifications,
      ecoCriteria: ecoCriteria ?? this.ecoCriteria,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      ingredients: ingredients ?? this.ingredients,
      packagingType: packagingType ?? this.packagingType,
      isRecyclable: isRecyclable ?? this.isRecyclable,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      origin: origin ?? this.origin,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      manufacturingInfo: manufacturingInfo ?? this.manufacturingInfo,
      price: price ?? this.price,
      merchantUrl: merchantUrl ?? this.merchantUrl,
    );
  }
}