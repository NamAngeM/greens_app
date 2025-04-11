import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int points;
  final String category;
  final List<String> requirements;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.points,
    required this.category,
    required this.requirements,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Badge.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Badge(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      points: data['points'] ?? 0,
      category: data['category'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'points': points,
      'category': category,
      'requirements': requirements,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt,
    };
  }
} 