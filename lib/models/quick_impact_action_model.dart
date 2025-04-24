import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enumération des catégories d'actions
enum ActionCategory {
  energy,
  water,
  waste,
  transportation,
  consumption,
  food,
  technology,
  community
}

// Extension pour les attributs de catégorie
extension ActionCategoryExtension on ActionCategory {
  String get name {
    switch (this) {
      case ActionCategory.energy:
        return 'energy';
      case ActionCategory.water:
        return 'water';
      case ActionCategory.waste:
        return 'waste';
      case ActionCategory.transportation:
        return 'transportation';
      case ActionCategory.consumption:
        return 'consumption';
      case ActionCategory.food:
        return 'food';
      case ActionCategory.technology:
        return 'technology';
      case ActionCategory.community:
        return 'community';
    }
  }

  String get displayName {
    switch (this) {
      case ActionCategory.energy:
        return 'Énergie';
      case ActionCategory.water:
        return 'Eau';
      case ActionCategory.waste:
        return 'Déchets';
      case ActionCategory.transportation:
        return 'Transport';
      case ActionCategory.consumption:
        return 'Consommation';
      case ActionCategory.food:
        return 'Alimentation';
      case ActionCategory.technology:
        return 'Technologie';
      case ActionCategory.community:
        return 'Communauté';
    }
  }

  IconData get icon {
    switch (this) {
      case ActionCategory.energy:
        return Icons.lightbulb_outline;
      case ActionCategory.water:
        return Icons.water_drop_outlined;
      case ActionCategory.waste:
        return Icons.delete_outline;
      case ActionCategory.transportation:
        return Icons.directions_bus_outlined;
      case ActionCategory.consumption:
        return Icons.shopping_bag_outlined;
      case ActionCategory.food:
        return Icons.restaurant_outlined;
      case ActionCategory.technology:
        return Icons.devices_outlined;
      case ActionCategory.community:
        return Icons.people_outline;
    }
  }

  Color get color {
    switch (this) {
      case ActionCategory.energy:
        return Colors.amber;
      case ActionCategory.water:
        return Colors.blue;
      case ActionCategory.waste:
        return Colors.green;
      case ActionCategory.transportation:
        return Colors.purple;
      case ActionCategory.consumption:
        return Colors.orange;
      case ActionCategory.food:
        return Colors.red;
      case ActionCategory.technology:
        return Colors.teal;
      case ActionCategory.community:
        return Colors.indigo;
    }
  }

  static ActionCategory fromString(String value) {
    return ActionCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionCategory.consumption,
    );
  }
}

// Enumération des niveaux de difficulté
enum ActionDifficulty {
  easy,
  medium,
  hard
}

// Extension pour les attributs de difficulté
extension ActionDifficultyExtension on ActionDifficulty {
  String get name {
    switch (this) {
      case ActionDifficulty.easy:
        return 'easy';
      case ActionDifficulty.medium:
        return 'medium';
      case ActionDifficulty.hard:
        return 'hard';
    }
  }

  String get displayName {
    switch (this) {
      case ActionDifficulty.easy:
        return 'Facile';
      case ActionDifficulty.medium:
        return 'Modéré';
      case ActionDifficulty.hard:
        return 'Difficile';
    }
  }

  IconData get icon {
    switch (this) {
      case ActionDifficulty.easy:
        return Icons.sentiment_satisfied_outlined;
      case ActionDifficulty.medium:
        return Icons.sentiment_neutral_outlined;
      case ActionDifficulty.hard:
        return Icons.sentiment_very_dissatisfied_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ActionDifficulty.easy:
        return Colors.green;
      case ActionDifficulty.medium:
        return Colors.orange;
      case ActionDifficulty.hard:
        return Colors.red;
    }
  }

  static ActionDifficulty fromString(String value) {
    return ActionDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionDifficulty.medium,
    );
  }
}

// Modèle pour représenter une étape d'action
class ActionStep {
  final String title;
  final String description;
  final String? imageUrl;

