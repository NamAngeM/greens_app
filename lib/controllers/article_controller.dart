import 'package:flutter/material.dart';
import 'package:greens_app/models/article_model.dart';
import 'package:greens_app/services/article_service.dart';

class ArticleController extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _allArticles = [];
  List<ArticleModel> _filteredArticles = [];
  List<ArticleModel> _recommendedArticles = [];
  ArticleModel? _selectedArticle;
  bool _isLoading = false;
  String _error = '';

  List<ArticleModel> get allArticles => _allArticles;
  List<ArticleModel> get filteredArticles => _filteredArticles;
  List<ArticleModel> get recommendedArticles => _recommendedArticles;
  List<ArticleModel> get articles => _allArticles;
  ArticleModel? get selectedArticle => _selectedArticle;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Récupérer tous les articles
  Future<void> getAllArticles() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allArticles = await _articleService.getAllArticles();
      _filteredArticles = _allArticles;
    } catch (e) {
      _error = 'Erreur lors de la récupération des articles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Alias pour getAllArticles pour compatibilité
  Future<void> fetchArticles() async {
    await getAllArticles();
  }

  // Récupérer les articles par catégorie
  Future<void> getArticlesByCategory(String category) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _filteredArticles = await _articleService.getArticlesByCategory(category);
    } catch (e) {
      _error = 'Erreur lors de la récupération des articles par catégorie: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer un article par son ID
  Future<void> getArticleById(String articleId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _selectedArticle = await _articleService.getArticleById(articleId);
    } catch (e) {
      _error = 'Erreur lors de la récupération de l\'article: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rechercher des articles
  Future<void> searchArticles(String query) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = await _articleService.searchArticles(query);
      }
    } catch (e) {
      _error = 'Erreur lors de la recherche d\'articles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer les articles les plus récents
  Future<void> getRecentArticles({int limit = 5}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _filteredArticles = await _articleService.getRecentArticles(limit: limit);
    } catch (e) {
      _error = 'Erreur lors de la récupération des articles récents: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer les articles recommandés en fonction des intérêts de l'utilisateur
  Future<void> getRecommendedArticles({int limit = 5}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _recommendedArticles = await _articleService.getRecommendedArticles(
        limit: limit,
      );
    } catch (e) {
      _error = 'Erreur lors de la récupération des articles recommandés: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
