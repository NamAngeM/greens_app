import 'package:cloud_firestore/cloud_firestore.dart';

class EcoChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  EcoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.imageUrl,
    this.metadata,
  });

  factory EcoChallenge.fromMap(Map<String, dynamic> map) {
    return EcoChallenge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      points: map['points'] as int,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      isActive: map['isActive'] as bool? ?? true,
      imageUrl: map['imageUrl'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  EcoChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return EcoChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
} 