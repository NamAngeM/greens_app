import '../models/article_model.dart';
import '../../user_profile/models/environmental_profile.dart';
import '../../product_scanner/models/product.dart';

class ArticleRecommendationService {
  // Singleton pattern
  static final ArticleRecommendationService _instance = ArticleRecommendationService._internal();
  
  factory ArticleRecommendationService() {
    return _instance;
  }
  
  ArticleRecommendationService._internal();
  
  // Liste d'articles disponibles (en pratique, cette liste serait chargée depuis une API ou une base de données)
  List<Article> _availableArticles = Article.getDemoArticles();
  
  // Historique des articles consultés par l'utilisateur
  final Set<String> _readArticleIds = {};
  
  // Liste des produits récemment scannés
  final List<Product> _recentlyScannedProducts = [];
  
  // Ajouter un article à l'historique de lecture
  void markArticleAsRead(String articleId) {
    _readArticleIds.add(articleId);
  }
  
  // Vérifier si un article a déjà été lu
  bool isArticleRead(String articleId) {
    return _readArticleIds.contains(articleId);
  }
  
  // Ajouter un produit scanné à l'historique récent
  void addScannedProduct(Product product) {
    // Ajouter le produit au début de la liste
    _recentlyScannedProducts.insert(0, product);
    
    // Limiter la liste à 10 produits récents
    if (_recentlyScannedProducts.length > 10) {
      _recentlyScannedProducts.removeLast();
    }
  }
  
  // Mettre à jour la liste d'articles disponibles (pour les rafraîchissements depuis une API)
  void updateAvailableArticles(List<Article> articles) {
    _availableArticles = articles;
  }
  
  // Recommander des articles basés sur un produit spécifique
  List<Article> getArticlesForProduct(Product product) {
    // Extraire les catégories du produit
    final String category = product.category.toLowerCase();
    final List<String> keywords = [category];
    
    // Ajouter des mots-clés basés sur les attributs du produit
    if (product.environmentalImpact.containsKey('transportDistance') && 
        (product.environmentalImpact['transportDistance'] as double) > 500) {
      keywords.add('transport');
    }
    
    if (product.environmentalImpact.containsKey('packagingRecyclability') && 
        (product.environmentalImpact['packagingRecyclability'] as double) < 50) {
      keywords.add('emballage');
      keywords.add('recyclage');
    }
    
    if (product.environmentalImpact.containsKey('waterUsage') && 
        (product.environmentalImpact['waterUsage'] as double) > 100) {
      keywords.add('eau');
    }
    
    if (product.environmentalImpact.containsKey('digitalEmissions')) {
      keywords.add('numérique');
    }
    
    if (product.environmentalImpact.containsKey('soundLevel')) {
      keywords.add('pollution sonore');
    }
    
    return _recommendArticlesByKeywords(keywords);
  }
  
  // Recommander des articles basés sur le profil environnemental de l'utilisateur
  List<Article> getArticlesForUserProfile(EnvironmentalProfile profile) {
    final List<String> keywords = [];
    
    // Analyse du profil de transport
    final transportHabits = profile.transportHabits;
    if (transportHabits.carKmPerWeek > 100) {
      keywords.add('transport');
      keywords.add('mobilité');
    }
    
    if (transportHabits.flightsPerYear > 2) {
      keywords.add('avion');
      keywords.add('voyage');
    }
    
    // Analyse du profil alimentaire
    final dietProfile = profile.dietProfile;
    keywords.add(dietProfile.dietType.toString().split('.').last.toLowerCase());
    if (dietProfile.meatKgPerWeek > 1) {
      keywords.add('viande');
    }
    
    if (!dietProfile.localProducePreference) {
      keywords.add('local');
    }
    
    // Analyse du profil numérique
    final digitalProfile = profile.digitalProfile;
    if (digitalProfile.streamingHoursPerDay > 2) {
      keywords.add('numérique');
      keywords.add('streaming');
    }
    
    if (digitalProfile.smartphonesOwnedLast5Years > 2) {
      keywords.add('électronique');
      keywords.add('technologie');
    }
    
    // Analyse du profil sonore
    if (digitalProfile.headphonesUseHoursPerDay > 3 || 
        digitalProfile.averageVolumeLevel > 70 ||
        digitalProfile.exposureToLoudEnvironmentsHoursPerWeek > 5) {
      keywords.add('pollution sonore');
      keywords.add('santé auditive');
    }
    
    return _recommendArticlesByKeywords(keywords);
  }
  
  // Recommander des articles tendance ou populaires
  List<Article> getTrendingArticles() {
    // Dans une vraie application, cela serait basé sur des métriques d'engagement
    // Pour cette démo, on retourne simplement les articles les plus récents
    final trendingArticles = List<Article>.from(_availableArticles);
    trendingArticles.sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return trendingArticles.take(3).toList();
  }
  
  // Recommander des articles non lus
  List<Article> getUnreadArticles() {
    return _availableArticles
        .where((article) => !_readArticleIds.contains(article.id))
        .toList();
  }
  
  // Méthode interne pour recommander des articles basés sur des mots-clés
  List<Article> _recommendArticlesByKeywords(List<String> keywords) {
    // Créer un score pour chaque article basé sur la correspondance avec les mots-clés
    final Map<Article, int> articleScores = {};
    
    for (var article in _availableArticles) {
      int score = 0;
      
      // Vérifier si les mots-clés correspondent aux tags ou aux catégories de l'article
      for (var keyword in keywords) {
        // Correspondance avec les tags
        for (var tag in article.tags) {
          if (tag.toLowerCase().contains(keyword.toLowerCase()) ||
              keyword.toLowerCase().contains(tag.toLowerCase())) {
            score += 2;
          }
        }
        
        // Correspondance avec les catégories de produits liées
        for (var category in article.relatedProductCategories) {
          if (category.toLowerCase().contains(keyword.toLowerCase()) ||
              keyword.toLowerCase().contains(category.toLowerCase())) {
            score += 3;
          }
        }
        
        // Correspondance avec les sujets environnementaux
        for (var topic in article.relatedEnvironmentalTopics) {
          if (topic.toLowerCase().contains(keyword.toLowerCase()) ||
              keyword.toLowerCase().contains(topic.toLowerCase())) {
            score += 4;
          }
        }
        
        // Vérifier le titre et le résumé
        if (article.title.toLowerCase().contains(keyword.toLowerCase())) {
          score += 5;
        }
        
        if (article.summary.toLowerCase().contains(keyword.toLowerCase())) {
          score += 3;
        }
      }
      
      // Bonus pour les articles récents
      final daysAgo = DateTime.now().difference(article.publishDate).inDays;
      if (daysAgo < 30) {
        score += (30 - daysAgo) ~/ 3; // Plus l'article est récent, plus le bonus est élevé
      }
      
      // Pénalité pour les articles déjà lus
      if (_readArticleIds.contains(article.id)) {
        score -= 10;
      }
      
      // Ajouter le score si l'article est pertinent
      if (score > 0) {
        articleScores[article] = score;
      }
    }
    
    // Trier les articles par score décroissant
    final sortedArticles = articleScores.keys.toList()
      ..sort((a, b) => articleScores[b]! - articleScores[a]!);
    
    // Retourner les articles les plus pertinents (limités à 5)
    return sortedArticles.take(5).toList();
  }
} 