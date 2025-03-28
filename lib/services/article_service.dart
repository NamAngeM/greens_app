import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/article_model.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer tous les articles
  Future<List<ArticleModel>> getAllArticles() async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ArticleModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles: $e');
      return [];
    }
  }

  // Méthode pour récupérer les articles par catégorie
  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('categories', arrayContains: category)
          .orderBy('publishDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ArticleModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles par catégorie: $e');
      return [];
    }
  }

  // Méthode pour récupérer un article par son ID
  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      final doc = await _firestore
          .collection('articles')
          .doc(articleId)
          .get();
      
      if (doc.exists) {
        return ArticleModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'article: $e');
      return null;
    }
  }

  // Méthode pour rechercher des articles
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      // Convertir la requête en minuscules pour une recherche insensible à la casse
      final lowercaseQuery = query.toLowerCase();
      
      // Récupérer tous les articles (dans une application réelle, il faudrait utiliser une solution de recherche plus efficace)
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishDate', descending: true)
          .get();
      
      // Filtrer les articles qui correspondent à la requête
      return snapshot.docs
          .map((doc) => ArticleModel.fromJson(doc.data()))
          .where((article) => 
              article.title.toLowerCase().contains(lowercaseQuery) ||
              article.content.toLowerCase().contains(lowercaseQuery) ||
              (article.authorName != null && article.authorName!.toLowerCase().contains(lowercaseQuery)))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'articles: $e');
      return [];
    }
  }

  // Méthode pour récupérer les articles les plus récents
  Future<List<ArticleModel>> getRecentArticles({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishDate', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => ArticleModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles récents: $e');
      return [];
    }
  }

  // Méthode pour récupérer les articles recommandés en fonction des intérêts de l'utilisateur
  Future<List<ArticleModel>> getRecommendedArticles(List<String> userInterests, {int limit = 5}) async {
    try {
      if (userInterests.isEmpty) {
        return getRecentArticles(limit: limit);
      }
      
      // Récupérer les articles qui correspondent aux intérêts de l'utilisateur
      final List<ArticleModel> recommendedArticles = [];
      
      for (final interest in userInterests) {
        final snapshot = await _firestore
            .collection('articles')
            .where('categories', arrayContains: interest)
            .orderBy('publishDate', descending: true)
            .limit(limit)
            .get();
        
        final articles = snapshot.docs
            .map((doc) => ArticleModel.fromJson(doc.data()))
            .toList();
        
        recommendedArticles.addAll(articles);
      }
      
      // Supprimer les doublons et limiter le nombre d'articles
      final uniqueArticles = <String, ArticleModel>{};
      for (final article in recommendedArticles) {
        uniqueArticles[article.id] = article;
      }
      
      return uniqueArticles.values.toList()
        ..sort((a, b) => b.publishDate.compareTo(a.publishDate))
        ..take(limit).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles recommandés: $e');
      return [];
    }
  }
}
