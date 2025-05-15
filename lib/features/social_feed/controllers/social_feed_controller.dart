import 'package:flutter/material.dart';

enum PostCategory {
  all,
  tips,
  achievements,
  questions,
  products,
  events,
}

enum SortOrder {
  recent,
  popular,
  trending,
  newest,
  mostLiked,
  mostCommented,
}

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorAvatar;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final List<String> tags;
  final String? imageUrl;
  final PostCategory category;
  final bool isBookmarked;
  final bool isLiked;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorAvatar,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.tags,
    this.imageUrl,
    required this.category,
    this.isBookmarked = false,
    this.isLiked = false,
  });
}

class SocialFeedController extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  List<Post> _recommendedPosts = [];
  List<Post> _trendingPosts = [];
  List<Post> _userPosts = [];
  List<Post> _searchResults = [];
  
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';
  
  PostCategory _selectedCategory = PostCategory.all;
  SortOrder _sortOrder = SortOrder.recent;
  SortOrder _currentSortOrder = SortOrder.newest;

  List<Post> get posts => _filteredPosts;
  List<Post> get recommendedPosts => _recommendedPosts;
  List<Post> get trendingPosts => _trendingPosts;
  List<Post> get userPosts => _userPosts;
  List<Post> get searchResults => _searchResults;
  
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  
  PostCategory get selectedCategory => _selectedCategory;
  SortOrder get sortOrder => _sortOrder;
  SortOrder get currentSortOrder => _currentSortOrder;

  // Méthode pour charger les posts
  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simuler un délai réseau
      
      // Posts factices pour l'exemple
      _posts = [
        Post(
          id: '1',
          title: 'Astuce du jour : économiser l\'eau',
          content: 'Voici 5 astuces simples pour économiser l\'eau au quotidien...',
          author: 'Éco-Conseil',
          authorAvatar: 'assets/images/avatars/eco_conseil.png',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          likes: 45,
          comments: 12,
          tags: ['eau', 'économie', 'astuces'],
          imageUrl: 'assets/images/posts/water_saving.jpg',
          category: PostCategory.tips,
        ),
        Post(
          id: '2',
          title: 'Défi hebdo : Une semaine sans plastique',
          content: 'Rejoignez notre défi communautaire : une semaine sans plastique à usage unique...',
          author: 'Sophie Martin',
          authorAvatar: 'assets/images/avatars/sophie.png',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          likes: 89,
          comments: 32,
          tags: ['défi', 'plastique', 'zéro-déchet'],
          imageUrl: 'assets/images/posts/plastic_free.jpg',
          category: PostCategory.achievements,
        ),
        Post(
          id: '3',
          title: 'Nouvelle législation européenne sur l\'économie circulaire',
          content: 'L\'Union Européenne vient d\'adopter une nouvelle directive...',
          author: 'ActuVert',
          authorAvatar: 'assets/images/avatars/actu_vert.png',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          likes: 132,
          comments: 47,
          tags: ['europe', 'législation', 'économie circulaire'],
          imageUrl: 'assets/images/posts/eu_law.jpg',
          category: PostCategory.products,
        ),
      ];
      
      // Initialiser les différentes listes
      _recommendedPosts = List.from(_posts);
      _trendingPosts = List.from(_posts)..sort((a, b) => b.likes.compareTo(a.likes));
      _userPosts = [_posts[1]]; // Supposons que l'utilisateur a publié le 2ème post
      
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour filtrer les posts par catégorie
  void filterByCategory(PostCategory category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Méthode pour trier les posts
  void sortBy(SortOrder order) {
    _sortOrder = order;
    _currentSortOrder = order;
    _applyFilters();
    notifyListeners();
  }

  // Méthode pour appliquer les filtres
  void _applyFilters() {
    // D'abord on filtre par catégorie
    if (_selectedCategory == PostCategory.all) {
      _filteredPosts = List.from(_posts);
    } else {
      _filteredPosts = _posts.where((post) => post.category == _selectedCategory).toList();
    }
    
    // Ensuite on trie
    switch (_sortOrder) {
      case SortOrder.recent:
      case SortOrder.newest:
        _filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOrder.popular:
      case SortOrder.mostLiked:
        _filteredPosts.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case SortOrder.trending:
      case SortOrder.mostCommented:
        _filteredPosts.sort((a, b) => (b.likes + b.comments).compareTo(a.likes + a.comments));
        break;
    }
  }

  // Méthode pour aimer/ne plus aimer un post
  void toggleLike(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex >= 0) {
      final post = _posts[postIndex];
      _posts[postIndex] = Post(
        id: post.id,
        title: post.title,
        content: post.content,
        author: post.author,
        authorAvatar: post.authorAvatar,
        createdAt: post.createdAt,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        comments: post.comments,
        tags: post.tags,
        imageUrl: post.imageUrl,
        category: post.category,
        isBookmarked: post.isBookmarked,
        isLiked: !post.isLiked,
      );
      _applyFilters();
      notifyListeners();
    }
  }

  // Méthode pour marquer/démarquer un post
  void toggleBookmark(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex >= 0) {
      final post = _posts[postIndex];
      _posts[postIndex] = Post(
        id: post.id,
        title: post.title,
        content: post.content,
        author: post.author,
        authorAvatar: post.authorAvatar,
        createdAt: post.createdAt,
        likes: post.likes,
        comments: post.comments,
        tags: post.tags,
        imageUrl: post.imageUrl,
        category: post.category,
        isBookmarked: !post.isBookmarked,
        isLiked: post.isLiked,
      );
      _applyFilters();
      notifyListeners();
    }
  }

  // Méthode pour supprimer un post
  void deletePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    _applyFilters();
    notifyListeners();
  }

  // Méthode pour rechercher des posts
  void searchPosts(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    
    if (query.isEmpty) {
      _searchResults = [];
      _applyFilters();
    } else {
      _searchResults = _posts.where((post) =>
        post.title.toLowerCase().contains(query.toLowerCase()) ||
        post.content.toLowerCase().contains(query.toLowerCase()) ||
        post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
      
      // Si nous sommes en mode recherche, filtrer les posts affichés
      _filteredPosts = _searchResults;
    }
    
    notifyListeners();
  }
  
  // Méthode pour effacer la recherche
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    _applyFilters();
    notifyListeners();
  }
} 