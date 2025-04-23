import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'dart:math';

class ProductScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Obtenir l'historique des scans d'un utilisateur
  Future<List<ProductScan>> getUserScanHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('product_scans')
          .where('userId', isEqualTo: userId)
          .orderBy('scanDate', descending: true)
          .get();
      
      final List<ProductScan> history = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        history.add(ProductScan.fromJson(data));
      }
      
      return history;
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }
  
  // Obtenir les informations d'un produit scanné
  Future<ProductScan> getProductInfo(String barcode, String? userId, {String category = 'Alimentation'}) async {
    try {
      // Vérifier si le produit existe déjà dans la base de données
      final existingProduct = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      
      if (existingProduct.docs.isNotEmpty) {
        // Produit trouvé, créer un scan basé sur les données existantes
        final productData = existingProduct.docs.first.data();
        final scanData = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'barcode': barcode,
          'productName': productData['name'],
          'brand': productData['brand'],
          'imageUrl': productData['imageUrl'],
          'category': productData['category'],
          'ecoScore': productData['ecoScore'] ?? 'C',
          'ingredients': productData['ingredients'] ?? [],
          'origin': productData['origin'] ?? 'Non spécifié',
          'scanDate': DateTime.now(),
          'userId': userId,
          // Autres informations du produit
        };
        
        // Sauvegarder le scan
        if (userId != null) {
          await _firestore.collection('product_scans').add(scanData);
        }
        
        return ProductScan.fromJson(scanData);
      } else {
        // Produit non trouvé, générer des données fictives
        return _generateMockProductData(barcode, userId, category);
      }
    } catch (e) {
      print('Erreur lors de la récupération des infos produit: $e');
      // En cas d'erreur, générer des données fictives
      return _generateMockProductData(barcode, userId, category);
    }
  }
  
  // Générer des données fictives pour un produit
  ProductScan _generateMockProductData(String barcode, String? userId, String category) {
    // Adapter les données en fonction de la catégorie
    String productName;
    String brand;
    List<String> ingredients = [];
    String origin;
    
    Random random = Random();
    
    switch (category) {
      case 'Livres & Médias':
        productName = 'Le Guide de l\'Écologie';
        brand = 'Éditions Vertes';
        origin = 'France';
        ingredients = ['Papier recyclé', 'Encre végétale'];
        break;
      
      case 'Électronique':
        productName = 'Écouteurs Bluetooth';
        brand = 'EcoTech';
        origin = 'Chine';
        ingredients = ['Plastique recyclé', 'Aluminium', 'Lithium'];
        break;
      
      case 'Vêtements & Mode':
        productName = 'T-shirt en coton bio';
        brand = 'EcoWear';
        origin = 'Portugal';
        ingredients = ['Coton biologique', 'Teinture naturelle'];
        break;
      
      case 'Beauté & Cosmétiques':
        productName = 'Crème hydratante naturelle';
        brand = 'NatureCare';
        origin = 'France';
        ingredients = ['Aloe vera', 'Huile d\'argan', 'Vitamine E'];
        break;
      
      case 'Produits Ménagers':
        productName = 'Lessive écologique';
        brand = 'EcoClean';
        origin = 'Allemagne';
        ingredients = ['Savon de Marseille', 'Bicarbonate', 'Huiles essentielles'];
        break;
      
      default: // Alimentation
        productName = 'Granola Bio';
        brand = 'NaturFood';
        origin = 'France';
        ingredients = ['Avoine', 'Miel', 'Noix', 'Fruits séchés', 'Graines'];
        break;
    }
    
    // Générer un score écologique aléatoire (mais plus souvent positif)
    final List<String> ecoScores = ['A', 'A', 'B', 'B', 'C', 'D', 'E'];
    final String ecoScore = ecoScores[random.nextInt(ecoScores.length)];
    
    // Générer des impacts environnementaux
    final int carbonFootprint = random.nextInt(4) + 1; // 1-5
    final int waterFootprint = random.nextInt(4) + 1; // 1-5
    final int deforestationImpact = random.nextInt(4) + 1; // 1-5
    
    // Conseils écologiques en fonction de la catégorie
    List<String> ecoTips = [];
    if (category == 'Livres & Médias') {
      ecoTips = [
        'Partagez ce livre avec vos amis après lecture',
        'Privilégiez les livres numériques pour réduire la consommation de papier',
        'Recyclez ce livre lorsque vous n\'en avez plus besoin'
      ];
    } else if (category == 'Alimentation') {
      ecoTips = [
        'Conservez ce produit correctement pour éviter le gaspillage',
        'Recyclez l\'emballage après usage',
        'Privilégiez les produits locaux et de saison'
      ];
    } else {
      ecoTips = [
        'Privilégiez les produits avec un meilleur score écologique',
        'Recyclez l\'emballage après usage',
        'Utilisez ce produit jusqu\'à la fin avant de le remplacer'
      ];
    }
    
    // Générer l'impact écologique
    String ecoImpact;
    if (ecoScore == 'A' || ecoScore == 'B') {
      ecoImpact = 'Ce produit a un impact environnemental relativement faible par rapport aux produits similaires de sa catégorie.';
    } else if (ecoScore == 'C') {
      ecoImpact = 'Ce produit a un impact environnemental moyen. Des alternatives plus écologiques existent.';
    } else {
      ecoImpact = 'Ce produit a un impact environnemental important. Nous vous recommandons de considérer des alternatives plus écologiques.';
    }
    
    // Créer l'objet ProductScan
    return ProductScan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      barcode: barcode,
      productName: productName,
      brand: brand,
      category: category,
      ecoScore: ecoScore,
      ecoRating: _getEcoRatingFromScore(ecoScore),
      ingredients: ingredients,
      origin: origin,
      imageUrl: 'https://via.placeholder.com/300x300.png?text=$productName',
      carbonFootprint: carbonFootprint,
      waterFootprint: waterFootprint,
      deforestationImpact: deforestationImpact,
      ecoTips: ecoTips,
      ecoImpact: ecoImpact,
      scanDate: DateTime.now(),
      userId: userId ?? 'anonymous',
      ecoAlternatives: [],
      alternativeProductIds: [],
    );
  }
  
  // Convertir un score écologique en EcoRating
  EcoRating _getEcoRatingFromScore(String score) {
    switch (score) {
      case 'A': return EcoRating.excellent;
      case 'B': return EcoRating.good;
      case 'C': return EcoRating.average;
      case 'D': return EcoRating.poor;
      case 'E': return EcoRating.bad;
      default: return EcoRating.unknown;
    }
  }
} 