import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupChallengeStatus {
  active,
  completed,
  cancelled
}

class GroupChallengeContribution {
  final String userId;
  final int value;
  final DateTime timestamp;

  GroupChallengeContribution({
    required this.userId,
    required this.value,
    required this.timestamp,
  });

  factory GroupChallengeContribution.fromJson(Map<String, dynamic> json) {
    return GroupChallengeContribution(
      userId: json['userId'] as String,
      value: json['value'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'value': value,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class GroupChallenge {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final String creatorId;
  final List<String> participants;
  final int participantsCount;
  final DateTime createdAt;
  final DateTime endDate;
  final GroupChallengeStatus status;
  final List<String> completedParticipants;
  final Map<String, int> individualContributions;
  final DateTime? completedAt;

  GroupChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.creatorId,
    required this.participants,
    required this.participantsCount,
    required this.createdAt,
    required this.endDate,
    required this.status,
    required this.completedParticipants,
    required this.individualContributions,
    this.completedAt,
  });

  factory GroupChallenge.fromJson(Map<String, dynamic> json) {
    // Convertir le status en enum
    GroupChallengeStatus statusEnum;
    switch (json['status'] as String) {
      case 'active':
        statusEnum = GroupChallengeStatus.active;
        break;
      case 'completed':
        statusEnum = GroupChallengeStatus.completed;
        break;
      case 'cancelled':
        statusEnum = GroupChallengeStatus.cancelled;
        break;
      default:
        statusEnum = GroupChallengeStatus.active;
    }

    // Convertir les timestamps
    final createdAt = json['createdAt'] is Timestamp 
        ? (json['createdAt'] as Timestamp).toDate() 
        : DateTime.now();
    
    final endDate = json['endDate'] is Timestamp 
        ? (json['endDate'] as Timestamp).toDate() 
        : DateTime.now().add(const Duration(days: 7));
    
    final completedAt = json['completedAt'] is Timestamp 
        ? (json['completedAt'] as Timestamp).toDate() 
        : null;

    // Convertir la liste des participants
    final List<String> participants = [];
    if (json['participants'] != null) {
      for (var participant in json['participants']) {
        participants.add(participant as String);
      }
    }

    // Convertir la liste des participants ayant complété
    final List<String> completedParticipants = [];
    if (json['completedParticipants'] != null) {
      for (var participant in json['completedParticipants']) {
        completedParticipants.add(participant as String);
      }
    }

    // Convertir les contributions individuelles
    final Map<String, int> individualContributions = {};
    if (json['individualContributions'] != null) {
      final Map<String, dynamic> contributeData = json['individualContributions'] as Map<String, dynamic>;
      contributeData.forEach((key, value) {
        individualContributions[key] = value as int;
      });
    }

    return GroupChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int,
      creatorId: json['creatorId'] as String,
      participants: participants,
      participantsCount: json['participantsCount'] as int,
      createdAt: createdAt,
      endDate: endDate,
      status: statusEnum,
      completedParticipants: completedParticipants,
      individualContributions: individualContributions,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir l'enum en string
    String statusString;
    switch (status) {
      case GroupChallengeStatus.active:
        statusString = 'active';
        break;
      case GroupChallengeStatus.completed:
        statusString = 'completed';
        break;
      case GroupChallengeStatus.cancelled:
        statusString = 'cancelled';
        break;
    }

    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'creatorId': creatorId,
      'participants': participants,
      'participantsCount': participantsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'endDate': Timestamp.fromDate(endDate),
      'status': statusString,
      'completedParticipants': completedParticipants,
      'individualContributions': individualContributions,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Calculer le pourcentage de progression du défi
  double getProgressPercentage() {
    if (targetValue == 0) return 0.0;
    final percentage = (currentValue / targetValue) * 100;
    return percentage > 100 ? 100.0 : percentage;
  }

  /// Vérifier si un utilisateur a rejoint le défi
  bool isUserParticipant(String userId) {
    return participants.contains(userId);
  }

  /// Vérifier si le défi est terminé
  bool isCompleted() {
    return status == GroupChallengeStatus.completed || currentValue >= targetValue;
  }

  /// Vérifier si le défi est expiré
  bool isExpired() {
    return DateTime.now().isAfter(endDate) && status != GroupChallengeStatus.completed;
  }

  /// Obtenir la contribution d'un utilisateur
  int getUserContribution(String userId) {
    return individualContributions[userId] ?? 0;
  }

  /// Créer une copie du défi avec de nouvelles valeurs
  GroupChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    String? creatorId,
    List<String>? participants,
    int? participantsCount,
    DateTime? createdAt,
    DateTime? endDate,
    GroupChallengeStatus? status,
    List<String>? completedParticipants,
    Map<String, int>? individualContributions,
    DateTime? completedAt,
  }) {
    return GroupChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      creatorId: creatorId ?? this.creatorId,
      participants: participants ?? this.participants,
      participantsCount: participantsCount ?? this.participantsCount,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      completedParticipants: completedParticipants ?? this.completedParticipants,
      individualContributions: individualContributions ?? this.individualContributions,
      completedAt: completedAt ?? this.completedAt,
    );
  }
} 