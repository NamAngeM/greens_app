import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/article_model.dart';
import 'package:greens_app/models/challenge_model.dart';

class AdminService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _baseApiUrl = 'https://api.greensapp.com/api/v1'; // Remplacer par votre URL d'API réelle
  
  String? _apiToken;
  bool _isLoadingData = false;
  
  bool get isLoadingData => _isLoadingData;
  
  // Singleton pour assurer une seule instance du service
  AdminService._internal() {
    _loadApiToken();
  }
  
  static final AdminService _instance = AdminService._internal();
  
  factory AdminService() {
    return _instance;
  }
  
  Future<void> _loadApiToken() async {
    final prefs = await SharedPreferences.getInstance();
    _apiToken = prefs.getString('admin_api_token');
  }
  
  Future<void> saveApiToken(String token) async {
    _apiToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_api_token', token);
  }
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  
  Future<String> _getAuthToken() async {
    if (_apiToken == null) {
      await _loadApiToken();
    }
    return _apiToken ?? '';
  }
  
  // SECTION DES STATISTIQUES ET ANALYTICS
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    _isLoadingData = true;
    notifyListeners();
    
    try {
      // 1. Obtenir les statistiques d'utilisateurs depuis Firestore
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['isActive'] == true;
      }).length;
      
      // 2. Obtenir les statistiques de défis depuis Firestore
      final challengesSnapshot = await _firestore.collection('challenges').get();
      final totalChallenges = challengesSnapshot.docs.length;
      final activeChallenges = challengesSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['isActive'] == true;
      }).length;
      
      // 3. Obtenir les statistiques de réduction carbone totale
      double totalCarbonSaving = 0;
      final carbonSnapshot = await _firestore.collection('carbon_footprints').get();
      for (var doc in carbonSnapshot.docs) {
        final data = doc.data();
        totalCarbonSaving += (data['totalSaving'] ?? 0).toDouble();
      }
      
      // 4. Obtenir les conversions récentes (si API disponible)
      List<Map<String, dynamic>> recentActivities = [];
      if (_apiToken != null) {
        try {
          final response = await http.get(
            Uri.parse('$_baseApiUrl/admin/activities'),
            headers: await _getAuthHeaders(),
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            recentActivities = List<Map<String, dynamic>>.from(data['activities'] ?? []);
          }
        } catch (e) {
          print('Erreur lors de la récupération des activités récentes: $e');
          // Utiliser des données fictives en cas d'erreur
          recentActivities = _getDummyRecentActivities();
        }
      } else {
        // Utiliser des données fictives si pas de token API
        recentActivities = _getDummyRecentActivities();
      }
      
      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalChallenges': totalChallenges,
        'activeChallenges': activeChallenges,
        'totalCarbonSaving': totalCarbonSaving,
        'recentActivities': recentActivities,
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      rethrow;
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }
  
  List<Map<String, dynamic>> _getDummyRecentActivities() {
    return [
      {
        'userId': 'user1',
        'userName': 'Alex Martin',
        'action': 'S\'est inscrit',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'Nouveau',
      },
      {
        'userId': 'user2',
        'userName': 'Sophie Dubois',
        'action': 'A partagé un article',
        'date': DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        'status': 'Complété',
      },
      {
        'userId': 'user3',
        'userName': 'Thomas Laurent',
        'action': 'A terminé un challenge',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'Complété',
      },
      {
        'userId': 'user4',
        'userName': 'Julie Moreau',
        'action': 'A scanné un produit',
        'date': DateTime.now().subtract(const Duration(days: 2, hours: 8)),
        'status': 'En cours',
      },
      {
        'userId': 'user5',
        'userName': 'Nicolas Bernard',
        'action': 'A ajouté un commentaire',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'Complété',
      },
    ];
  }
  
  // SECTION DE GESTION DE CONTENU
  
  Future<bool> createArticle(Map<String, dynamic> articleData) async {
    try {
      await _firestore.collection('articles').add(articleData);
      return true;
    } catch (e) {
      print('Erreur lors de la création de l\'article: $e');
      return false;
    }
  }
  
  Future<Product> createProduct(Product product) async {
    try {
      if (_apiToken != null) {
        final response = await http.post(
          Uri.parse('$_baseApiUrl/admin/products'),
          headers: await _getAuthHeaders(),
          body: json.encode(product.toMap()),
        );
        
        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          return Product.fromMap(data);
        }
        throw Exception('Erreur lors de la création du produit');
      } else {
        // Fallback sur Firestore si pas d'API disponible
        final docRef = await _firestore.collection('products').add(product.toMap());
        final doc = await docRef.get();
        final data = doc.data()!;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }
    } catch (e) {
      print('Erreur lors de la création du produit: $e');
      rethrow;
    }
  }
  
  Future<List<Product>> getProducts() async {
    try {
      if (_apiToken != null) {
        final response = await http.get(
          Uri.parse('$_baseApiUrl/admin/products'),
          headers: await _getAuthHeaders(),
        );
        
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => Product.fromMap(item)).toList();
        }
        return [];
      } else {
        // Fallback sur Firestore si pas d'API disponible
        final snapshot = await _firestore.collection('products').get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Product.fromMap(data);
        }).toList();
      }
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }
  
  Future<Product> updateProduct(Product product) async {
    try {
      if (_apiToken != null) {
        final response = await http.put(
          Uri.parse('$_baseApiUrl/admin/products/${product.id}'),
          headers: await _getAuthHeaders(),
          body: json.encode(product.toMap()),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return Product.fromMap(data);
        }
        throw Exception('Erreur lors de la mise à jour du produit');
      } else {
        // Fallback sur Firestore si pas d'API disponible
        await _firestore.collection('products').doc(product.id).update(product.toMap());
        return product;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      if (_apiToken != null) {
        final response = await http.delete(
          Uri.parse('$_baseApiUrl/admin/products/$productId'),
          headers: await _getAuthHeaders(),
        );
        
        if (response.statusCode != 204) {
          throw Exception('Erreur lors de la suppression du produit');
        }
      } else {
        // Fallback sur Firestore si pas d'API disponible
        await _firestore.collection('products').doc(productId).delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      rethrow;
    }
  }
  
  // SECTION DE PARAMÈTRES SYSTÈME
  
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final settingsDoc = await _firestore.collection('system_settings').doc('app_settings').get();
      
      if (settingsDoc.exists) {
        return settingsDoc.data() ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Erreur lors de la récupération des paramètres système: $e');
      return {};
    }
  }
  
  Future<bool> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('system_settings').doc('app_settings').set(
        settings,
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour des paramètres système: $e');
      return false;
    }
  }

  // Méthodes pour les articles
  Future<List<Article>> getArticles() async {
    try {
      final snapshot = await _firestore.collection('articles').get();
      return snapshot.docs.map((doc) => Article.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      print('Erreur lors de la récupération des articles: $e');
      return [];
    }
  }

  Future<Article?> getArticleById(String articleId) async {
    try {
      final doc = await _firestore.collection('articles').doc(articleId).get();
      if (doc.exists) {
        return Article.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'article: $e');
      return null;
    }
  }

  Future<bool> updateArticle(String articleId, Map<String, dynamic> articleData) async {
    try {
      await _firestore.collection('articles').doc(articleId).update(articleData);
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'article: $e');
      return false;
    }
  }

  Future<bool> deleteArticle(String articleId) async {
    try {
      await _firestore.collection('articles').doc(articleId).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'article: $e');
      return false;
    }
  }

  // SECTION DE GESTION DES DÉFIS
  
  Future<List<EcoChallenge>> getChallenges() async {
    try {
      final snapshot = await _firestore.collection('challenges').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EcoChallenge.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des défis: $e');
      return [];
    }
  }

  Future<void> createChallenge(EcoChallenge challenge) async {
    try {
      await _firestore.collection('challenges').add(challenge.toMap());
    } catch (e) {
      print('Erreur lors de la création du défi: $e');
      rethrow;
    }
  }

  Future<void> updateChallenge(String challengeId, EcoChallenge challenge) async {
    try {
      await _firestore.collection('challenges').doc(challengeId).update(challenge.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour du défi: $e');
      rethrow;
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      await _firestore.collection('challenges').doc(challengeId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du défi: $e');
      rethrow;
    }
  }
} 