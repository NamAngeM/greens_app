import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:geolocator/geolocator.dart';

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
      final Position currentPosition = await _getCurrentPosition();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('local_stores')
          .get();

      final List<Map<String, dynamic>> alternatives = [];
      
      for (var doc in snapshot.docs) {
        final storeData = doc.data() as Map<String, dynamic>;
        final storeLocation = storeData['location'] as GeoPoint;
        
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          storeLocation.latitude,
          storeLocation.longitude,
        ) / 1000; // Convertir en kilomètres

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

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Les permissions de localisation ont été refusées.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Les permissions de localisation sont définitivement refusées.');
    }

    return await Geolocator.getCurrentPosition();
  }

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
