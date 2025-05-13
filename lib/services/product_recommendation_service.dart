// lib/services/product_recommendation_service.dart
import 'package:flutter/material.dart';
import 'package:greens_app/models/product.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/product_controller.dart';
import 'package:greens_app/services/carbon_footprint_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service qui recommande des produits basés sur les objectifs écologiques de l'utilisateur
class ProductRecommendationService extends ChangeNotifier {
  final EcoGoalController _goalController;
  final ProductController _productController;
  final CarbonFootprintService _carbonService;
  final FirebaseFirestore _firestore;
  
  // Singleton
  static final ProductRecommendationService _instance = ProductRecommendationService._internal(
    EcoGoalController(),
    ProductController(),
    CarbonFootprintService(),
    FirebaseFirestore.instance,
  );
  
  factory ProductRecommendationService() {
    return _instance;
  }
  
  ProductRecommendationService._internal(
    this._goalController,
    this._productController,
    this._carbonService,
    this._firestore,
  );
  
  static ProductRecommendationService get instance => _instance;
  
  // Cache des recommandations
  Map<String, List<Product>> _recommendationCache = {};
  DateTime _lastCacheUpdate = DateTime.now().subtract(const Duration(days: 1));
  
  // Durée de validité du cache (en heures)
  static const int _cacheDuration = 24;
  
  /// Récupère les produits recommandés pour un utilisateur spécifique
  Future<List<Product>> getRecommendedProducts(String userId) async {
    // Vérifier si le cache est valide
    final cacheAge = DateTime.now().difference(_lastCacheUpdate).inHours;
    if (_recommendationCache.containsKey(userId) && cacheAge < _cacheDuration) {
      return _recommendationCache[userId]!;
    }
    
    try {
      // Récupérer les objectifs de l'utilisateur
      await _goalController.getUserGoals(userId);
      final goals = _goalController.userGoals;
      
      // Récupérer l'empreinte carbone de l'utilisateur
      final footprint = await _carbonService.getUserCarbonFootprint(userId);
      
      // Récupérer tous les produits
      final allProducts = await _productController.getAllProducts();
      
      // Calculer le score de pertinence pour chaque produit
      final scoredProducts = <Map<String, dynamic>>[];
      
      for (final product in allProducts) {
        double relevanceScore = 0.0;
        
        // Analyser les objectifs de l'utilisateur
        for (final goal in goals) {
          // Augmenter le score en fonction du type d'objectif et des tags du produit
          relevanceScore += _calculateGoalProductRelevance(goal, product);
        }
        
        // Prendre en compte l'empreinte carbone si disponible
        if (footprint != null) {
          relevanceScore += _calculateFootprintProductRelevance(footprint, product);
        }
        
        // Ajouter un bonus pour les produits écologiques
        if (product.isEcoFriendly) {
          relevanceScore += 2.0;
        }
        
        // Ajouter le produit avec son score
        scoredProducts.add({
          'product': product,
          'score': relevanceScore,
        });
      }
      
      // Trier les produits par score de pertinence (décroissant)
      scoredProducts.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      
      // Prendre les 10 produits les plus pertinents
      final recommendedProducts = scoredProducts
          .take(10)
          .map((item) => item['product'] as Product)
          .toList();
      
      // Mettre à jour le cache
      _recommendationCache[userId] = recommendedProducts;
      _lastCacheUpdate = DateTime.now();
      
      return recommendedProducts;
    } catch (e) {
      print('ProductRecommendationService: Erreur lors de la récupération des recommandations: $e');
      return [];
    }
  }
  
  /// Calcule la pertinence d'un produit par rapport à un objectif écologique
  double _calculateGoalProductRelevance(EcoGoal goal, Product product) {
    double score = 0.0;
    
    // Vérifier le type d'objectif
    switch (goal.type) {
      case GoalType.wasteReduction:
        // Produits liés à la réduction des déchets
        if (_containsKeywords(product, ['zéro déchet', 'compostable', 'réutilisable', 'recyclable'])) {
          score += 3.0;
        }
        break;
        
      case GoalType.waterSaving:
        // Produits liés à l'économie d'eau
        if (_containsKeywords(product, ['économie d\'eau', 'douche', 'robinet', 'récupération'])) {
          score += 3.0;
        }
        break;
        
      case GoalType.energySaving:
        // Produits liés à l'économie d'énergie
        if (_containsKeywords(product, ['énergie', 'solaire', 'LED', 'économie d\'électricité'])) {
          score += 3.0;
        }
        break;
        
      case GoalType.sustainableShopping:
        // Produits liés à la consommation responsable
        if (_containsKeywords(product, ['bio', 'équitable', 'local', 'durable'])) {
          score += 3.0;
        }
        // Bonus pour les produits alimentaires si l'objectif concerne l'alimentation
        if (goal.title.toLowerCase().contains('aliment') && 
            product.category.toLowerCase().contains('aliment')) {
          score += 2.0;
        }
        break;
        
      case GoalType.transportation:
        // Produits liés au transport durable
        if (_containsKeywords(product, ['vélo', 'transport', 'mobilité'])) {
          score += 3.0;
        }
        break;
        
      case GoalType.custom:
        // Pour les objectifs personnalisés, analyser le titre et la description
        final keywords = _extractKeywords(goal.title + ' ' + goal.description);
        if (_containsAnyKeyword(product, keywords)) {
          score += 2.0;
        }
        break;
    }
    
    // Bonus si l'objectif est en cours (pas complété)
    if (!goal.isCompleted) {
      score += 1.0;
    }
    
    // Bonus si l'objectif a une progression faible (besoin d'aide)
    if (goal.currentProgress / goal.target < 0.3) {
      score += 1.5;
    }
    
    return score;
  }
  
