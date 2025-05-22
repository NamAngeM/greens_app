import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'package:flutter/foundation.dart';

/// Service qui intègre plusieurs APIs spécialisées pour obtenir des informations
/// environnementales détaillées sur les produits scannés.
class EcoProductApiService {
  // Singleton
  static final EcoProductApiService instance = EcoProductApiService._internal();
  
  // Client HTTP pour les requêtes API
  final http.Client _client;
  
  // URLs des APIs
  final String _openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v2/product';
  final String _ecobalyseUrl = 'https://api.ecobalyse.fr/products';
  final String _carbonCloudUrl = 'https://api.carboncloud.com/v0/products';
  
  // Clé API pour CarbonCloud (à remplacer par votre propre clé)
  // En production, cette clé devrait être stockée de manière sécurisée
  final String _carbonCloudApiKey;

  // Constructeur privé pour le singleton
  EcoProductApiService._internal() : 
    _client = http.Client(),
    _carbonCloudApiKey = const String.fromEnvironment('CARBON_CLOUD_API_KEY', defaultValue: 'CC_7a9b3f2e1d8c5g6h');
  
  // Constructeur pour les tests avec injection de dépendances
  @visibleForTesting
  EcoProductApiService.test({
    required http.Client client,
    String carbonCloudApiKey = 'TEST_API_KEY'
  }) : 
    _client = client,
    _carbonCloudApiKey = carbonCloudApiKey;

  /// Récupère les informations complètes d'un produit à partir de son code-barres
  /// en combinant les données de plusieurs sources.
  Future<Product> getProductInfo(String barcode) async {
    try {
      // Récupérer les données de base depuis Open Food Facts
      final openFoodFactsData = await _fetchOpenFoodFactsData(barcode);
      
      // Initialiser le produit avec les données de base
      Product product = _mapOpenFoodFactsToProduct(openFoodFactsData, barcode);
      
      // Enrichir avec les données d'Ecobalyse si disponibles
      try {
        final ecobalyseData = await _fetchEcobalyseData(barcode);
        product = _enrichWithEcobalyseData(product, ecobalyseData);
      } catch (e) {
        debugPrint('Erreur lors de la récupération des données Ecobalyse: $e');
        // Continuer même si Ecobalyse échoue
      }
      
      // Enrichir avec les données de CarbonCloud si disponibles
      try {
        final carbonCloudData = await _fetchCarbonCloudData(barcode);
        product = _enrichWithCarbonCloudData(product, carbonCloudData);
      } catch (e) {
        debugPrint('Erreur lors de la récupération des données CarbonCloud: $e');
        // Continuer même si CarbonCloud échoue
      }
      
      return product;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des informations du produit: $e');
      // En cas d'échec complet, retourner un produit avec des données minimales
      return Product(
        id: 'error_$barcode',
        barcode: barcode,
        name: 'Produit non trouvé',
        brand: 'Inconnu',
        category: 'Non catégorisé',
        ecoScore: 0.0,
        carbonFootprint: 0.0,
        waterFootprint: 0.0,
        scannedAt: DateTime.now(),
      );
    }
  }

  /// Récupère les données depuis Open Food Facts
  Future<Map<String, dynamic>> _fetchOpenFoodFactsData(String barcode) async {
    final response = await _client.get(
      Uri.parse('$_openFoodFactsUrl/$barcode.json'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 1) {
        return data['product'];
      } else {
        throw Exception('Produit non trouvé dans Open Food Facts');
      }
    } else {
      throw Exception('Erreur Open Food Facts: ${response.statusCode}');
    }
  }

