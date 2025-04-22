import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';

class ProductDatabase {
  static const String _scannedProductsKey = 'scanned_products';
  static final ProductDatabase _instance = ProductDatabase._internal();
  
  factory ProductDatabase() {
    return _instance;
  }
  
  ProductDatabase._internal();
  
  // Base de données simulée avec des produits prédéfinis
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Lait Bio Demi-Écrémé',
      brand: 'Naturavie',
      barcode: '3456789012345',
      imageUrl: 'assets/images/products/lait_bio.jpg',
      carbonFootprint: 1.2,
      composition: {
        'plastique': false,
        'carton': true,
        'huile_de_palme': false,
        'ogm': false,
      },
      decompositionTime: 90, // 3 mois pour le carton
      ecoScore: 'B',
      ethicalScore: 'A',
      recyclingInstructions: ['Jeter la brique dans le bac de recyclage', 'Plier la brique pour gagner de l\'espace'],
      price: 1.89,
      tags: ['bio', 'local', 'recyclable'],
      scannedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'Céréales au Chocolat',
      brand: 'CrunchyMunch',
      barcode: '5678901234567',
      imageUrl: 'assets/images/products/cereales_choco.jpg',
      carbonFootprint: 2.5,
      composition: {
        'plastique': true,
        'carton': true,
        'huile_de_palme': true,
        'ogm': false,
      },
      decompositionTime: 450, // 15 mois pour le plastique
      ecoScore: 'D',
      ethicalScore: 'C',
      recyclingInstructions: ['Jeter le carton dans le bac de recyclage', 'Le sachet plastique n\'est pas recyclable'],
      price: 3.49,
      tags: ['sucré', 'petit-déjeuner'],
      scannedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: 'Lessive Écologique',
      brand: 'CleanGreen',
      barcode: '7890123456789',
      imageUrl: 'assets/images/products/lessive_eco.jpg',
      carbonFootprint: 0.8,
      composition: {
        'plastique': true,
        'carton': false,
        'huile_de_palme': false,
        'ogm': false,
      },
      decompositionTime: 300,
      ecoScore: 'A',
      ethicalScore: 'A',
      recyclingInstructions: ['Flacon recyclable', 'Vider complètement avant de jeter'],
      price: 5.99,
      tags: ['eco', 'naturel', 'sans parfum'],
      scannedAt: DateTime.now(),
    ),
    Product(
      id: '4',
      name: 'Chips Nature',
      brand: 'CrispyCrunch',
      barcode: '9012345678901',
      imageUrl: 'assets/images/products/chips.jpg',
      carbonFootprint: 1.9,
      composition: {
        'plastique': true,
        'carton': false,
        'huile_de_palme': false,
        'ogm': false,
      },
      decompositionTime: 500,
      ecoScore: 'C',
      ethicalScore: 'B',
      recyclingInstructions: ['Emballage non recyclable', 'À jeter dans les ordures ménagères'],
      price: 1.75,
      tags: ['snack', 'salé'],
      scannedAt: DateTime.now(),
    ),
    Product(
      id: '5',
      name: 'Savon Solide Bio',
      brand: 'NatureSoap',
      barcode: '1234509876543',
      imageUrl: 'assets/images/products/savon_solide.jpg',
      carbonFootprint: 0.3,
      composition: {
        'plastique': false,
        'carton': true,
        'huile_de_palme': false,
        'ogm': false,
      },
      decompositionTime: 30,
      ecoScore: 'A',
      ethicalScore: 'A',
      recyclingInstructions: ['Emballage en carton recyclable', 'Produit biodégradable'],
      price: 4.50,
      tags: ['bio', 'vegan', 'zero déchet'],
      scannedAt: DateTime.now(),
    ),
  ];
  
  // Obtenir un produit par code-barres
  Future<Product?> getProductByBarcode(String barcode) async {
    // Dans une vraie application, ceci ferait un appel API
    try {
      return _mockProducts.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }
  
  // Obtenir un produit par reconnaissance d'image (simulé)
  Future<Product?> getProductByImage(String imagePath) async {
    // Simuler la reconnaissance d'image avec un délai
    await Future.delayed(const Duration(seconds: 2));
    
    // Dans une vraie application, ceci utiliserait un modèle ML ou une API
    // Pour la démo, on retourne simplement un produit aléatoire
    if (_mockProducts.isNotEmpty) {
      final randomIndex = DateTime.now().millisecondsSinceEpoch % _mockProducts.length;
      return _mockProducts[randomIndex];
    }
    
    return null;
  }
  
  // Obtenir des alternatives plus écologiques
  Future<List<Product>> getAlternatives(Product product) async {
    // Filtrer les produits qui ont un meilleur score écologique
    final alternatives = _mockProducts.where((p) => 
      p.id != product.id && 
      p.getEnvironmentalImpactScore() > product.getEnvironmentalImpactScore()
    ).toList();
    
    return alternatives;
  }
  
  // Sauvegarder un produit scanné dans l'historique
  Future<void> saveScannedProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Récupérer les produits déjà scannés
    final List<String> savedProducts = prefs.getStringList(_scannedProductsKey) ?? [];
    
    // Vérifier si le produit existe déjà
    final bool alreadyExists = savedProducts.any((p) {
      final Map<String, dynamic> savedProduct = jsonDecode(p);
      return savedProduct['barcode'] == product.barcode;
    });
    
    // Si le produit n'existe pas, l'ajouter
    if (!alreadyExists) {
      // Mettre à jour la date de scan
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        brand: product.brand,
        barcode: product.barcode,
        imageUrl: product.imageUrl,
        carbonFootprint: product.carbonFootprint,
        composition: product.composition,
        decompositionTime: product.decompositionTime,
        ecoScore: product.ecoScore,
        ethicalScore: product.ethicalScore,
        recyclingInstructions: product.recyclingInstructions,
        alternatives: product.alternatives,
        price: product.price,
        tags: product.tags,
        scannedAt: DateTime.now(),
      );
      
      savedProducts.add(jsonEncode(updatedProduct.toJson()));
      await prefs.setStringList(_scannedProductsKey, savedProducts);
    }
  }
  
  // Récupérer l'historique des produits scannés
  Future<List<Product>> getScannedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedProducts = prefs.getStringList(_scannedProductsKey) ?? [];
    
    // Convertir les chaînes JSON en objets Product
    final products = savedProducts.map((p) {
      final Map<String, dynamic> productMap = jsonDecode(p);
      return Product.fromJson(productMap);
    }).toList();
    
    // Trier par date de scan (du plus récent au plus ancien)
    products.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    
    return products;
  }
  
  // Calculer le score écologique de l'utilisateur
  Future<double> calculateEcoScore() async {
    final products = await getScannedProducts();
    
    if (products.isEmpty) {
      return 0.0;
    }
    
    // Calculer la moyenne des scores environnementaux
    double totalScore = 0;
    for (final product in products) {
      totalScore += product.getEnvironmentalImpactScore();
    }
    
    return totalScore / products.length;
  }
  
  // Générer des recommandations personnalisées
  Future<List<String>> generateRecommendations() async {
    final products = await getScannedProducts();
    final List<String> recommendations = [];
    
    if (products.isEmpty) {
      return ['Commencez à scanner des produits pour obtenir des recommandations personnalisées'];
    }
    
    // Analyser les produits scannés
    int plasticCount = 0;
    int nonRecyclableCount = 0;
    int lowEcoScoreCount = 0;
    
    for (final product in products) {
      if (product.composition['plastique'] == true) {
        plasticCount++;
      }
      
      // On considère un produit comme non recyclable si son emballage n'est pas recyclable
      if (product.recyclingInstructions.any((instruction) => 
        instruction.toLowerCase().contains('non recyclable'))) {
        nonRecyclableCount++;
      }
      
      // On considère un score C, D ou E comme faible
      if (['C', 'D', 'E'].contains(product.ecoScore)) {
        lowEcoScoreCount++;
      }
    }
    
    // Générer des recommandations basées sur l'analyse
    if (plasticCount > products.length * 0.3) {
      recommendations.add('Essayez de réduire votre consommation de produits avec emballage plastique');
    }
    
    if (nonRecyclableCount > 0) {
      recommendations.add('Privilégiez les produits avec emballages recyclables');
    }
    
    if (lowEcoScoreCount > products.length * 0.5) {
      recommendations.add('Recherchez des alternatives avec de meilleurs scores environnementaux');
    }
    
    // Si aucune recommandation spécifique, ajouter une recommandation générale
    if (recommendations.isEmpty) {
      recommendations.add('Continuez comme ça ! Vos choix sont déjà assez écologiques');
    }
    
    return recommendations;
  }
} 