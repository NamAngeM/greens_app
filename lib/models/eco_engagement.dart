import 'package:cloud_firestore/cloud_firestore.dart';

class EcoEngagement {
  final String id;
  final String userId;
  final String challengeId;
  final String status;
  final int? points;
  final DateTime startDate;
  final DateTime? completionDate;
  final Map<String, dynamic>? progress;
  final Map<String, dynamic>? metadata;

  EcoEngagement({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.status,
    this.points,
    required this.startDate,
    this.completionDate,
    this.progress,
    this.metadata,
  });

  factory EcoEngagement.fromMap(Map<String, dynamic> map) {
    return EcoEngagement(
      id: map['id'] as String,
      userId: map['userId'] as String,
      challengeId: map['challengeId'] as String,
      status: map['status'] as String,
      points: map['points'] as int?,
      startDate: (map['startDate'] as Timestamp).toDate(),
      completionDate: map['completionDate'] != null ? (map['completionDate'] as Timestamp).toDate() : null,
      progress: map['progress'] as Map<String, dynamic>?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'challengeId': challengeId,
      'status': status,
      'points': points,
      'startDate': startDate,
      'completionDate': completionDate,
      'progress': progress,
      'metadata': metadata,
    };
  }

  EcoEngagement copyWith({
    String? id,
    String? userId,
    String? challengeId,
    String? status,
    int? points,
    DateTime? startDate,
    DateTime? completionDate,
    Map<String, dynamic>? progress,
    Map<String, dynamic>? metadata,
  }) {
    return EcoEngagement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      status: status ?? this.status,
      points: points ?? this.points,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
    );
  }
} 