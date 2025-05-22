import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greens_app/features/product_scanner/controllers/scanner_controller.dart';
import 'package:greens_app/features/product_scanner/services/product_service.dart';
import 'package:greens_app/features/product_scanner/services/eco_product_api_service.dart';
import 'package:greens_app/features/product_scanner/models/product_model.dart';
import 'package:greens_app/features/product_scanner/services/product_database.dart';

@GenerateNiceMocks([
  MockSpec<ProductService>(),
  MockSpec<EcoProductApiService>(),
  MockSpec<ProductDatabase>(),
  MockSpec<ImagePicker>(),
])
import 'scanner_controller_test.mocks.dart';

void main() {
  group('ScannerController Tests', () {
    late ScannerController scannerController;
    late MockProductService mockProductService;
    late MockEcoProductApiService mockEcoProductApiService;
    late MockProductDatabase mockProductDatabase;
    late MockImagePicker mockImagePicker;

    setUp(() {
      mockProductService = MockProductService();
      mockEcoProductApiService = MockEcoProductApiService();
      mockProductDatabase = MockProductDatabase();
      mockImagePicker = MockImagePicker();
      
      // Injecter les services mockés dans le contrôleur
      scannerController = ScannerController(
        productService: mockProductService,
        database: mockProductDatabase,
        ecoProductApiService: mockEcoProductApiService,
        imagePicker: mockImagePicker,
      );
    });

    test('_fetchProductInfo - Succès avec EcoProductApiService', () async {
      // Produit de test
      final testProduct = Product(
        id: 'test_123',
        barcode: '3000000000000',
        name: 'Produit Test',
        brand: 'Marque Test',
        category: 'Fruits',
        ecoScore: 80.0,
        carbonFootprint: 2.0,
        waterFootprint: 600.0,
        scannedAt: DateTime.now(),
      );

      // Configurer le mock pour retourner le produit de test
      when(mockEcoProductApiService.getProductInfo('3000000000000'))
          .thenAnswer((_) async => testProduct);
      
      // Configurer le mock pour les alternatives
      when(mockProductDatabase.getAlternatives(any))
          .thenAnswer((_) async => []);

      // Appeler la méthode à tester
      await scannerController.testFetchProductInfo('3000000000000');

      // Vérifications
      expect(scannerController.state, equals(ScannerState.success));
      expect(scannerController.scannedProduct, equals(testProduct));
      expect(scannerController.errorMessage, isNull);
    });

    test('_fetchProductInfo - Fallback à ProductService quand EcoProductApiService échoue', () async {
      // Produit non trouvé par EcoProductApiService
      final notFoundProduct = Product(
        id: 'error_3000000000001',
        barcode: '3000000000001',
        name: 'Produit non trouvé',
        brand: 'Inconnu',
        category: 'Non catégorisé',
        ecoScore: 0.0,
        carbonFootprint: 0.0,
        waterFootprint: 0.0,
        scannedAt: DateTime.now(),
      );

      // Produit trouvé par ProductService
      final localProduct = Product(
        id: 'local_123',
        barcode: '3000000000001',
        name: 'Produit Local',
        brand: 'Marque Locale',
        category: 'Légumes',
        ecoScore: 60.0,
        carbonFootprint: 3.0,
        waterFootprint: 800.0,
        scannedAt: DateTime.now(),
      );

      // Configurer les mocks
      when(mockEcoProductApiService.getProductInfo('3000000000001'))
          .thenAnswer((_) async => notFoundProduct);
      
      when(mockProductService.getProductByBarcode('3000000000001'))
          .thenAnswer((_) async => localProduct);
      
      when(mockProductDatabase.getAlternatives(any))
          .thenAnswer((_) async => []);

      // Appeler la méthode à tester
      await scannerController.testFetchProductInfo('3000000000001');

      // Vérifications
      expect(scannerController.state, equals(ScannerState.success));
      expect(scannerController.scannedProduct, equals(localProduct));
      expect(scannerController.errorMessage, isNull);
    });

    test('_fetchProductInfo - Échec complet', () async {
      // Configurer les mocks pour simuler des échecs
      when(mockEcoProductApiService.getProductInfo('3000000000002'))
          .thenThrow(Exception('API error'));
      
      when(mockProductService.getProductByBarcode('3000000000002'))
          .thenThrow(Exception('Database error'));

      // Appeler la méthode à tester
      await scannerController.testFetchProductInfo('3000000000002');

      // Vérifications
      expect(scannerController.state, equals(ScannerState.error));
      expect(scannerController.scannedProduct, isNull);
      expect(scannerController.errorMessage, isNotNull);
    });

    test('_findAlternatives - Alternatives trouvées dans la base de données', () async {
      // Produit de test
      final testProduct = Product(
        id: 'test_123',
        barcode: '3000000000000',
        name: 'Produit Test',
        brand: 'Marque Test',
        category: 'Fruits',
        ecoScore: 60.0,
        carbonFootprint: 2.0,
        waterFootprint: 600.0,
        scannedAt: DateTime.now(),
      );

      // Alternatives
      final alternatives = [
        Product(
          id: 'alt_1',
          barcode: '3000000000003',
          name: 'Alternative 1',
          brand: 'Marque Eco',
          category: 'Fruits',
          ecoScore: 85.0,
          carbonFootprint: 1.0,
          waterFootprint: 400.0,
          scannedAt: DateTime.now(),
        ),
        Product(
          id: 'alt_2',
          barcode: '3000000000004',
          name: 'Alternative 2',
          brand: 'Marque Bio',
          category: 'Fruits',
          ecoScore: 90.0,
          carbonFootprint: 0.8,
          waterFootprint: 350.0,
          scannedAt: DateTime.now(),
        ),
      ];

      // Configurer le mock
      when(mockProductDatabase.getAlternatives(testProduct))
          .thenAnswer((_) async => alternatives);

      // Appeler la méthode à tester
      scannerController.scannedProduct = testProduct;
      await scannerController.testFindAlternatives(testProduct);

      // Vérifications
      expect(scannerController.alternatives, equals(alternatives));
      expect(scannerController.alternatives.length, equals(2));
    });

    test('_findAlternatives - Recherche d\'alternatives via ProductService', () async {
      // Produit de test
      final testProduct = Product(
        id: 'test_123',
        barcode: '3000000000000',
        name: 'Produit Test',
        brand: 'Marque Test',
        category: 'Légumes',
        ecoScore: 50.0,
        carbonFootprint: 3.0,
        waterFootprint: 800.0,
        scannedAt: DateTime.now(),
      );

      // Produits similaires
      final similarProducts = [
        Product(
          id: 'sim_1',
          barcode: '3000000000005',
          name: 'Similaire 1',
          brand: 'Marque X',
          category: 'Légumes',
          ecoScore: 40.0, // Moins bon
          carbonFootprint: 3.5,
          waterFootprint: 900.0,
          scannedAt: DateTime.now(),
        ),
        Product(
          id: 'sim_2',
          barcode: '3000000000006',
          name: 'Similaire 2',
          brand: 'Marque Y',
          category: 'Légumes',
          ecoScore: 65.0, // Meilleur
          carbonFootprint: 2.0,
          waterFootprint: 600.0,
          scannedAt: DateTime.now(),
        ),
        Product(
          id: 'sim_3',
          barcode: '3000000000007',
          name: 'Similaire 3',
          brand: 'Marque Z',
          category: 'Légumes',
          ecoScore: 75.0, // Meilleur
          carbonFootprint: 1.5,
          waterFootprint: 500.0,
          scannedAt: DateTime.now(),
        ),
      ];

      // Configurer les mocks
      when(mockProductDatabase.getAlternatives(testProduct))
          .thenAnswer((_) async => []);
      
      when(mockProductService.searchProducts('Légumes'))
          .thenAnswer((_) async => similarProducts);

      // Appeler la méthode à tester
      scannerController.scannedProduct = testProduct;
      await scannerController.testFindAlternatives(testProduct);

      // Vérifications
      expect(scannerController.alternatives.length, equals(2)); // Seulement ceux avec un meilleur eco-score
      expect(scannerController.alternatives[0].ecoScore, equals(75.0)); // Trié par eco-score décroissant
      expect(scannerController.alternatives[1].ecoScore, equals(65.0));
    });
  });
}