  ActionStep({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory ActionStep.fromJson(Map<String, dynamic> json) {
    return ActionStep(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

// Modèle principal pour les actions à impact rapide
class QuickImpactActionModel {
  final String id;
  final String title;
  final String description;
  final String fullDescription;
  final List<ActionStep> steps;
  final ActionCategory category;
  final ActionDifficulty difficulty;
  final double estimatedCarbonSaving;
  final int estimatedTimeInMinutes;
  final int rewardPoints;
  final bool isRecurring;
  final int frequencyLimitInDays;
  final String imageUrl;
  final List<String> tags;
  final String? externalLink;

  QuickImpactActionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fullDescription,
    required this.steps,
    required this.category,
    required this.difficulty,
    required this.estimatedCarbonSaving,
    required this.estimatedTimeInMinutes,
    required this.rewardPoints,
    required this.isRecurring,
    required this.frequencyLimitInDays,
    required this.imageUrl,
    required this.tags,
    this.externalLink,
  });

  factory QuickImpactActionModel.fromJson(Map<String, dynamic> json) {
    List<ActionStep> stepsList = [];
    if (json['steps'] != null) {
      stepsList = (json['steps'] as List)
          .map((step) => ActionStep.fromJson(step))
          .toList();
    }

    List<String> tagsList = [];
    if (json['tags'] != null) {
      tagsList = List<String>.from(json['tags']);
    }

    return QuickImpactActionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fullDescription: json['fullDescription'] ?? '',
      steps: stepsList,
      category: ActionCategoryExtension.fromString(json['category'] ?? ''),
      difficulty: ActionDifficultyExtension.fromString(json['difficulty'] ?? ''),
      estimatedCarbonSaving: (json['estimatedCarbonSaving'] ?? 0.0).toDouble(),
      estimatedTimeInMinutes: json['estimatedTimeInMinutes'] ?? 0,
      rewardPoints: json['rewardPoints'] ?? 0,
      isRecurring: json['isRecurring'] ?? false,
      frequencyLimitInDays: json['frequencyLimitInDays'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      tags: tagsList,
      externalLink: json['externalLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fullDescription': fullDescription,
      'steps': steps.map((step) => step.toJson()).toList(),
      'category': category.name,
      'difficulty': difficulty.name,
      'estimatedCarbonSaving': estimatedCarbonSaving,
      'estimatedTimeInMinutes': estimatedTimeInMinutes,
      'rewardPoints': rewardPoints,
      'isRecurring': isRecurring,
      'frequencyLimitInDays': frequencyLimitInDays,
      'imageUrl': imageUrl,
      'tags': tags,
      'externalLink': externalLink,
    };
  }
}

// Modèle pour les actions complétées
class CompletedActionModel {
  final String id;
  final String actionId;
  final String userId;
  final DateTime completedDate;
  final String? userNote;
  final int earnedPoints;
  final double carbonSaved;

  CompletedActionModel({
    required this.id,
    required this.actionId,
    required this.userId,
    required this.completedDate,
    this.userNote,
    required this.earnedPoints,
    required this.carbonSaved,
  });

  factory CompletedActionModel.fromJson(Map<String, dynamic> json) {
    return CompletedActionModel(
      id: json['id'] ?? '',
      actionId: json['actionId'] ?? '',
      userId: json['userId'] ?? '',
      completedDate: json['completedDate'] != null
          ? (json['completedDate'] is DateTime
              ? json['completedDate']
              : (json['completedDate'].toDate()))
          : DateTime.now(),
      userNote: json['userNote'],
      earnedPoints: json['earnedPoints'] ?? 0,
      carbonSaved: (json['carbonSaved'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionId': actionId,
      'userId': userId,
      'completedDate': completedDate,
      'userNote': userNote,
      'earnedPoints': earnedPoints,
      'carbonSaved': carbonSaved,
    };
  }
} 