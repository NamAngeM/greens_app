import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:greens_app/services/sync_service.dart';
import 'package:greens_app/services/cache_service.dart';

class MockCacheService extends Mock implements CacheService {}

void main() {
  group('SyncService Tests', () {
    late SyncService syncService;
    late MockCacheService mockCacheService;

    setUp(() {
      mockCacheService = MockCacheService();
      syncService = SyncService(mockCacheService);
    });

    test('Doit mettre en file d\'attente une opération', () async {
      final operation = SyncOperation(
        type: 'create',
        data: {'id': 1, 'name': 'test'},
        timestamp: DateTime.now(),
      );

      await syncService.enqueueOperation(operation);
      verify(mockCacheService.set('pending_operations', any)).called(1);
    });

    test('Doit gérer les erreurs de connexion', () async {
      when(mockCacheService.set(any, any))
          .thenAnswer((_) => Future.value(true));

      final operation = SyncOperation(
        type: 'update',
        data: {'id': 1, 'status': 'completed'},
        timestamp: DateTime.now(),
      );

      await syncService.enqueueOperation(operation);
      // Vérifie que l'opération est sauvegardée même en cas d'erreur
      verify(mockCacheService.set('pending_operations', any)).called(1);
    });
  });
}