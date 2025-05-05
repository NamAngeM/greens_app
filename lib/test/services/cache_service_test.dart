import 'package:test/test.dart';
import 'package:greens_app/services/cache_service.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    test('Doit stocker et récupérer une valeur', () async {
      await cacheService.set('test_key', 'test_value');
      expect(await cacheService.get('test_key'), equals('test_value'));
    });

    test('Doit gérer le dépassement de taille maximale', () async {
      for (int i = 0; i < 150; i++) {
        await cacheService.set('key_$i', 'value_$i');
      }
      expect(cacheService.size, lessThanOrEqualTo(100));
    });
  });
}