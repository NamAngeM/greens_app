import 'package:flutter/foundation.dart';

class MonitoringService {
  MonitoringService();
  
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    debugPrint('Event logged: $eventName with parameters: $parameters');
  }
}

class PerformanceMetric {
  final String name;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? tags;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'tags': tags,
  };
}