import 'package:test/test.dart';
import 'package:greens_app/services/monitoring_service.dart';

void main() {
  group('MonitoringService Tests', () {
    late MonitoringService monitoringService;

    setUp(() {
      monitoringService = MonitoringService();
    });

    test('Doit enregistrer une nouvelle métrique', () {
      monitoringService.logMetric('test_metric', 100.0);
      final metrics = monitoringService.getMetrics();
      expect(metrics['metrics'], isNotEmpty);
      expect(metrics['metrics'][0]['name'], equals('test_metric'));
      expect(metrics['metrics'][0]['value'], equals(100.0));
    });

    test('Doit calculer correctement le résumé des métriques', () {
      monitoringService.logMetric('response_time', 100.0);
      monitoringService.logMetric('response_time', 200.0);
      final summary = monitoringService.getMetrics()['summary'];
      expect(summary['totalRequests'], equals(2));
      expect(summary['averageResponseTime'], equals(150.0));
    });
  });
}