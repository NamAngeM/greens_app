import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/product_model.dart';
import 'dart:math';
// Désactivé temporairement pour résoudre les problèmes de compilation
// import 'package:geolocator/geolocator.dart';

// Structure temporaire pour remplacer la dépendance à Position
class FakePosition {
  final double latitude;
  final double longitude;
  
  FakePosition({required this.latitude, required this.longitude});
}

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer tous les produits
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  // Méthode pour récupérer les produits écologiques
  Future<List<ProductModel>> getEcoFriendlyProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isEcoFriendly', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits écologiques: $e');
      return [];
    }
  }

  // Méthode pour récupérer les produits par catégorie
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('categories', arrayContains: category)
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits par catégorie: $e');
      return [];
    }
  }

  // Méthode pour récupérer un produit par son ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();
      
      if (doc.exists) {
        return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  // Méthode pour rechercher des produits
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Convertir la requête en minuscules pour une recherche insensible à la casse
      final lowercaseQuery = query.toLowerCase();
      
      // Récupérer tous les produits (dans une application réelle, il faudrait utiliser une solution de recherche plus efficace)
      final snapshot = await _firestore
          .collection('products')
          .get();
      
      // Filtrer les produits qui correspondent à la requête
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .where((product) => 
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.brand.toLowerCase().contains(lowercaseQuery) ||
              product.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche de produits: $e');
      return [];
    }
  }

  // Méthode pour appliquer un coupon à un produit
  Future<ProductModel?> applyDiscountCoupon(String productId, double discountPercentage) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        return null;
      }
      
      // Créer une copie du produit avec la réduction appliquée
      final discountedProduct = ProductModel(
        id: product.id,
        name: product.name,
        brand: product.brand,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        categories: product.categories,
        isEcoFriendly: product.isEcoFriendly,
        discountPercentage: discountPercentage,
        hasCoupon: true,
      );
      
      return discountedProduct;
    } catch (e) {
      debugPrint('Erreur lors de l\'application du coupon: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductInfo(String barcode) async {
    try {
      final doc = await _firestore
          .collection('products')
          .doc(barcode)
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      print('Erreur lors de la récupération des informations du produit: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getLocalAlternatives(String productId, {double maxDistance = 10.0}) async {
    try {
      // Version temporaire sans géolocalisation réelle
      final currentPosition = FakePosition(latitude: 48.8566, longitude: 2.3522); // Paris par défaut
      
      final QuerySnapshot snapshot = await _firestore
          .collection('local_stores')
          .get();

      final List<Map<String, dynamic>> alternatives = [];
      
      for (var doc in snapshot.docs) {
        final storeData = doc.data() as Map<String, dynamic>;
        final storeLocation = storeData['location'] as GeoPoint;
        
        // Calcul de distance temporaire (approximatif)
        final distance = _calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          storeLocation.latitude,
          storeLocation.longitude,
        );

        if (distance <= maxDistance) {
          final productInfo = await _getStoreProductInfo(doc.id, productId);
          if (productInfo != null) {
            alternatives.add({
              ...storeData,
              'distance': distance,
              'product': productInfo,
            });
          }
        }
      }

      alternatives.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      return alternatives;
    } catch (e) {
      print('Erreur lors de la récupération des alternatives locales: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getStoreProductInfo(String storeId, String productId) async {
    try {
      final doc = await _firestore
          .collection('local_stores')
          .doc(storeId)
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      print('Erreur lors de la récupération des informations du produit en magasin: $e');
      return null;
    }
  }

  Future<FakePosition> _getCurrentPosition() async {
    // Version temporaire sans géolocalisation réelle
    return FakePosition(latitude: 48.8566, longitude: 2.3522); // Paris par défaut
  }

  // Méthode temporaire pour calculer la distance (formule approximative)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = 
        _sin(dLat / 2) * _sin(dLat / 2) +
        _sin(dLon / 2) * _sin(dLon / 2) * _cos(_toRadians(lat1)) * _cos(_toRadians(lat2));
    final c = 2 * _asin(_sqrt(a));
    
    return earthRadius * c; // Distance en km
  }
  
  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }
  
  double _sin(double radians) => sin(radians);
  double _cos(double radians) => cos(radians);
  double _asin(double value) => asin(value);
  double _sqrt(double value) => sqrt(value);

  Future<List<String>> getProductCertifications(String productId) async {
    try {
      final doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['certifications'] ?? []);
    } catch (e) {
      print('Erreur lors de la récupération des certifications: $e');
      return [];
    }
  }

  Future<double> calculateEcoRating(String productId) async {
    try {
      final doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        return 0.0;
      }

      final data = doc.data() as Map<String, dynamic>;
      final Map<String, double> criteria = Map<String, double>.from(data['eco_criteria'] ?? {});
      
      double totalScore = 0.0;
      int criteriaCount = 0;

      criteria.forEach((key, value) {
        totalScore += value;
        criteriaCount++;
      });

      return criteriaCount > 0 ? totalScore / criteriaCount : 0.0;
    } catch (e) {
      print('Erreur lors du calcul de la note écologique: $e');
      return 0.0;
    }
  }
}
