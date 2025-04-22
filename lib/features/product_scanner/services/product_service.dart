import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v0';
  
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$barcode.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1) {
          return _mapResponseToProduct(data['product'], barcode);
        } else {
          throw Exception('Produit non trouvé');
        }
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      // Simuler un produit pour les tests en cas d'erreur
      // À supprimer en production
      return Product.mock();
    }
  }
  
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/${Uri.encodeComponent(query)}.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['count'] > 0) {
          final List<dynamic> productsJson = data['products'];
          return productsJson
              .take(10) // Limiter à 10 résultats
              .map<Product>((product) => _mapResponseToProduct(
                  product, product['code'] ?? 'unknown'))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }
  
  Product _mapResponseToProduct(Map<String, dynamic> data, String barcode) {
    // Calculer un eco-score basé sur différentes données environnementales
    final ecoScore = _calculateEcoScore(data);
    
    return Product(
      id: data['_id'] ?? barcode,
      barcode: barcode,
      name: data['product_name'] ?? 'Produit inconnu',
      brand: data['brands'] ?? 'Marque inconnue',
      category: data['categories_tags']?.isNotEmpty == true
          ? data['categories_tags'][0].toString().replaceAll('en:', '')
          : 'Non catégorisé',
      imageUrl: data['image_url'] ?? '',
      ecoScore: ecoScore,
      carbonFootprint: _extractCarbonFootprint(data),
      waterFootprint: _calculateWaterFootprint(data),
      recyclablePackaging: _isPackagingRecyclable(data),
      ingredients: _extractIngredients(data),
      nutritionalInfo: _extractNutritionalInfo(data),
      scannedAt: DateTime.now(),
    );
  }
  
  double _calculateEcoScore(Map<String, dynamic> data) {
    // Utiliser l'eco-score de Open Food Facts s'il existe
    if (data['ecoscore_score'] != null) {
      return (data['ecoscore_score'] as num).toDouble();
    }
    
    // Sinon, calculer un score approximatif basé sur d'autres facteurs
    double score = 50.0; // Score par défaut moyen
    
    // Ajuster en fonction de facteurs environnementaux si disponibles
    if (data['ecoscore_grade'] != null) {
      final grade = data['ecoscore_grade'].toString().toLowerCase();
      if (grade == 'a') score = 90.0;
      else if (grade == 'b') score = 70.0;
      else if (grade == 'c') score = 50.0;
      else if (grade == 'd') score = 30.0;
      else if (grade == 'e') score = 10.0;
    }
    
    // Réduire le score si produit transformé
    if (data['nova_group'] != null) {
      final novaGroup = (data['nova_group'] as num).toInt();
      score -= (novaGroup - 1) * 5.0; // Plus le groupe NOVA est élevé, moins le produit est naturel
    }
    
    // Ajuster en fonction du packaging si connu
    if (data['packaging'] != null) {
      if (data['packaging'].toString().contains('plastic')) {
        score -= 10.0;
      }
      if (data['packaging'].toString().contains('carton') || 
          data['packaging'].toString().contains('paper')) {
        score += 5.0;
      }
    }
    
    // Ajuster pour les produits biologiques
    if (data['labels_tags'] != null) {
      final labels = data['labels_tags'] as List<dynamic>;
      if (labels.any((label) => label.toString().contains('organic') || 
                               label.toString().contains('bio'))) {
        score += 15.0;
      }
    }
    
    // Limiter le score entre 0 et 100
    return score.clamp(0.0, 100.0);
  }
  
  double _extractCarbonFootprint(Map<String, dynamic> data) {
    // Extraire l'empreinte carbone si disponible
    if (data['carbon_footprint_value'] != null) {
      return (data['carbon_footprint_value'] as num).toDouble();
    }
    
    // Sinon, estimation basée sur la catégorie du produit
    // Valeur en kg CO2 eq/kg de produit (très approximatif)
    final category = data['categories_tags']?.isNotEmpty == true
        ? data['categories_tags'][0].toString().toLowerCase()
        : '';
    
    if (category.contains('meat') || category.contains('beef')) {
      return 27.0;
    } else if (category.contains('dairy') || category.contains('cheese')) {
      return 13.5;
    } else if (category.contains('vegetables') || category.contains('fruits')) {
      return 2.0;
    } else if (category.contains('cereals') || category.contains('grains')) {
      return 1.5;
    }
    
    // Valeur par défaut
    return 8.0;
  }
  
  double _calculateWaterFootprint(Map<String, dynamic> data) {
    // L'empreinte eau en litres/kg (estimation)
    final category = data['categories_tags']?.isNotEmpty == true
        ? data['categories_tags'][0].toString().toLowerCase()
        : '';
    
    if (category.contains('meat') || category.contains('beef')) {
      return 15000.0;
    } else if (category.contains('dairy') || category.contains('cheese')) {
      return 5000.0;
    } else if (category.contains('vegetables')) {
      return 300.0;
    } else if (category.contains('fruits')) {
      return 800.0;
    } else if (category.contains('cereals') || category.contains('grains')) {
      return 1500.0;
    }
    
    // Valeur par défaut
    return 2000.0;
  }
  
  bool _isPackagingRecyclable(Map<String, dynamic> data) {
    if (data['packaging'] == null) return false;
    
    final packaging = data['packaging'].toString().toLowerCase();
    
    // Liste non exhaustive de matériaux généralement recyclables
    final recyclableMaterials = [
      'paper', 'papier', 'carton', 'cardboard', 
      'glass', 'verre',
      'aluminium', 'aluminum', 'metal', 'steel', 'tin'
    ];
    
    return recyclableMaterials.any((material) => packaging.contains(material));
  }
  
  String _extractIngredients(Map<String, dynamic> data) {
    if (data['ingredients_text'] != null && data['ingredients_text'].toString().isNotEmpty) {
      return data['ingredients_text'];
    }
    return 'Informations sur les ingrédients non disponibles';
  }
  
  Map<String, dynamic> _extractNutritionalInfo(Map<String, dynamic> data) {
    final nutritionalInfo = <String, dynamic>{};
    
    if (data['nutriments'] != null) {
      final nutriments = data['nutriments'] as Map<String, dynamic>;
      
      nutritionalInfo['calories'] = nutriments['energy-kcal_100g'] ?? 0.0;
      nutritionalInfo['fat'] = nutriments['fat_100g'] ?? 0.0;
      nutritionalInfo['saturatedFat'] = nutriments['saturated-fat_100g'] ?? 0.0;
      nutritionalInfo['carbohydrates'] = nutriments['carbohydrates_100g'] ?? 0.0;
      nutritionalInfo['sugars'] = nutriments['sugars_100g'] ?? 0.0;
      nutritionalInfo['fiber'] = nutriments['fiber_100g'] ?? 0.0;
      nutritionalInfo['proteins'] = nutriments['proteins_100g'] ?? 0.0;
      nutritionalInfo['salt'] = nutriments['salt_100g'] ?? 0.0;
    }
    
    return nutritionalInfo;
  }
} 