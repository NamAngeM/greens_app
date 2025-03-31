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
  final DateTime scannedAt;

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
    required this.scannedAt,
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
      scannedAt: (json['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'scannedAt': scannedAt,
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