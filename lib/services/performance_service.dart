import 'package:flutter/foundation.dart';
import 'monitoring_service.dart';

class PerformanceService {
  final MonitoringService _monitoringService;

  PerformanceService(this._monitoringService);

  void logPerformanceMetric(String metricName, double value) {
    _monitoringService.logEvent('performance_metric', parameters: {
      'metric': metricName,
      'value': value
    });
  }
}

void logPerformanceMetric(String name, double value) {
  _monitoring.logMetric(name, value);
}

void trackApiCall(String endpoint, Duration duration) {
  _monitoring.logMetric(
    'api_call_duration',
    duration.inMilliseconds.toDouble(),
    tags: {'endpoint': endpoint},
  );
}

void trackCacheHit(String key, bool hit) {
  _monitoring.logMetric(
    'cache_hit',
    hit ? 1.0 : 0.0,
    tags: {'key': key},
  );
}

Map<String, dynamic> getPerformanceMetrics() {
  return _monitoring.getMetrics();
}

void trackMemoryUsage() {
  // Platform-specific implementation
  // This will be implemented based on the platform requirements
  _monitoring.logMetric(
    'memory_usage',
    0.0, // Placeholder value
    tags: {'platform': 'flutter'},
  );
}