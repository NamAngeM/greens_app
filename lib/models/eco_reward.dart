import 'package:cloud_firestore/cloud_firestore.dart';

class EcoReward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String type;
  final String? imageUrl;
  final bool isActive;
  final DateTime? expiryDate;
  final Map<String, dynamic>? metadata;

  EcoReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.type,
    this.imageUrl,
    this.isActive = true,
    this.expiryDate,
    this.metadata,
  });

  factory EcoReward.fromMap(Map<String, dynamic> map) {
    return EcoReward(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      pointsRequired: map['pointsRequired'] as int,
      type: map['type'] as String,
      imageUrl: map['imageUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      expiryDate: map['expiryDate'] != null ? (map['expiryDate'] as Timestamp).toDate() : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'type': type,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'expiryDate': expiryDate,
      'metadata': metadata,
    };
  }

  EcoReward copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsRequired,
    String? type,
    String? imageUrl,
    bool? isActive,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) {
    return EcoReward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      metadata: metadata ?? this.metadata,
    );
  }
} 