  /// Récupère les données depuis Ecobalyse
  Future<Map<String, dynamic>> _fetchEcobalyseData(String barcode) async {
    final response = await _client.get(
      Uri.parse('$_ecobalyseUrl/$barcode'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur Ecobalyse: ${response.statusCode}');
    }
  }

  /// Récupère les données depuis CarbonCloud
  Future<Map<String, dynamic>> _fetchCarbonCloudData(String barcode) async {
    final response = await _client.get(
      Uri.parse('$_carbonCloudUrl/$barcode'),
      headers: {
        'Authorization': 'Bearer $_carbonCloudApiKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur CarbonCloud: ${response.statusCode}');
    }
  }

  /// Convertit les données Open Food Facts en objet Product
  Product _mapOpenFoodFactsToProduct(Map<String, dynamic> data, String barcode) {
    // Calculer un eco-score basé sur les données disponibles
    final ecoScore = _calculateEcoScore(data);
    
    // Extraire les ingrédients
    final ingredientsList = _extractIngredients(data);
    
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
      ingredients: ingredientsList,
      nutritionalInfo: _extractNutritionalInfo(data),
      environmentalImpact: _extractEnvironmentalImpact(data),
      scannedAt: DateTime.now(),
    );
  }

  /// Enrichit le produit avec les données d'Ecobalyse
  Product _enrichWithEcobalyseData(Product product, Map<String, dynamic> ecobalyseData) {
    // Extraire les données environnementales d'Ecobalyse
    final environmentalImpact = product.environmentalImpact ?? {};
    
    // Mettre à jour ou ajouter les données d'Ecobalyse
    if (ecobalyseData.containsKey('environmental_impact')) {
      final impact = ecobalyseData['environmental_impact'];
      
      // Créer une structure enrichie pour l'impact environnemental
      final ecobalyseImpact = {
        'ecobalyse': {
          'score': impact['score'] ?? 0.0,
          'carbon': impact['carbon_footprint'] ?? 0.0,
          'water': impact['water_footprint'] ?? 0.0,
          'land_use': impact['land_use'] ?? 0.0,
          'biodiversity': impact['biodiversity_impact'] ?? 0.0,
          'resource_depletion': impact['resource_depletion'] ?? 0.0,
        }
      };
      
      // Fusionner avec les données existantes
      environmentalImpact.addAll(ecobalyseImpact);
      
      // Mettre à jour les valeurs principales si plus précises
      double carbonFootprint = product.carbonFootprint;
      double waterFootprint = product.waterFootprint;
      double ecoScore = product.ecoScore;
      
      if (impact['carbon_footprint'] != null) {
        carbonFootprint = impact['carbon_footprint'];
      }
      
      if (impact['water_footprint'] != null) {
        waterFootprint = impact['water_footprint'];
      }
      
      if (impact['score'] != null) {
        // Pondérer avec le score existant pour une meilleure précision
        ecoScore = (ecoScore + impact['score']) / 2;
      }
      
      // Retourner un produit enrichi
      return product.copyWith(
        carbonFootprint: carbonFootprint,
        waterFootprint: waterFootprint,
        ecoScore: ecoScore,
        environmentalImpact: environmentalImpact,
      );
    }
    
    return product;
  }

  /// Enrichit le produit avec les données de CarbonCloud
  Product _enrichWithCarbonCloudData(Product product, Map<String, dynamic> carbonCloudData) {
    // Extraire les données environnementales de CarbonCloud
    final environmentalImpact = product.environmentalImpact ?? {};
    
    // Mettre à jour ou ajouter les données de CarbonCloud
    if (carbonCloudData.containsKey('climate_footprint')) {
      final impact = carbonCloudData['climate_footprint'];
      
      // Créer une structure enrichie pour l'impact climatique
      final carbonCloudImpact = {
        'carbon_cloud': {
          'total_footprint': impact['total'] ?? 0.0,
          'details': {
            'farming': impact['farming'] ?? 0.0,
            'processing': impact['processing'] ?? 0.0,
            'packaging': impact['packaging'] ?? 0.0,
            'transport': impact['transport'] ?? 0.0,
            'retail': impact['retail'] ?? 0.0,
          },
          'methodology': carbonCloudData['methodology'] ?? 'Standard',
          'certification': carbonCloudData['certification'] ?? false,
        }
      };
      
      // Fusionner avec les données existantes
      environmentalImpact.addAll(carbonCloudImpact);
      
      // Mettre à jour l'empreinte carbone si plus précise
      double carbonFootprint = product.carbonFootprint;
      
      if (impact['total'] != null) {
        // Utiliser la valeur de CarbonCloud qui est généralement plus précise
        carbonFootprint = impact['total'];
      }
      
      // Retourner un produit enrichi
      return product.copyWith(
        carbonFootprint: carbonFootprint,
        environmentalImpact: environmentalImpact,
      );
    }
    
    return product;
  }

