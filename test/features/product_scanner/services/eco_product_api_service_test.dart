import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/features/product_scanner/services/eco_product_api_service.dart';
import 'package:greens_app/features/product_scanner/models/product_model.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'eco_product_api_service_test.mocks.dart';

void main() {
  group('EcoProductApiService Tests', () {
    late MockClient mockClient;
    late EcoProductApiService ecoProductApiService;

    setUp(() {
      mockClient = MockClient();
      // Injecter le client HTTP mocké dans le service
      ecoProductApiService = EcoProductApiService.test(
        client: mockClient,
        carbonCloudApiKey: 'test_api_key'
      );
    });

    test('getProductInfo - Succès avec toutes les sources', () async {
      // Données de test pour Open Food Facts
      final openFoodFactsData = {
        'status': 1,
        'product': {
          '_id': 'test_123',
          'product_name': 'Produit Test',
          'brands': 'Marque Test',
          'categories_tags': ['en:fruits'],
          'image_url': 'https://example.com/image.jpg',
          'ecoscore_score': 80,
          'carbon_footprint_value': 2.5,
          'packaging': 'carton',
          'ingredients_text': 'Ingrédient 1, Ingrédient 2',
          'nutriments': {
            'energy-kcal_100g': 100,
            'fat_100g': 0.5,
            'saturated-fat_100g': 0.1,
            'carbohydrates_100g': 20,
            'sugars_100g': 15,
            'fiber_100g': 2,
            'proteins_100g': 1,
            'salt_100g': 0.01
          },
          'labels_tags': ['en:organic']
        }
      };

      // Données de test pour Ecobalyse
      final ecobalyseData = {
        'environmental_impact': {
          'score': 85,
          'carbon_footprint': 2.0,
          'water_footprint': 600,
          'land_use': 1.5,
          'biodiversity_impact': 0.8,
          'resource_depletion': 0.7
        }
      };

      // Données de test pour CarbonCloud
      final carbonCloudData = {
        'climate_footprint': {
          'total': 1.8,
          'farming': 1.0,
          'processing': 0.3,
          'packaging': 0.2,
          'transport': 0.2,
          'retail': 0.1
        },
        'methodology': 'ISO 14067',
        'certification': true
      };

      // Configuration des réponses mockées
      when(mockClient.get(Uri.parse('https://world.openfoodfacts.org/api/v2/product/3000000000000.json')))
          .thenAnswer((_) async => http.Response(json.encode({'status': 1, 'product': openFoodFactsData['product']}), 200));
      
      when(mockClient.get(Uri.parse('https://api.ecobalyse.fr/products/3000000000000')))
          .thenAnswer((_) async => http.Response(json.encode(ecobalyseData), 200));
      
      when(mockClient.get(
        Uri.parse('https://api.carboncloud.com/v0/products/3000000000000'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(json.encode(carbonCloudData), 200));

      // Appel de la méthode à tester
      final product = await ecoProductApiService.getProductInfo('3000000000000');

      // Vérifications
      expect(product.id, equals('test_123'));
      expect(product.name, equals('Produit Test'));
      expect(product.brand, equals('Marque Test'));
      expect(product.category, equals('fruits'));
      expect(product.ecoScore, closeTo(82.5, 0.1)); // Moyenne entre 80 (OFF) et 85 (Ecobalyse)
      expect(product.carbonFootprint, equals(1.8)); // Valeur de CarbonCloud (plus précise)
      expect(product.waterFootprint, equals(600)); // Valeur d'Ecobalyse
      expect(product.recyclablePackaging, isTrue);
      expect(product.ingredients.length, equals(2));
    });

    test('getProductInfo - Succès avec Open Food Facts uniquement', () async {
      // Données de test pour Open Food Facts
      final openFoodFactsData = {
        'status': 1,
        'product': {
          '_id': 'test_456',
          'product_name': 'Produit Simple',
          'brands': 'Marque Simple',
          'categories_tags': ['en:vegetables'],
          'image_url': 'https://example.com/image2.jpg',
          'ecoscore_score': 70,
          'packaging': 'plastic',
          'ingredients_text': 'Ingrédient A, Ingrédient B, Ingrédient C',
          'nutriments': {
            'energy-kcal_100g': 120,
            'fat_100g': 1.0,
            'carbohydrates_100g': 25,
            'proteins_100g': 2
          }
        }
      };

      // Configuration des réponses mockées
      when(mockClient.get(Uri.parse('https://world.openfoodfacts.org/api/v2/product/3000000000001.json')))
          .thenAnswer((_) async => http.Response(json.encode({'status': 1, 'product': openFoodFactsData['product']}), 200));
      
      when(mockClient.get(Uri.parse('https://api.ecobalyse.fr/products/3000000000001')))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      
      when(mockClient.get(
        Uri.parse('https://api.carboncloud.com/v0/products/3000000000001'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Appel de la méthode à tester
      final product = await ecoProductApiService.getProductInfo('3000000000001');

      // Vérifications
      expect(product.id, equals('test_456'));
      expect(product.name, equals('Produit Simple'));
      expect(product.ecoScore, equals(70));
      expect(product.recyclablePackaging, isFalse); // Emballage plastique
      expect(product.ingredients.length, equals(3));
    });

    test('getProductInfo - Échec de toutes les sources', () async {
      // Configuration des réponses mockées pour simuler des échecs
      when(mockClient.get(Uri.parse('https://world.openfoodfacts.org/api/v2/product/3000000000002.json')))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      
      when(mockClient.get(Uri.parse('https://api.ecobalyse.fr/products/3000000000002')))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      
      when(mockClient.get(
        Uri.parse('https://api.carboncloud.com/v0/products/3000000000002'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Appel de la méthode à tester
      final product = await ecoProductApiService.getProductInfo('3000000000002');

      // Vérifications
      expect(product.id, equals('error_3000000000002'));
      expect(product.name, equals('Produit non trouvé'));
      expect(product.ecoScore, equals(0.0));
    });
  });
}