  /// Calcule la pertinence d'un produit par rapport à l'empreinte carbone
  double _calculateFootprintProductRelevance(dynamic footprint, Product product) {
    double score = 0.0;
    
    // Vérifier les différentes catégories d'empreinte carbone
    
    // Transport
    if (footprint.transportScore > 400) {
      if (_containsKeywords(product, ['vélo', 'transport', 'mobilité'])) {
        score += 2.0;
      }
    }
    
    // Alimentation
    if (footprint.foodScore > 350) {
      if (_containsKeywords(product, ['bio', 'local', 'végétal', 'vrac'])) {
        score += 2.0;
      }
    }
    
    // Énergie
    if (footprint.energyScore > 300) {
      if (_containsKeywords(product, ['énergie', 'solaire', 'LED', 'économie'])) {
        score += 2.0;
      }
    }
    
    // Consommation
    if (footprint.consumptionScore > 250) {
      if (_containsKeywords(product, ['durable', 'réparable', 'seconde main', 'recyclé'])) {
        score += 2.0;
      }
    }
    
    // Numérique
    if (footprint.digitalScore > 200) {
      if (_containsKeywords(product, ['reconditionné', 'réparation', 'durable'])) {
        score += 2.0;
      }
    }
    
    return score;
  }
  
  /// Vérifie si un produit contient certains mots-clés dans son nom ou sa description
  bool _containsKeywords(Product product, List<String> keywords) {
    final text = (product.name + ' ' + product.description).toLowerCase();
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }
  
  /// Vérifie si un produit contient au moins un des mots-clés
  bool _containsAnyKeyword(Product product, List<String> keywords) {
    final text = (product.name + ' ' + product.description).toLowerCase();
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }
  
  /// Extrait les mots-clés d'un texte
  List<String> _extractKeywords(String text) {
    // Liste de mots à ignorer (articles, prépositions, etc.)
    final stopWords = ['le', 'la', 'les', 'un', 'une', 'des', 'et', 'ou', 'à', 'de', 'du', 'pour', 'par', 'en', 'dans'];
    
    // Convertir en minuscules et diviser en mots
    final words = text.toLowerCase().split(RegExp(r'[^\w\s]+'))
      .where((word) => word.trim().isNotEmpty)
      .where((word) => !stopWords.contains(word))
      .toList();
    
    return words;
  }
  
  /// Récupère les produits recommandés pour un objectif spécifique
  Future<List<Product>> getProductsForGoal(EcoGoal goal) async {
    try {
      // Récupérer tous les produits
      final allProducts = await _productController.getAllProducts();
      
      // Calculer le score de pertinence pour chaque produit
      final scoredProducts = allProducts.map((product) {
        final relevanceScore = _calculateGoalProductRelevance(goal, product);
        return {
          'product': product,
          'score': relevanceScore,
        };
      }).toList();
      
      // Filtrer les produits avec un score minimum
      final filteredProducts = scoredProducts
          .where((item) => (item['score'] as double) > 1.0)
          .toList();
      
      // Trier les produits par score de pertinence (décroissant)
      filteredProducts.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      
      // Prendre les 5 produits les plus pertinents
      return filteredProducts
          .take(5)
          .map((item) => item['product'] as Product)
          .toList();
    } catch (e) {
      print('ProductRecommendationService: Erreur lors de la récupération des produits pour un objectif: $e');
      return [];
    }
  }
  
  /// Récupère les produits recommandés pour une catégorie d'empreinte carbone
  Future<List<Product>> getProductsForCarbonCategory(String category, double score) async {
    try {
      // Récupérer tous les produits
      final allProducts = await _productController.getAllProducts();
      
      // Mots-clés par catégorie
      final categoryKeywords = {
        'transport': ['vélo', 'transport', 'mobilité', 'covoiturage'],
        'food': ['bio', 'local', 'végétal', 'vrac', 'saison'],
        'energy': ['énergie', 'solaire', 'LED', 'économie', 'isolation'],
        'consumption': ['durable', 'réparable', 'seconde main', 'recyclé'],
        'digital': ['reconditionné', 'réparation', 'durable', 'économe'],
      };
      
      // Vérifier si la catégorie existe
      if (!categoryKeywords.containsKey(category)) {
        return [];
      }
      
      // Filtrer les produits contenant les mots-clés de la catégorie
      final keywords = categoryKeywords[category]!;
      final relevantProducts = allProducts
          .where((product) => _containsKeywords(product, keywords))
          .toList();
      
      // Trier les produits (par défaut, on peut ajouter d'autres critères)
      relevantProducts.sort((a, b) => a.name.compareTo(b.name));
      
      // Limiter à 5 produits
      return relevantProducts.take(5).toList();
    } catch (e) {
      print('ProductRecommendationService: Erreur lors de la récupération des produits pour une catégorie: $e');
      return [];
    }
  }
  
  /// Invalide le cache des recommandations
  void invalidateCache() {
    _recommendationCache.clear();
    _lastCacheUpdate = DateTime.now().subtract(const Duration(days: 1));
  }
}
