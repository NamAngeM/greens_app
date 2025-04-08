// File: lib/models/eco_badge.dart
import 'package:flutter/material.dart';

enum BadgeCategory {
  generalEcology,
  wasteReduction,
  waterSaving,
  energySaving,
  sustainableShopping,
  conservation,
  recycling,
  energy,
  transportation,
  community,
  special,
  other
}

enum BadgeLevel {
  bronze,
  silver,
  gold,
  platinum
}

class EcoBadge {
  final String id;
  final String? userId;
  final String title;
  final String description;
  final String imageUrl;
  final BadgeCategory category;
  final BadgeLevel level;
  final int pointsAwarded;
  final DateTime dateAwarded;
  final DateTime? earnedDate;
  final DateTime? createdAt;
  final bool isUnlocked;
  final Map<String, dynamic>? criteria;
  final String badgeColor;
  final bool isDisplayedOnProfile;

  EcoBadge({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.level,
    required this.pointsAwarded,
    required this.dateAwarded,
    this.earnedDate,
    this.createdAt,
    this.isUnlocked = false,
    this.criteria,
    this.badgeColor = '#4CAF50',
    this.isDisplayedOnProfile = false,
  });

  factory EcoBadge.fromJson(Map<String, dynamic> json) {
    return EcoBadge(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: BadgeCategory.values.firstWhere(
        (e) => e.toString() == 'BadgeCategory.${json['category']}',
      ),
      level: BadgeLevel.values.firstWhere(
        (e) => e.toString() == 'BadgeLevel.${json['level']}',
      ),
      pointsAwarded: json['pointsAwarded'] as int,
      dateAwarded: DateTime.parse(json['dateAwarded'] as String),
      earnedDate: json['earnedDate'] != null
          ? DateTime.parse(json['earnedDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      criteria: json['criteria'] as Map<String, dynamic>?,
      badgeColor: json['badgeColor'] as String? ?? '#4CAF50',
      isDisplayedOnProfile: json['isDisplayedOnProfile'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last,
      'level': level.toString().split('.').last,
      'pointsAwarded': pointsAwarded,
      'dateAwarded': dateAwarded.toIso8601String(),
      'earnedDate': earnedDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'criteria': criteria,
      'badgeColor': badgeColor,
      'isDisplayedOnProfile': isDisplayedOnProfile,
    };
  }

  Color get levelColor {
    switch (level) {
      case BadgeLevel.bronze:
        return Colors.brown.shade300;
      case BadgeLevel.silver:
        return Colors.grey.shade400;
      case BadgeLevel.gold:
        return Colors.amber.shade300;
      case BadgeLevel.platinum:
        return Colors.blueGrey.shade300;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case BadgeCategory.waterSaving:
        return Icons.water_drop;
      case BadgeCategory.energySaving:
        return Icons.bolt;
      case BadgeCategory.wasteReduction:
        return Icons.delete_outline;
      case BadgeCategory.sustainableShopping:
        return Icons.shopping_bag;
      case BadgeCategory.transportation:
        return Icons.directions_bike;
      case BadgeCategory.community:
        return Icons.people;
      case BadgeCategory.recycling:
        return Icons.recycling;
      case BadgeCategory.conservation:
        return Icons.nature;
      case BadgeCategory.energy:
        return Icons.lightbulb_outline;
      case BadgeCategory.special:
        return Icons.star;
      default:
        return Icons.eco;
    }
  }
}