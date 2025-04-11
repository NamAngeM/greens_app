import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeType {
  daily,
  weekly,
  monthly,
  seasonal,
  custom
}

enum ChallengeStatus {
  notStarted,
  inProgress,
  completed,
  failed
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int targetValue;
  final int currentValue;
  final int points;
  final List<String> participants;
  final Map<String, dynamic> requirements;
  final bool isPersonalized;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.currentValue,
    required this.points,
    required this.participants,
    required this.requirements,
    this.isPersonalized = false,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == 'ChallengeType.${data['type']}',
        orElse: () => ChallengeType.daily,
      ),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.toString() == 'ChallengeStatus.${data['status']}',
        orElse: () => ChallengeStatus.notStarted,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      targetValue: data['targetValue'] ?? 0,
      currentValue: data['currentValue'] ?? 0,
      points: data['points'] ?? 0,
      participants: List<String>.from(data['participants'] ?? []),
      requirements: data['requirements'] ?? {},
      isPersonalized: data['isPersonalized'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'points': points,
      'participants': participants,
      'requirements': requirements,
      'isPersonalized': isPersonalized,
    };
  }
} 