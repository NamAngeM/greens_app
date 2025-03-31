import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:uuid/uuid.dart';

import '../views/blogs/blog_view.dart';

class ProductScanController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ProductScan> _scanHistory = [];
  ProductScan? _lastScan;
  bool _isLoading = false;
  bool _isScanning = false;
  
  List<ProductScan> get scanHistory => _scanHistory;
  ProductScan? get lastScan => _lastScan;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  
  Future<void> getUserScanHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('product_scans')
          .where('userId', isEqualTo: userId)
          .orderBy('scannedAt', descending: true)
          .get();
      
      _scanHistory.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        _scanHistory.add(ProductScan.fromJson(data));
      }
      
      if (_scanHistory.isNotEmpty) {
        _lastScan = _scanHistory.first;
      }
    } catch (e) {
      print('Error fetching scan history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<ProductScan?> scanBarcode(String barcode, String userId) async {
    _isScanning = true;
    notifyListeners();
    
    try {
      // Vérifier si le produit existe dans la base de données
      final productSnapshot = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      
      if (productSnapshot.docs.isEmpty) {
        return null; // Produit non trouvé
      }
      
      final productData = productSnapshot.docs.first.data();
      
      // Créer un scan
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      
      final scan = ProductScan(
        id: uuid,
        userId: userId,
        barcode: barcode,
        productName: productData['name'] ?? 'Produit inconnu',
        brand: productData['brand'] ?? 'Marque inconnue',
        imageUrl: productData['imageUrl'] ?? '',
        ecoRating: EcoRating.values.firstWhere(
          (e) => e.toString() == 'EcoRating.${productData['ecoRating']}',
          orElse: () => EcoRating.unknown,
        ),
        ecoImpact: productData['ecoImpact'] ?? 'Impact environnemental non disponible',
        ecoTips: List<String>.from(productData['ecoTips'] ?? []),
        alternativeProductIds: List<String>.from(productData['alternativeProductIds'] ?? []),
        scannedAt: now,
      );
      
      // Enregistrer le scan dans Firestore
      await _firestore.collection('product_scans').doc(uuid).set(scan.toJson());
      
      // Mettre à jour l'historique local
      _scanHistory.insert(0, scan);
      _lastScan = scan;
      
      notifyListeners();
      
      return scan;
    } catch (e) {
      print('Error scanning barcode: $e');
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
  
  Future<List<ProductModel>> getAlternativeProducts(List<String> productIds) async {
    try {
      final List<ProductModel> alternatives = [];
      
      for (var id in productIds) {
        final doc = await _firestore.collection('products').doc(id).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            data['id'] = doc.id;
            alternatives.add(ProductModel.fromJson(data));
          }
        }
      }
      
      return alternatives;
    } catch (e) {
      print('Error fetching alternative products: $e');
      return [];
    }
  }
  
  Future<bool> deleteScan(String scanId) async {
    try {
      await _firestore.collection('product_scans').doc(scanId).delete();
      
      _scanHistory.removeWhere((scan) => scan.id == scanId);
      if (_lastScan?.id == scanId) {
        _lastScan = _scanHistory.isNotEmpty ? _scanHistory.first : null;
      }
      
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error deleting scan: $e');
      return false;
    }
  }
  
  void clearScanHistory() {
    _scanHistory.clear();
    _lastScan = null;
    notifyListeners();
  }
}