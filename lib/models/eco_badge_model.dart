import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeLevel {
  bronze,
  silver,
  gold,
  platinum
}

enum BadgeCategory {
  wasteReduction,
  waterSaving,
  energySaving,
  sustainableShopping,
  transportation,
  communityParticipation,
  generalEcology
}

class EcoBadgeModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final BadgeCategory category;
  final BadgeLevel level;
  final String imageUrl;
  final int pointsAwarded;
  final DateTime earnedDate;
  final Map<String, dynamic>? criteria; // Requirements to earn this badge
  final bool isDisplayedOnProfile;
  final DateTime createdAt;

  EcoBadgeModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.imageUrl,
    required this.pointsAwarded,
    required this.earnedDate,
    this.criteria,
    this.isDisplayedOnProfile = true,
    required this.createdAt,
  });

  factory EcoBadgeModel.fromJson(Map<String, dynamic> json) {
    return EcoBadgeModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: BadgeCategory.values.firstWhere(
        (e) => e.toString() == 'BadgeCategory.${json['category']}',
        orElse: () => BadgeCategory.generalEcology,
      ),
      level: BadgeLevel.values.firstWhere(
        (e) => e.toString() == 'BadgeLevel.${json['level']}',
        orElse: () => BadgeLevel.bronze,
      ),
      imageUrl: json['imageUrl'] ?? '',
      pointsAwarded: json['pointsAwarded'] ?? 0,
      earnedDate: (json['earnedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      criteria: json['criteria'],
      isDisplayedOnProfile: json['isDisplayedOnProfile'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'level': level.toString().split('.').last,
      'imageUrl': imageUrl,
      'pointsAwarded': pointsAwarded,
      'earnedDate': earnedDate,
      'criteria': criteria,
      'isDisplayedOnProfile': isDisplayedOnProfile,
      'createdAt': createdAt,
    };
  }

  // Helper method to get badge color based on level
  String get badgeColor {
    switch (level) {
      case BadgeLevel.bronze:
        return '#CD7F32';
      case BadgeLevel.silver:
        return '#C0C0C0';
      case BadgeLevel.gold:
        return '#FFD700';
      case BadgeLevel.platinum:
        return '#E5E4E2';
      default:
        return '#CD7F32';
    }
  }

  // Helper method to get category icon
  String get categoryIcon {
    switch (category) {
      case BadgeCategory.wasteReduction:
        return 'assets/icons/waste_reduction.png';
      case BadgeCategory.waterSaving:
        return 'assets/icons/water_saving.png';
      case BadgeCategory.energySaving:
        return 'assets/icons/energy_saving.png';
      case BadgeCategory.sustainableShopping:
        return 'assets/icons/sustainable_shopping.png';
      case BadgeCategory.transportation:
        return 'assets/icons/transportation.png';
      case BadgeCategory.communityParticipation:
        return 'assets/icons/community.png';
      case BadgeCategory.generalEcology:
        return 'assets/icons/ecology.png';
      default:
        return 'assets/icons/ecology.png';
    }
  }
}