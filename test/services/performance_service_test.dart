import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:greens_app/services/performance_service.dart';
import 'package:greens_app/services/monitoring_service.dart';

class MockMonitoringService extends Mock implements MonitoringService {}

void main() {
  group('PerformanceService Tests', () {
    late PerformanceService performanceService;
    late MockMonitoringService mockMonitoringService;

    setUp(() {
      mockMonitoringService = MockMonitoringService();
      performanceService = PerformanceService(mockMonitoringService);
    });

    test('Doit tracker un appel API', () {
      final duration = Duration(milliseconds: 100);
      performanceService.trackApiCall('/test', duration);
      
      verify(mockMonitoringService.logMetric(
        'api_call_duration',
        100.0,
        tags: {'endpoint': '/test'},
      )).called(1);
    });

    test('Doit tracker les hits du cache', () {
      performanceService.trackCacheHit('test_key', true);
      
      verify(mockMonitoringService.logMetric(
        'cache_hit_rate',
        1.0,
        tags: {'key': 'test_key'},
      )).called(1);
    });
  });
}