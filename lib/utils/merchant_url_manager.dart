import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greens_app/models/unified_product_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Gestionnaire d'URLs marchands plus robuste et évolutif
class MerchantUrlManager {
  // Singleton
  static final MerchantUrlManager _instance = MerchantUrlManager._internal();
  factory MerchantUrlManager() => _instance;
  MerchantUrlManager._internal();

  // URL de base pour l'e-commerce
  static const String _defaultBaseUrl = 'https://green-commerce-gamma.vercel.app';
  
  // Domaines de repli en cas d'échec
  static const List<String> _fallbackDomains = [
    'https://green-commerce-gamma.vercel.app',
    'https://green-commerce-backup.vercel.app',
    'https://green-commerce-mirror.netlify.app',
  ];
  
  // Cache local des URLs
  final Map<String, Map<String, String>> _urlCache = {};
  DateTime _lastCacheUpdate = DateTime.now().subtract(const Duration(days: 1));
  
  // Durée de validité du cache (en heures)
  static const int _cacheDuration = 24;
  
  /// Récupérer l'URL marchand pour un produit
  Future<Map<String, String>> getMerchantUrlForProduct(String productId) async {
    // Vérifier si le cache est valide
    final cacheAge = DateTime.now().difference(_lastCacheUpdate).inHours;
    if (_urlCache.containsKey(productId) && cacheAge < _cacheDuration) {
      return _urlCache[productId]!;
    }
    
    try {
      // Vérifier la connectivité
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return _generateFallbackUrl(productId);
      }
      
      // Essayer de récupérer l'URL depuis Firestore
      final doc = await FirebaseFirestore.instance
          .collection('product_merchant_urls')
          .doc(productId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final result = {
          'url': data['url'] ?? '$_defaultBaseUrl/produit/$productId',
          'name': data['merchant_name'] ?? 'Green Commerce',
        };
        
        // Mettre en cache
        _urlCache[productId] = result;
        _lastCacheUpdate = DateTime.now();
        
        // Sauvegarder dans les préférences locales
        _saveToLocalStorage(productId, result);
        
        return result;
      }
      
      // Si pas trouvé, utiliser le système de mapping de secours
      return await _getLegacyMappedUrl(productId);
    } catch (e) {
      print('Erreur lors de la récupération de l\'URL marchand: $e');
      
      // Essayer de récupérer depuis le stockage local
      final localData = await _getFromLocalStorage(productId);
      if (localData != null) {
        return localData;
      }
      
      // En dernier recours, générer une URL de repli
      return _generateFallbackUrl(productId);
    }
  }
  
  /// Générer une URL de repli basée sur l'ID du produit
  Map<String, String> _generateFallbackUrl(String productId) {
    // Extraire un ID numérique si possible
    final numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    final finalId = numericId.isNotEmpty ? numericId : '1';
    
    return {
      'url': '$_defaultBaseUrl/produit/$finalId',
      'name': 'Green Commerce',
    };
  }
  
  /// Récupérer l'URL depuis l'ancien système de mapping
  Future<Map<String, String>> _getLegacyMappedUrl(String productId) async {
    // Mapping spécifique des IDs de l'application vers les IDs e-commerce
    Map<String, String> appToEcommerceIdMap = {
      // Health & Food products
      'amoseeds-1': '6', // Amandes en vrac
      'juneshine-1': '4', // Savon solide
      'jens-sorbet-1': '11', // Mousse nettoyante visage
      'amoseeds-2': '5', // Coffret soin cheveux
      
      // Fashion products
      'allbirds-1': '7', // T-shirt en coton bio
      'organic-basics-1': '7', // T-shirt en coton bio
      'qapel-1': '3', // Sac en coton bio
      'organic-basics-2': '7', // T-shirt en coton bio
      
      // Essentials
      'ecobottle-1': '2', // Gourde en inox
      'lift-1': '8', // Dentifrice solide
      'mofpw-1': '10', // Panier en osier
      'lenovo-1': '1', // Brosse à dents en bambou
    };
    
    String idToUse = productId;
    
    // Utiliser l'ID mappé si disponible
    if (appToEcommerceIdMap.containsKey(productId)) {
      idToUse = appToEcommerceIdMap[productId]!;
    } else {
      // Essayer d'extraire un ID numérique
      final numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericId.isNotEmpty) {
        idToUse = numericId;
      } else {
        idToUse = '1'; // ID par défaut
      }
    }
    
    final result = {
      'url': '$_defaultBaseUrl/produit/$idToUse',
      'name': 'Green Commerce',
    };
    
    // Mettre en cache
    _urlCache[productId] = result;
    _lastCacheUpdate = DateTime.now();
    
    // Sauvegarder localement
    _saveToLocalStorage(productId, result);
    
    return result;
  }
  
  /// Sauvegarder les données URL dans le stockage local
  Future<void> _saveToLocalStorage(String productId, Map<String, String> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('merchant_url_$productId', data['url']!);
      await prefs.setString('merchant_name_$productId', data['name']!);
    } catch (e) {
      print('Erreur lors de la sauvegarde locale des données URL: $e');
    }
  }
  
  /// Récupérer les données URL depuis le stockage local
  Future<Map<String, String>?> _getFromLocalStorage(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('merchant_url_$productId');
      final name = prefs.getString('merchant_name_$productId');
      
      if (url != null && name != null) {
        return {'url': url, 'name': name};
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la récupération locale des données URL: $e');
      return null;
    }
  }
  
  /// Ouvrir l'URL du marchand pour un produit
  Future<bool> openMerchantUrl(String productId, {BuildContext? context}) async {
    try {
      final merchantData = await getMerchantUrlForProduct(productId);
      final merchantUrl = merchantData['url']!;
      
      final url = Uri.parse(merchantUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'ouvrir le site marchand"),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // Si l'URL principale a échoué, essayer avec les domaines de repli
      for (final domain in _fallbackDomains.skip(1)) {
        // Extraire le chemin relatif
        final uri = Uri.parse(merchantUrl);
        final path = uri.path;
        
        // Construire la nouvelle URL avec le domaine de repli
        final fallbackUrl = Uri.parse('$domain$path');
        
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(
            fallbackUrl,
            mode: LaunchMode.externalApplication,
          );
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de l\'ouverture de l\'URL marchand: $e');
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      return false;
    }
  }

  /// Obtenir les URLs marchands pour une liste de produits
  Future<List<Map<String, dynamic>>> getMerchantUrlsForProducts(List<UnifiedProduct> products) async {
    final results = <Map<String, dynamic>>[];
    
    for (final product in products) {
      final merchantData = await getMerchantUrlForProduct(product.id);
      results.add({
        'productId': product.id,
        'productName': product.name,
        'merchantUrl': merchantData['url'],
        'merchantName': merchantData['name'],
      });
    }
    
    return results;
  }

  /// Mettre à jour l'URL marchand pour un produit
  Future<bool> updateMerchantUrl(String productId, String url, String merchantName) async {
    try {
      await FirebaseFirestore.instance
          .collection('product_merchant_urls')
          .doc(productId)
          .set({
            'url': url,
            'merchant_name': merchantName,
            'updated_at': FieldValue.serverTimestamp(),
          });
      
      // Mettre à jour le cache
      _urlCache[productId] = {
        'url': url,
        'name': merchantName,
      };
      
      // Mettre à jour le stockage local
      _saveToLocalStorage(productId, {
        'url': url,
        'name': merchantName,
      });
      
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'URL marchand: $e');
      return false;
    }
  }
} 