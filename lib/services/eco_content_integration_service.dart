import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/unified_product_model.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/article_model.dart';
import 'package:greens_app/models/challenge_enums.dart';

/// Service pour intégrer et connecter les différents types de contenu écologique
/// (produits, défis, objectifs, articles)
class EcoContentIntegrationService {
  final FirebaseFirestore _firestore;
  
  // Cache local pour optimiser les performances
  final Map<String, List<dynamic>> _recommendationsCache = {};
  final Map<String, List<dynamic>> _relatedContentCache = {};
  
  // Singleton
  static final EcoContentIntegrationService _instance = 
      EcoContentIntegrationService._internal(FirebaseFirestore.instance);
  
  factory EcoContentIntegrationService() {
    return _instance;
  }
  
  EcoContentIntegrationService._internal(this._firestore);

  /// Obtenir des produits recommandés basés sur un défi écologique
  Future<List<UnifiedProduct>> getProductsForChallenge(EcoChallenge challenge) async {
    final cacheKey = 'products_for_challenge_${challenge.id}';
    
    // Vérifier si les données sont en cache
    if (_recommendationsCache.containsKey(cacheKey)) {
      return _recommendationsCache[cacheKey]! as List<UnifiedProduct>;
    }
    
    try {
      // Récupérer les produits liés à cette catégorie de défi
      final querySnapshot = await _firestore
          .collection('products')
          .where('primary_challenge_category', isEqualTo: challenge.category.toString())
          .limit(5)
          .get();
      
      final products = querySnapshot.docs
          .map((doc) => UnifiedProduct.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Si pas assez de produits trouvés par la catégorie directe, 
      // rechercher par mots-clés liés au défi
      if (products.length < 3) {
        final keywordsSnapshot = await _firestore
            .collection('challenge_keywords')
            .doc(challenge.category.toString())
            .get();
        
        if (keywordsSnapshot.exists && keywordsSnapshot.data() != null) {
          final keywords = List<String>.from(keywordsSnapshot.data()!['keywords'] ?? []);
          
          // Pour chaque mot-clé, rechercher des produits
          for (final keyword in keywords) {
            if (products.length >= 5) break; // Limiter à 5 produits
            
            final keywordQuery = await _firestore
                .collection('products')
                .where('eco_tags', arrayContains: keyword)
                .limit(3)
                .get();
            
            // Ajouter les produits trouvés sans doublons
            for (final doc in keywordQuery.docs) {
              final product = UnifiedProduct.fromJson({...doc.data(), 'id': doc.id});
              if (!products.any((p) => p.id == product.id)) {
                products.add(product);
              }
              
              if (products.length >= 5) break;
            }
          }
        }
      }
      
      // Mettre en cache
      _recommendationsCache[cacheKey] = products;
      
      return products;
    } catch (e) {
      print('Erreur lors de la récupération des produits pour un défi: $e');
      return [];
    }
  }

  /// Obtenir des défis recommandés basés sur un objectif écologique
  Future<List<EcoChallenge>> getChallengesForGoal(EcoGoal goal) async {
    final cacheKey = 'challenges_for_goal_${goal.id}';
    
    // Vérifier si les données sont en cache
    if (_recommendationsCache.containsKey(cacheKey)) {
      return _recommendationsCache[cacheKey]! as List<EcoChallenge>;
    }
    
    try {
      // Mapper le type d'objectif à une catégorie de défi
      ChallengeCategory? matchingCategory;
      
      switch (goal.type) {
        case GoalType.waste:
          matchingCategory = ChallengeCategory.waste;
          break;
        case GoalType.energy:
          matchingCategory = ChallengeCategory.energy;
          break;
        case GoalType.water:
          matchingCategory = ChallengeCategory.water;
          break;
        case GoalType.transport:
          matchingCategory = ChallengeCategory.transport;
          break;
        case GoalType.food:
          matchingCategory = ChallengeCategory.food;
          break;
        case GoalType.community:
          matchingCategory = ChallengeCategory.community;
          break;
        default:
          matchingCategory = ChallengeCategory.nature;
      }
      
      // Récupérer les défis de cette catégorie
      final querySnapshot = await _firestore
          .collection('eco_challenges')
          .where('category', isEqualTo: matchingCategory.toString().split('.').last)
          .limit(5)
          .get();
      
      final challenges = querySnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Mettre en cache
      _recommendationsCache[cacheKey] = challenges;
      
      return challenges;
    } catch (e) {
      print('Erreur lors de la récupération des défis pour un objectif: $e');
      return [];
    }
  }

  /// Obtenir des articles recommandés basés sur un défi écologique
  Future<List<ArticleModel>> getArticlesForChallenge(EcoChallenge challenge) async {
    final cacheKey = 'articles_for_challenge_${challenge.id}';
    
    // Vérifier si les données sont en cache
    if (_recommendationsCache.containsKey(cacheKey)) {
      return _recommendationsCache[cacheKey]! as List<ArticleModel>;
    }
    
    try {
      // Récupérer les articles liés à cette catégorie de défi
      final querySnapshot = await _firestore
          .collection('articles')
          .where('categories', arrayContains: challenge.category.toString().split('.').last)
          .limit(3)
          .get();
      
      final articles = querySnapshot.docs
          .map((doc) => ArticleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Mettre en cache
      _recommendationsCache[cacheKey] = articles;
      
      return articles;
    } catch (e) {
      print('Erreur lors de la récupération des articles pour un défi: $e');
      return [];
    }
  }

  /// Obtenir des articles basés sur un produit scanné
  Future<List<ArticleModel>> getArticlesForProduct(UnifiedProduct product) async {
    final cacheKey = 'articles_for_product_${product.id}';
    
    // Vérifier si les données sont en cache
    if (_relatedContentCache.containsKey(cacheKey)) {
      return _relatedContentCache[cacheKey]! as List<ArticleModel>;
    }
    
    try {
      // Utiliser les catégories du produit pour trouver des articles pertinents
      final categories = product.categories;
      
      if (categories.isEmpty) {
        return [];
      }
      
      // Récupérer les articles qui correspondant à au moins une catégorie
      final querySnapshot = await _firestore
          .collection('articles')
          .where('categories', arrayContainsAny: categories)
          .limit(3)
          .get();
      
      final articles = querySnapshot.docs
          .map((doc) => ArticleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Si nous avons des tags écologiques, chercher aussi par tags
      if (product.ecoTags.isNotEmpty) {
        final tagQuery = await _firestore
            .collection('articles')
            .where('tags', arrayContainsAny: product.ecoTags)
            .limit(3)
            .get();
        
        // Ajouter les articles sans doublons
        for (final doc in tagQuery.docs) {
          final article = ArticleModel.fromJson({...doc.data(), 'id': doc.id});
          if (!articles.any((a) => a.id == article.id)) {
            articles.add(article);
          }
          
          if (articles.length >= 5) break;
        }
      }
      
      // Mettre en cache
      _relatedContentCache[cacheKey] = articles;
      
      return articles;
    } catch (e) {
      print('Erreur lors de la récupération des articles pour un produit: $e');
      return [];
    }
  }

  /// Créer un lien entre un produit et un défi
  Future<bool> linkProductToChallenge(String productId, String challengeId) async {
    try {
      // Créer ou mettre à jour la relation dans Firestore
      await _firestore
          .collection('content_relationships')
          .doc('${productId}_${challengeId}')
          .set({
            'productId': productId,
            'challengeId': challengeId,
            'type': 'product_challenge',
            'createdAt': FieldValue.serverTimestamp(),
          });
      
      // Mettre à jour les métadonnées du produit
      await _firestore
          .collection('products')
          .doc(productId)
          .update({
            'relatedChallenges': FieldValue.arrayUnion([challengeId]),
          });
      
      return true;
    } catch (e) {
      print('Erreur lors de la création du lien produit-défi: $e');
      return false;
    }
  }

  /// Créer un lien entre un article et un produit
  Future<bool> linkArticleToProduct(String articleId, String productId) async {
    try {
      // Créer ou mettre à jour la relation dans Firestore
      await _firestore
          .collection('content_relationships')
          .doc('${articleId}_${productId}')
          .set({
            'articleId': articleId,
            'productId': productId,
            'type': 'article_product',
            'createdAt': FieldValue.serverTimestamp(),
          });
      
      // Mettre à jour les métadonnées de l'article
      await _firestore
          .collection('articles')
          .doc(articleId)
          .update({
            'relatedProducts': FieldValue.arrayUnion([productId]),
          });
      
      // Mettre à jour les métadonnées du produit
      await _firestore
          .collection('products')
          .doc(productId)
          .update({
            'relatedArticles': FieldValue.arrayUnion([articleId]),
          });
      
      return true;
    } catch (e) {
      print('Erreur lors de la création du lien article-produit: $e');
      return false;
    }
  }

  /// Récupérer les défis liés à un article
  Future<List<EcoChallenge>> getChallengesForArticle(String articleId) async {
    final cacheKey = 'challenges_for_article_$articleId';
    
    // Vérifier si les données sont en cache
    if (_relatedContentCache.containsKey(cacheKey)) {
      return _relatedContentCache[cacheKey]! as List<EcoChallenge>;
    }
    
    try {
      // Récupérer d'abord les informations de l'article
      final articleDoc = await _firestore
          .collection('articles')
          .doc(articleId)
          .get();
      
      if (!articleDoc.exists || articleDoc.data() == null) {
        return [];
      }
      
      final articleData = articleDoc.data()!;
      final categories = List<String>.from(articleData['categories'] ?? []);
      
      if (categories.isEmpty) {
        return [];
      }
      
      // Convertir les catégories d'article en catégories de défi
      final challengeCategories = categories.map((category) {
        switch (category.toLowerCase()) {
          case 'déchets':
          case 'zéro-déchet':
            return 'waste';
          case 'énergie':
            return 'energy';
          case 'eau':
            return 'water';
          case 'transport':
          case 'mobilité':
            return 'transport';
          case 'alimentation':
          case 'nourriture':
            return 'food';
          case 'communauté':
            return 'community';
          case 'nature':
          case 'biodiversité':
            return 'nature';
          default:
            return 'nature';
        }
      }).toList();
      
      // Récupérer les défis correspondant à ces catégories
      final querySnapshot = await _firestore
          .collection('eco_challenges')
          .where('category', whereIn: challengeCategories)
          .limit(5)
          .get();
      
      final challenges = querySnapshot.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Mettre en cache
      _relatedContentCache[cacheKey] = challenges;
      
      return challenges;
    } catch (e) {
      print('Erreur lors de la récupération des défis pour un article: $e');
      return [];
    }
  }

  /// Récupérer du contenu en vedette pour le tableau de bord utilisateur
  Future<Map<String, dynamic>> getFeaturedContentForUser(String userId) async {
    try {
      // Structure pour stocker les résultats
      final featuredContent = {
        'products': <UnifiedProduct>[],
        'challenges': <EcoChallenge>[],
        'articles': <ArticleModel>[],
      };
      
      // Récupérer le profil utilisateur pour personnaliser les recommandations
      final userProfileDoc = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();
      
      List<String> userInterests = [];
      
      if (userProfileDoc.exists && userProfileDoc.data() != null) {
        userInterests = List<String>.from(userProfileDoc.data()!['interests'] ?? []);
      }
      
      // Récupérer les produits en vedette
      final productsQuery = userInterests.isNotEmpty
          ? await _firestore
              .collection('products')
              .where('categories', arrayContainsAny: userInterests)
              .where('is_featured', isEqualTo: true)
              .limit(3)
              .get()
          : await _firestore
              .collection('products')
              .where('is_featured', isEqualTo: true)
              .limit(3)
              .get();
      
      featuredContent['products'] = productsQuery.docs
          .map((doc) => UnifiedProduct.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Récupérer les défis en vedette
      final challengesQuery = userInterests.isNotEmpty
          ? await _firestore
              .collection('eco_challenges')
              .where('tags', arrayContainsAny: userInterests)
              .limit(3)
              .get()
          : await _firestore
              .collection('eco_challenges')
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();
      
      featuredContent['challenges'] = challengesQuery.docs
          .map((doc) => EcoChallenge.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Récupérer les articles en vedette
      final articlesQuery = userInterests.isNotEmpty
          ? await _firestore
              .collection('articles')
              .where('categories', arrayContainsAny: userInterests)
              .where('featured', isEqualTo: true)
              .limit(3)
              .get()
          : await _firestore
              .collection('articles')
              .where('featured', isEqualTo: true)
              .limit(3)
              .get();
      
      featuredContent['articles'] = articlesQuery.docs
          .map((doc) => ArticleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      return featuredContent;
    } catch (e) {
      print('Erreur lors de la récupération du contenu en vedette: $e');
      return {
        'products': <UnifiedProduct>[],
        'challenges': <EcoChallenge>[],
        'articles': <ArticleModel>[],
      };
    }
  }
} 