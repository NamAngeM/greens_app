import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeStatus {
  upcoming,
  active,
  completed
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
    );
  }
}