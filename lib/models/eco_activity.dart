import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  transport,
  food,
  energy,
  waste,
  shopping
}

class EcoActivity {
  final String id;
  final String userId;
  final ActivityType type;
  final String description;
  final double carbonImpact;
  final DateTime date;
  final Map<String, dynamic> details;
  final bool isVerified;

  EcoActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.carbonImpact,
    required this.date,
    required this.details,
    this.isVerified = false,
  });

  factory EcoActivity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return EcoActivity(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${data['type']}',
        orElse: () => ActivityType.transport,
      ),
      description: data['description'] ?? '',
      carbonImpact: (data['carbonImpact'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      details: data['details'] ?? {},
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'description': description,
      'carbonImpact': carbonImpact,
      'date': Timestamp.fromDate(date),
      'details': details,
      'isVerified': isVerified,
    };
  }
} 