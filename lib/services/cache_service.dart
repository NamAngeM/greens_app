import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _productsKey = 'cached_products';
  static const String _articlesKey = 'cached_articles';
  static const String _userDataKey = 'cached_user_data';
  static const String _communityKey = 'cached_community_challenges';
  static const Duration _defaultExpiration = Duration(hours: 6);
  
  /// Stocker des données dans le cache avec une durée d'expiration
  Future<bool> cacheData(String key, dynamic data, {Duration? expiration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheItem = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiration': (expiration ?? _defaultExpiration).inMilliseconds,
      };
      
      return await prefs.setString(key, jsonEncode(cacheItem));
    } catch (e) {
      debugPrint('Erreur lors de la mise en cache: $e');
      return false;
    }
  }
  
  /// Récupérer des données du cache
  Future<T?> getCachedData<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(key);
      
      if (cachedString == null) {
        return null;
      }
      
      final cacheItem = jsonDecode(cachedString);
      final timestamp = cacheItem['timestamp'] as int;
      final expiration = cacheItem['expiration'] as int;
      
      // Vérifier si les données sont expirées
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiration) {
        // Nettoyer les données expirées
        await prefs.remove(key);
        return null;
      }
      
      return cacheItem['data'] as T;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du cache: $e');
      return null;
    }
  }
  
  /// Mettre en cache les produits populaires
  Future<bool> cacheProducts(List<Map<String, dynamic>> products) {
    return cacheData(_productsKey, products);
  }
  
  /// Récupérer les produits du cache
  Future<List<Map<String, dynamic>>?> getCachedProducts() async {
    final data = await getCachedData<List<dynamic>>(_productsKey);
    if (data == null) return null;
    
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }
  
  /// Mettre en cache les articles
  Future<bool> cacheArticles(List<Map<String, dynamic>> articles) {
    return cacheData(_articlesKey, articles);
  }
  
  /// Récupérer les articles du cache
  Future<List<Map<String, dynamic>>?> getCachedArticles() async {
    final data = await getCachedData<List<dynamic>>(_articlesKey);
    if (data == null) return null;
    
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }
  
  /// Mettre en cache les données utilisateur
  Future<bool> cacheUserData(Map<String, dynamic> userData) {
    // Durée d'expiration plus longue pour les données utilisateur
    return cacheData(_userDataKey, userData, expiration: const Duration(days: 1));
  }
  
  /// Récupérer les données utilisateur du cache
  Future<Map<String, dynamic>?> getCachedUserData() async {
    return await getCachedData<Map<String, dynamic>>(_userDataKey);
  }
  
  /// Mettre en cache les défis communautaires
  Future<bool> cacheCommunityData(List<Map<String, dynamic>> challenges) {
    return cacheData(_communityKey, challenges);
  }
  
  /// Récupérer les défis communautaires du cache
  Future<List<Map<String, dynamic>>?> getCachedCommunityData() async {
    final data = await getCachedData<List<dynamic>>(_communityKey);
    if (data == null) return null;
    
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }
  
  /// Nettoyer tout le cache ou des éléments spécifiques
  Future<bool> clearCache({String? specificKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (specificKey != null) {
        return await prefs.remove(specificKey);
      } else {
        // Nettoyer toutes les données mises en cache
        final keys = [_productsKey, _articlesKey, _userDataKey, _communityKey];
        for (final key in keys) {
          await prefs.remove(key);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Erreur lors du nettoyage du cache: $e');
      return false;
    }
  }
} 