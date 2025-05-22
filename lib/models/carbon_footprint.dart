import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonFootprint {
  final String id;
  final String userId;
  final double transportEmissions; // in kg CO2
  final double foodEmissions; // in kg CO2
  final double energyEmissions; // in kg CO2
  final double wasteEmissions; // in kg CO2
  final DateTime date;
  final Map<String, dynamic> details; // Additional details for each category

  CarbonFootprint({
    required this.id,
    required this.userId,
    required this.transportEmissions,
    required this.foodEmissions,
    required this.energyEmissions,
    required this.wasteEmissions,
    required this.date,
    required this.details,
  });

  double get totalEmissions => 
    transportEmissions + foodEmissions + energyEmissions + wasteEmissions;

  factory CarbonFootprint.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CarbonFootprint(
      id: doc.id,
      userId: data['userId'] ?? '',
      transportEmissions: (data['transportEmissions'] ?? 0.0).toDouble(),
      foodEmissions: (data['foodEmissions'] ?? 0.0).toDouble(),
      energyEmissions: (data['energyEmissions'] ?? 0.0).toDouble(),
      wasteEmissions: (data['wasteEmissions'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      details: data['details'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'transportEmissions': transportEmissions,
      'foodEmissions': foodEmissions,
      'energyEmissions': energyEmissions,
      'wasteEmissions': wasteEmissions,
      'date': Timestamp.fromDate(date),
      'details': details,
    };
  }

  CarbonFootprint copyWith({
    String? id,
    String? userId,
    double? transportEmissions,
    double? foodEmissions,
    double? energyEmissions,
    double? wasteEmissions,
    DateTime? date,
    Map<String, dynamic>? details,
  }) {
    return CarbonFootprint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      transportEmissions: transportEmissions ?? this.transportEmissions,
      foodEmissions: foodEmissions ?? this.foodEmissions,
      energyEmissions: energyEmissions ?? this.energyEmissions,
      wasteEmissions: wasteEmissions ?? this.wasteEmissions,
      date: date ?? this.date,
      details: details ?? this.details,
    );
  }
} 