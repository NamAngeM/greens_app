import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeStatus {
  upcoming,
  active,
  completed
}

enum ChallengeCategory {
  water,
  energy,
  waste,
  transportation,
  food,
  biodiversity,
  community,
  other
}

class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final int targetParticipants;
  final ChallengeStatus status;
  final String imageUrl;
  final int carbonPointsReward;
  final List<String> participants;
  final DateTime createdAt;
  
  // Nouvelles propriétés
  final String creatorId;
  final String creatorName;
  final ChallengeCategory category;
  final String location;
  final bool isPublic;
  final int difficulty;
  final List<String> tags;
  final String rules;
  final bool isVerified;
  final List<String> sponsors;
  final Map<String, dynamic> progress;
  final List<ChallengeMilestone> milestones;

  CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.participantsCount = 0,
    required this.targetParticipants,
    required this.status,
    required this.imageUrl,
    required this.carbonPointsReward,
    required this.participants,
    required this.createdAt,
    this.creatorId = '',
    this.creatorName = '',
    this.category = ChallengeCategory.other,
    this.location = '',
    this.isPublic = true,
    this.difficulty = 2,
    this.tags = const [],
    this.rules = '',
    this.isVerified = false,
    this.sponsors = const [],
    this.progress = const {},
    this.milestones = const [],
  });

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    return CommunityChallenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      participantsCount: json['participantsCount'] ?? 0,
      targetParticipants: json['targetParticipants'] ?? 0,
      status: ChallengeStatus.values.firstWhere(
        (e) => e.toString() == 'ChallengeStatus.${json['status']}',
        orElse: () => ChallengeStatus.upcoming,
      ),
      imageUrl: json['imageUrl'] ?? '',
      carbonPointsReward: json['carbonPointsReward'] ?? 0,
      participants: List<String>.from(json['participants'] ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? '',
      category: ChallengeCategory.values.firstWhere(
        (e) => e.toString() == 'ChallengeCategory.${json['category']}',
        orElse: () => ChallengeCategory.other,
      ),
      location: json['location'] ?? '',
      isPublic: json['isPublic'] ?? true,
      difficulty: json['difficulty'] ?? 2,
      tags: List<String>.from(json['tags'] ?? []),
      rules: json['rules'] ?? '',
      isVerified: json['isVerified'] ?? false,
      sponsors: List<String>.from(json['sponsors'] ?? []),
      progress: json['progress'] ?? {},
      milestones: (json['milestones'] as List<dynamic>?)
          ?.map((e) => ChallengeMilestone.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'participantsCount': participantsCount,
      'targetParticipants': targetParticipants,
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl,
      'carbonPointsReward': carbonPointsReward,
      'participants': participants,
      'createdAt': createdAt,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'category': category.toString().split('.').last,
      'location': location,
      'isPublic': isPublic,
      'difficulty': difficulty,
      'tags': tags,
      'rules': rules,
      'isVerified': isVerified,
      'sponsors': sponsors,
      'progress': progress,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    };
  }

  CommunityChallenge copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? participantsCount,
    int? targetParticipants,
    ChallengeStatus? status,
    String? imageUrl,
    int? carbonPointsReward,
    List<String>? participants,
    DateTime? createdAt,
    String? creatorId,
    String? creatorName,
    ChallengeCategory? category,
    String? location,
    bool? isPublic,
    int? difficulty,
    List<String>? tags,
    String? rules,
    bool? isVerified,
    List<String>? sponsors,
    Map<String, dynamic>? progress,
    List<ChallengeMilestone>? milestones,
  }) {
    return CommunityChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantsCount: participantsCount ?? this.participantsCount,
      targetParticipants: targetParticipants ?? this.targetParticipants,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      carbonPointsReward: carbonPointsReward ?? this.carbonPointsReward,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      category: category ?? this.category,
      location: location ?? this.location,
      isPublic: isPublic ?? this.isPublic,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      rules: rules ?? this.rules,
      isVerified: isVerified ?? this.isVerified,
      sponsors: sponsors ?? this.sponsors,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
    );
  }
  
  String getStatusText() {
    switch (status) {
      case ChallengeStatus.upcoming:
        return 'À venir';
      case ChallengeStatus.active:
        return 'En cours';
      case ChallengeStatus.completed:
        return 'Terminé';
    }
  }
  
  String getCategoryText() {
    switch (category) {
      case ChallengeCategory.water:
        return 'Eau';
      case ChallengeCategory.energy:
        return 'Énergie';
      case ChallengeCategory.waste:
        return 'Déchets';
      case ChallengeCategory.transportation:
        return 'Transport';
      case ChallengeCategory.food:
        return 'Alimentation';
      case ChallengeCategory.biodiversity:
        return 'Biodiversité';
      case ChallengeCategory.community:
        return 'Communauté';
      case ChallengeCategory.other:
        return 'Autre';
    }
  }
  
  String getDifficultyText() {
    switch (difficulty) {
      case 1:
        return 'Facile';
      case 2:
        return 'Moyen';
      case 3:
        return 'Difficile';
      default:
        return 'Moyen';
    }
  }
}

class ChallengeMilestone {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isCompleted;
  
  ChallengeMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.isCompleted = false,
  });
  
  factory ChallengeMilestone.fromJson(Map<String, dynamic> json) {
    return ChallengeMilestone(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'isCompleted': isCompleted,
    };
  }
  
  ChallengeMilestone copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    bool? isCompleted,
  }) {
    return ChallengeMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}