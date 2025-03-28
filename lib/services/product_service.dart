import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/product_model.dart';

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
}
