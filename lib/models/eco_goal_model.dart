import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalType {
  wasteReduction,
  waterSaving,
  energySaving,
  sustainableShopping,
  transportation,
  custom
}

enum GoalFrequency {
  daily,
  weekly,
  monthly
}

class EcoGoal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalType type;
  final GoalFrequency frequency;
  final int target;
  final int currentProgress;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  EcoGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.target,
    this.currentProgress = 0,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage => target > 0 ? (currentProgress / target) * 100 : 0;

  factory EcoGoal.fromJson(Map<String, dynamic> json) {
    return EcoGoal(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.toString() == 'GoalType.${json['type']}',
        orElse: () => GoalType.custom,
      ),
      frequency: GoalFrequency.values.firstWhere(
        (e) => e.toString() == 'GoalFrequency.${json['frequency']}',
        orElse: () => GoalFrequency.weekly,
      ),
      target: json['target'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'target': target,
      'currentProgress': currentProgress,
      'startDate': startDate,
      'endDate': endDate,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  EcoGoal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    GoalType? type,
    GoalFrequency? frequency,
    int? target,
    int? currentProgress,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EcoGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}