import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum EcoRating {
  excellent,
  good,
  average,
  poor,
  bad,
  unknown
}

class ProductScan {
  final String id;
  final String userId;
  final String barcode;
  final String productName;
  final String brand;
  final String imageUrl;
  final EcoRating ecoRating;
  final String ecoImpact;
  final List<String> ecoTips;
  final List<String> alternativeProductIds;
  final DateTime scanDate;
  final String ecoScore;
  final String category;
  final List<String> ingredients;
  final String origin;
  final int carbonFootprint;
  final int waterFootprint;
  final int deforestationImpact;
  final List<EcoAlternative> ecoAlternatives;

  ProductScan({
    required this.id,
    required this.userId,
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.imageUrl,
    required this.ecoRating,
    required this.ecoImpact,
    required this.ecoTips,
    required this.alternativeProductIds,
    required this.scanDate,
    this.ecoScore = 'C',
    this.category = 'Non catégorisé',
    this.ingredients = const [],
    this.origin = 'Inconnu',
    this.carbonFootprint = 3,
    this.waterFootprint = 3,
    this.deforestationImpact = 3,
    this.ecoAlternatives = const [],
  });

  factory ProductScan.fromJson(Map<String, dynamic> json) {
    return ProductScan(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      barcode: json['barcode'] ?? '',
      productName: json['productName'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ecoRating: EcoRating.values.firstWhere(
        (e) => e.toString() == 'EcoRating.${json['ecoRating']}',
        orElse: () => EcoRating.unknown,
      ),
      ecoImpact: json['ecoImpact'] ?? '',
      ecoTips: List<String>.from(json['ecoTips'] ?? []),
      alternativeProductIds: List<String>.from(json['alternativeProductIds'] ?? []),
      scanDate: (json['scanDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ecoScore: json['ecoScore'] ?? 'C',
      category: json['category'] ?? 'Non catégorisé',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      origin: json['origin'] ?? 'Inconnu',
      carbonFootprint: json['carbonFootprint'] ?? 3,
      waterFootprint: json['waterFootprint'] ?? 3,
      deforestationImpact: json['deforestationImpact'] ?? 3,
      ecoAlternatives: (json['ecoAlternatives'] as List<dynamic>?)
          ?.map((e) => EcoAlternative.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'imageUrl': imageUrl,
      'ecoRating': ecoRating.toString().split('.').last,
      'ecoImpact': ecoImpact,
      'ecoTips': ecoTips,
      'alternativeProductIds': alternativeProductIds,
      'scanDate': scanDate,
      'ecoScore': ecoScore,
      'category': category,
      'ingredients': ingredients,
      'origin': origin,
      'carbonFootprint': carbonFootprint,
      'waterFootprint': waterFootprint,
      'deforestationImpact': deforestationImpact,
      'ecoAlternatives': ecoAlternatives.map((e) => e.toJson()).toList(),
    };
  }

  Color getRatingColor() {
    switch (ecoRating) {
      case EcoRating.excellent:
        return Colors.green;
      case EcoRating.good:
        return Colors.lightGreen;
      case EcoRating.average:
        return Colors.yellow;
      case EcoRating.poor:
        return Colors.orange;
      case EcoRating.bad:
        return Colors.red;
      case EcoRating.unknown:
        return Colors.grey;
    }
  }

  String getRatingText() {
    switch (ecoRating) {
      case EcoRating.excellent:
        return 'Excellent';
      case EcoRating.good:
        return 'Bon';
      case EcoRating.average:
        return 'Moyen';
      case EcoRating.poor:
        return 'Médiocre';
      case EcoRating.bad:
        return 'Mauvais';
      case EcoRating.unknown:
        return 'Inconnu';
    }
  }
}

class EcoAlternative {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String ecoScore;

  EcoAlternative({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.ecoScore,
  });

  factory EcoAlternative.fromJson(Map<String, dynamic> json) {
    return EcoAlternative(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ecoScore: json['ecoScore'] ?? 'C',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'ecoScore': ecoScore,
    };
  }
}