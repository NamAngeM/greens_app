import 'package:cloud_firestore/cloud_firestore.dart';

class ProductScan {
  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final double environmentalScore; // 0-100
  final Map<String, dynamic> impactDetails; // Detailed impact information
  final List<String> recyclingInstructions;
  final List<String> ecoAlternatives;
  final DateTime scanDate;
  final String userId;

  ProductScan({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.environmentalScore,
    required this.impactDetails,
    required this.recyclingInstructions,
    required this.ecoAlternatives,
    required this.scanDate,
    required this.userId,
  });

  factory ProductScan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductScan(
      id: doc.id,
      barcode: data['barcode'] ?? '',
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      environmentalScore: (data['environmentalScore'] ?? 0.0).toDouble(),
      impactDetails: data['impactDetails'] ?? {},
      recyclingInstructions: List<String>.from(data['recyclingInstructions'] ?? []),
      ecoAlternatives: List<String>.from(data['ecoAlternatives'] ?? []),
      scanDate: (data['scanDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'environmentalScore': environmentalScore,
      'impactDetails': impactDetails,
      'recyclingInstructions': recyclingInstructions,
      'ecoAlternatives': ecoAlternatives,
      'scanDate': Timestamp.fromDate(scanDate),
      'userId': userId,
    };
  }

  ProductScan copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    double? environmentalScore,
    Map<String, dynamic>? impactDetails,
    List<String>? recyclingInstructions,
    List<String>? ecoAlternatives,
    DateTime? scanDate,
    String? userId,
  }) {
    return ProductScan(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      environmentalScore: environmentalScore ?? this.environmentalScore,
      impactDetails: impactDetails ?? this.impactDetails,
      recyclingInstructions: recyclingInstructions ?? this.recyclingInstructions,
      ecoAlternatives: ecoAlternatives ?? this.ecoAlternatives,
      scanDate: scanDate ?? this.scanDate,
      userId: userId ?? this.userId,
    );
  }
} 