import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/article_model.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer tous les articles
  Future<List<ArticleModel>> getAllArticles() async {
    try {
      try {
        final snapshot = await _firestore
            .collection('articles')
            .orderBy('publishDate', descending: true)
            .get();
        
        final articles = snapshot.docs
            .map((doc) => ArticleModel.fromJson({
              'id': doc.id,
              ...doc.data() ?? {},
            }))
            .toList();
            
        // Si la liste est vide, retourner des articles de démonstration
        if (articles.isEmpty) {
          return _getDemoArticles();
        }
        
        return articles;
      } catch (firestoreError) {
        debugPrint('Erreur Firestore lors de la récupération des articles: $firestoreError');
        // En cas d'erreur Firestore, retourner des articles de démonstration
        return _getDemoArticles();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles: $e');
      return _getDemoArticles();
    }
  }

  // Méthode pour récupérer les articles par catégorie
  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    try {
      try {
        final snapshot = await _firestore
            .collection('articles')
            .where('categories', arrayContains: category)
            .orderBy('publishDate', descending: true)
            .get();
        
        final articles = snapshot.docs
            .map((doc) => ArticleModel.fromJson({
              'id': doc.id,
              ...doc.data() ?? {},
            }))
            .toList();
            
        // Si la liste est vide, filtrer les articles de démonstration par catégorie
        if (articles.isEmpty) {
          return _getDemoArticles().where((article) => 
            article.categories.contains(category)).toList();
        }
        
        return articles;
      } catch (firestoreError) {
        debugPrint('Erreur Firestore lors de la récupération des articles par catégorie: $firestoreError');
        // En cas d'erreur Firestore, filtrer les articles de démonstration par catégorie
        return _getDemoArticles().where((article) => 
            article.categories.contains(category)).toList();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles par catégorie: $e');
      return _getDemoArticles().where((article) => 
          article.categories.contains(category)).toList();
    }
  }

  // Méthode pour récupérer un article par son ID
  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      try {
        final doc = await _firestore
            .collection('articles')
            .doc(articleId)
            .get();
        
        if (doc.exists) {
          return ArticleModel.fromJson({
            'id': doc.id,
            ...doc.data() ?? {},
          });
        }
        
        // Si l'article n'existe pas, chercher dans les articles de démonstration
        final demoArticle = _getDemoArticles().firstWhere(
          (article) => article.id == articleId,
          orElse: () => _getDemoArticles().first,
        );
        
        return demoArticle;
      } catch (firestoreError) {
        debugPrint('Erreur Firestore lors de la récupération de l\'article: $firestoreError');
        // En cas d'erreur Firestore, retourner un article de démonstration
        return _getDemoArticles().firstWhere(
          (article) => article.id == articleId,
          orElse: () => _getDemoArticles().first,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'article: $e');
      return _getDemoArticles().first;
    }
  }

  // Méthode pour rechercher des articles
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      try {
        // Convertir la requête en minuscules pour une recherche insensible à la casse
        final lowercaseQuery = query.toLowerCase();
        
        // Récupérer tous les articles (dans une application réelle, il faudrait utiliser une solution de recherche plus efficace)
        final snapshot = await _firestore
            .collection('articles')
            .orderBy('publishDate', descending: true)
            .get();
        
        // Filtrer les articles qui correspondent à la requête
        final articles = snapshot.docs
            .map((doc) => ArticleModel.fromJson({
              'id': doc.id,
              ...doc.data() ?? {},
            }))
            .where((article) => 
                article.title.toLowerCase().contains(lowercaseQuery) ||
                article.content.toLowerCase().contains(lowercaseQuery) ||
                (article.authorName != null && article.authorName!.toLowerCase().contains(lowercaseQuery)))
            .toList();
            
        // Si aucun résultat, rechercher dans les articles de démonstration
        if (articles.isEmpty) {
          return _getDemoArticles().where((article) => 
              article.title.toLowerCase().contains(lowercaseQuery) ||
              article.content.toLowerCase().contains(lowercaseQuery) ||
              (article.authorName != null && article.authorName!.toLowerCase().contains(lowercaseQuery)))
              .toList();
        }
        
        return articles;
      } catch (firestoreError) {
        debugPrint('Erreur Firestore lors de la recherche d\'articles: $firestoreError');
        // En cas d'erreur Firestore, rechercher dans les articles de démonstration
        final lowercaseQuery = query.toLowerCase();
        return _getDemoArticles().where((article) => 
            article.title.toLowerCase().contains(lowercaseQuery) ||
            article.content.toLowerCase().contains(lowercaseQuery) ||
            (article.authorName != null && article.authorName!.toLowerCase().contains(lowercaseQuery)))
            .toList();
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'articles: $e');
      return _getDemoArticles();
    }
  }

  // Méthode pour récupérer les articles les plus récents
  Future<List<ArticleModel>> getRecentArticles({int limit = 5}) async {
    try {
      try {
        final snapshot = await _firestore
            .collection('articles')
            .orderBy('publishDate', descending: true)
            .limit(limit)
            .get();
        
        final articles = snapshot.docs
            .map((doc) => ArticleModel.fromJson({
              'id': doc.id,
              ...doc.data() ?? {},
            }))
            .toList();
            
        // Si la liste est vide, retourner des articles de démonstration limités
        if (articles.isEmpty) {
          return _getDemoArticles().take(limit).toList();
        }
        
        return articles;
      } catch (firestoreError) {
        debugPrint('Erreur Firestore lors de la récupération des articles récents: $firestoreError');
        // En cas d'erreur Firestore, retourner des articles de démonstration limités
        return _getDemoArticles().take(limit).toList();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles récents: $e');
      return _getDemoArticles().take(limit).toList();
    }
  }

  // Méthode pour récupérer les articles recommandés pour l'utilisateur
  Future<List<ArticleModel>> getRecommendedArticles({int limit = 5}) async {
    try {
      try {
        final snapshot = await _firestore
            .collection('articles')
            .where('isRecommended', isEqualTo: true)
            .orderBy('publishDate', descending: true)
            .limit(limit)
            .get();

        if (snapshot.docs.isEmpty) {
          return _getDemoRecommendedArticles();
        }

        return snapshot.docs
            .map((doc) => ArticleModel.fromJson({
                  'id': doc.id,
                  ...doc.data() ?? {},
                }))
            .toList();
      } catch (firestoreError) {
        debugPrint('Erreur Firestore lors de la récupération des articles recommandés: $firestoreError');
        return _getDemoRecommendedArticles();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles recommandés: $e');
      return _getDemoRecommendedArticles();
    }
  }

  // Méthode pour récupérer des articles recommandés de démonstration
  List<ArticleModel> _getDemoRecommendedArticles() {
    return _getDemoArticles().where((article) => 
      article.categories.contains('Lifestyle') || 
      article.categories.contains('Climate')).toList();
  }

  // Méthode pour obtenir des articles de démonstration lorsque Firestore n'est pas disponible
  List<ArticleModel> _getDemoArticles() {
    return [
      ArticleModel(
        id: 'demo1',
        title: '5 easy steps to go green today',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        imageUrl: 'assets/images/article1.jpg',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        readTimeMinutes: 5,
        authorName: 'Eco Expert',
        categories: ['Lifestyle', 'Eco-friendly'],
      ),
      ArticleModel(
        id: 'demo2',
        title: 'Eco hacks for daily life',
        content: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        imageUrl: 'assets/images/article2.jpg',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        readTimeMinutes: 3,
        authorName: 'Green Guru',
        categories: ['Tips', 'Daily Life'],
      ),
      ArticleModel(
        id: 'demo3',
        title: 'How to reduce your carbon footprint',
        content: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
        imageUrl: 'assets/images/article3.jpg',
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        readTimeMinutes: 4,
        authorName: 'Climate Warrior',
        categories: ['Climate', 'Action'],
      ),
      ArticleModel(
        id: 'demo4',
        title: 'Sustainable brands to support',
        content: 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        imageUrl: 'assets/images/article4.jpg',
        publishDate: DateTime.now().subtract(const Duration(days: 10)),
        readTimeMinutes: 6,
        authorName: 'Sustainable Shopper',
        categories: ['Shopping', 'Brands'],
      ),
    ];
  }
}