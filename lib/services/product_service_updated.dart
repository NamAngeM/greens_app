import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/product_unified.dart';

class ProductServiceUpdated {
  final FirebaseFirestore _firestore;
  final String _collection = 'products';
  
  ProductServiceUpdated({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Récupère tous les produits depuis Firestore
  Future<List<UnifiedProduct>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) => 
        UnifiedProduct.fromMap(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      rethrow;
    }
  }
  
  /// Récupère les produits écologiques depuis Firestore
  Future<List<UnifiedProduct>> getEcoFriendlyProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isEcoFriendly', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) => 
        UnifiedProduct.fromMap(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits écologiques: $e');
      rethrow;
    }
  }
  
  /// Récupère les produits d'une catégorie spécifique
  Future<List<UnifiedProduct>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('categories', arrayContains: category)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) => 
        UnifiedProduct.fromMap(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits par catégorie: $e');
      rethrow;
    }
  }
  
  /// Recherche des produits par mot-clé
  Future<List<UnifiedProduct>> searchProducts(String query) async {
    try {
      // Recherche directe par nom (Firebase ne supporte pas la recherche textuelle native)
      // Pour une recherche avancée, il faudrait utiliser Algolia ou ElasticSearch
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();
      
      return snapshot.docs.map((doc) => 
        UnifiedProduct.fromMap(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      print('Erreur lors de la recherche de produits: $e');
      rethrow;
    }
  }
  
  /// Récupère un produit par son ID
  Future<UnifiedProduct?> getProductById(String id) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return UnifiedProduct.fromMap(doc.data()!, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du produit: $e');
      rethrow;
    }
  }
  
  /// Ajoute ou met à jour un produit
  Future<void> saveProduct(UnifiedProduct product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .set(product.toMap());
    } catch (e) {
      print('Erreur lors de l\'enregistrement du produit: $e');
      rethrow;
    }
  }
  
  /// Supprime un produit
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      rethrow;
    }
  }
} 