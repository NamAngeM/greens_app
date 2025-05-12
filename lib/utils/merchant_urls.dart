import 'package:flutter/material.dart';
import 'domain_manager.dart';
import 'url_launcher_helper.dart';

class MerchantInfo {
  final String name;
  final String url;

  MerchantInfo({
    required this.name,
    required this.url,
  });
}

class MerchantUrls {
  // Mapping des produits vers les URLs (avec des clés de type String)
  static final Map<String, MerchantInfo> productMerchants = {
    '1': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/1',
    ),
    '2': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/2',
    ),
    '3': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/3',
    ),
    '4': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/4',
    ),
    '5': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/5',
    ),
    '6': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/6',
    ),
    '7': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/7',
    ),
    '8': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/8',
    ),
    '9': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/9',
    ),
    '10': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/10',
    ),
    '11': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-gamma.vercel.app/produit/11',
    ),
  };

  // Récupérer les informations du marchand pour un produit donné
  static MerchantInfo? getMerchantForProduct(String productId) {
    // Mapping spécifique des IDs de l'application vers les IDs numériques du site e-commerce
    Map<String, String> appToEcommerceIdMap = {
      // Health & Food products
      'amoseeds-1': '6', // Amandes en vrac
      'juneshine-1': '4', // Savon solide (produit similaire)
      'jens-sorbet-1': '11', // Mousse nettoyante visage (produit similaire)
      'amoseeds-2': '5', // Coffret soin cheveux (produit similaire)
      
      // Fashion products
      'allbirds-1': '7', // T-shirt en coton bio (produit similaire)
      'organic-basics-1': '7', // T-shirt en coton bio
      'qapel-1': '3', // Sac en coton bio
      'organic-basics-2': '7', // T-shirt en coton bio (même produit)
      
      // Essentials
      'ecobottle-1': '2', // Gourde en inox
      'lift-1': '8', // Dentifrice solide (produit similaire)
      'mofpw-1': '10', // Panier en osier
      'lenovo-1': '1', // Brosse à dents en bambou (produit similaire)
    };
    
    print('getMerchantForProduct: Recherche de l\'ID e-commerce pour le produit: $productId');
    
    // Si le produit est dans notre mapping spécifique, utiliser l'ID correspondant
    if (appToEcommerceIdMap.containsKey(productId)) {
      String ecommerceId = appToEcommerceIdMap[productId]!;
      print('getMerchantForProduct: ID e-commerce trouvé dans le mapping: $ecommerceId');
      
      if (productMerchants.containsKey(ecommerceId)) {
        return productMerchants[ecommerceId];
      }
    }
    
    // Si le produit est directement dans le mapping statique, utiliser cette URL
    if (productMerchants.containsKey(productId)) {
      print('getMerchantForProduct: ID trouvé directement dans productMerchants');
      return productMerchants[productId];
    }
    
    // Essayer d'extraire un ID numérique si possible (fallback)
    String numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    print('getMerchantForProduct: ID numérique extrait: $numericId');
    
    if (numericId.isNotEmpty && productMerchants.containsKey(numericId)) {
      print('getMerchantForProduct: ID numérique trouvé dans productMerchants');
      return productMerchants[numericId];
    }
    
    // Sinon, construire une URL dynamique basée sur le produit
    print('getMerchantForProduct: Aucun mapping trouvé, utilisation de l\'ID par défaut: 1');
    return MerchantInfo(
      name: 'Green Commerce',
      url: '${DomainManager.currentDomain}/produit/1', // Rediriger vers le produit 1 par défaut
    );
  }
  
  // Méthode pour ouvrir l'URL du marchand avec gestion des erreurs
  static Future<bool> openMerchantUrl(String productId, {BuildContext? context}) async {
    print('MerchantUrls: Tentative d\'ouverture de l\'URL pour le produit: $productId');
    
    // Obtenir les informations du marchand via notre méthode de mapping
    final merchantInfo = getMerchantForProduct(productId);
    
    if (merchantInfo != null) {
      try {
        print('MerchantUrls: URL trouvée via mapping: ${merchantInfo.url}');
        
        // Utiliser notre utilitaire pour lancer l'URL
        final success = await UrlLauncherHelper.launchUrlWithFallback(
          merchantInfo.url,
          context: context,
        );
        
        if (success) {
          return true;
        }
      } catch (e) {
        print('MerchantUrls: Erreur avec l\'URL mappée: $e');
      }
    } else {
      print('MerchantUrls: Aucune info marchand trouvée pour $productId');
    }
    
    // Si le mapping a échoué ou si l'URL n'a pas pu être ouverte,
    // essayer avec l'approche dynamique
    
    // Extraire l'ID numérique si possible
    String numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericId.isEmpty) {
      numericId = '1'; // Fallback sur l'ID 1 si aucun ID numérique n'est trouvé
    }
    
    print('MerchantUrls: Utilisation de l\'ID numérique extrait: $numericId');
    
    // Essayer avec chaque domaine jusqu'à ce qu'un fonctionne
    for (String domain in DomainManager.domains) {
      final url = '$domain/produit/$numericId';
      print('MerchantUrls: Essai avec le domaine: $url');
      
      final success = await UrlLauncherHelper.launchUrlWithFallback(
        url,
        context: context,
        // Ne pas afficher d'erreur pour chaque domaine, seulement pour le dernier
        showErrorMessage: domain == DomainManager.domains.last,
      );
      
      if (success) {
        return true;
      }
    }
    
    return false;
  }
}