  /// Calcule un eco-score basé sur différentes données environnementales
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

  /// Extrait l'empreinte carbone des données
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

  /// Calcule l'empreinte eau en litres/kg (estimation)
  double _calculateWaterFootprint(Map<String, dynamic> data) {
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

  /// Détermine si l'emballage est recyclable
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

  /// Extrait les ingrédients du produit
  List<String> _extractIngredients(Map<String, dynamic> data) {
    if (data['ingredients_text'] != null && data['ingredients_text'].toString().isNotEmpty) {
      // Diviser le texte des ingrédients en liste
      return data['ingredients_text']
          .toString()
          .split(',')
          .map((ingredient) => ingredient.trim())
          .where((ingredient) => ingredient.isNotEmpty)
          .toList();
    }
    return ['Informations sur les ingrédients non disponibles'];
  }

  /// Extrait les informations nutritionnelles
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

  /// Extrait l'impact environnemental des données
  Map<String, dynamic> _extractEnvironmentalImpact(Map<String, dynamic> data) {
    final environmentalImpact = <String, dynamic>{};
    
    // Données carbone
    environmentalImpact['carbon'] = {
      'value': _extractCarbonFootprint(data),
      'details': {
        'production': 0.0,
        'transport': 0.0,
        'packaging': 0.0,
        'processing': 0.0,
      },
      'equivalents': {
        'km_voiture': _extractCarbonFootprint(data) * 4.2, // Approximation: 1kg CO2 = 4.2km en voiture
        'charges_smartphone': _extractCarbonFootprint(data) * 250, // Approximation: 1kg CO2 = 250 charges
        'arbres_necessaires': _extractCarbonFootprint(data) * 0.04, // Approximation: 1kg CO2 = 0.04 arbre/an
        'jours_chauffage': _extractCarbonFootprint(data) * 0.06, // Approximation: 1kg CO2 = 0.06 jour de chauffage
      },
    };
    
    // Données eau
    environmentalImpact['water'] = {
      'value': _calculateWaterFootprint(data),
    };
    
    // Eco-score
    environmentalImpact['ecoScore'] = _calculateEcoScore(data);
    
    // Conseils écologiques
    environmentalImpact['ecoTips'] = _generateEcoTips(data);
    
    return environmentalImpact;
  }

  /// Génère des conseils écologiques adaptés au produit
  List<String> _generateEcoTips(Map<String, dynamic> data) {
    final tips = <String>[];
    final category = data['categories_tags']?.isNotEmpty == true
        ? data['categories_tags'][0].toString().toLowerCase()
        : '';
    
    // Conseils généraux
    tips.add('Privilégiez les produits locaux et de saison');
    
    // Conseils spécifiques par catégorie
    if (category.contains('meat') || category.contains('beef')) {
      tips.add('Réduisez votre consommation de viande pour diminuer votre empreinte carbone');
      tips.add('Privilégiez les viandes issues d\'élevages durables et locaux');
    } else if (category.contains('dairy') || category.contains('cheese')) {
      tips.add('Optez pour des produits laitiers issus d\'élevages durables');
      tips.add('Essayez les alternatives végétales qui ont souvent une empreinte écologique plus faible');
    } else if (category.contains('vegetables') || category.contains('fruits')) {
      tips.add('Achetez des fruits et légumes de saison et produits localement');
      tips.add('Privilégiez les produits biologiques pour réduire l\'impact des pesticides');
    } else if (category.contains('cereals') || category.contains('grains')) {
      tips.add('Choisissez des céréales complètes et biologiques');
      tips.add('Achetez en vrac pour réduire les emballages');
    }
    
    // Conseils sur l'emballage
    if (data['packaging'] != null) {
      final packaging = data['packaging'].toString().toLowerCase();
      if (packaging.contains('plastic')) {
        tips.add('Recherchez des alternatives avec moins d\'emballages plastiques');
      }
      if (!_isPackagingRecyclable(data)) {
        tips.add('Privilégiez les produits avec des emballages recyclables');
      }
    }
    
    return tips;
  }
}
