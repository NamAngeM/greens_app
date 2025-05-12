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
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/1',
    ),
    '2': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/2',
    ),
    '3': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/3',
    ),
    '4': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/4',
    ),
    '5': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/5',
    ),
    '6': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/6',
    ),
    '7': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/7',
    ),
    '8': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/8',
    ),
    '9': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/9',
    ),
    '10': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/10',
    ),
    '11': MerchantInfo(
      name: 'Green Commerce',
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/11',
    ),
  };

  // Récupérer les informations du marchand pour un produit donné
  static MerchantInfo? getMerchantForProduct(String productId) {
    // Si le produit est dans le mapping statique, utiliser cette URL
    if (productMerchants.containsKey(productId)) {
      return productMerchants[productId];
    }
    
    // Essayer d'extraire un ID numérique si possible
    String numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericId.isNotEmpty && productMerchants.containsKey(numericId)) {
      return productMerchants[numericId];
    }
    
    // Sinon, construire une URL dynamique basée sur le produit
    // Cette approche est plus flexible et permet d'ajouter de nouveaux produits sans modifier le code
    return MerchantInfo(
      name: 'Green Commerce',
      url: '${DomainManager.currentDomain}/produit/${numericId.isNotEmpty ? numericId : productId}',
    );
  }
  
  // Nouvelle méthode pour ouvrir l'URL du marchand avec gestion des erreurs
  static Future<bool> openMerchantUrl(String productId, {BuildContext? context}) async {
    print('MerchantUrls: Tentative d\'ouverture de l\'URL pour le produit: $productId');
    
    // Vérifier d'abord si nous avons une URL statique pour ce produit
    if (productMerchants.containsKey(productId)) {
      try {
        final merchantInfo = productMerchants[productId]!;
        print('MerchantUrls: URL statique trouvée: ${merchantInfo.url}');
        
        // Utiliser notre nouvel utilitaire pour lancer l'URL
        final success = await UrlLauncherHelper.launchUrlWithFallback(
          merchantInfo.url,
          context: context,
        );
        
        if (success) {
          return true;
        }
      } catch (e) {
        print('MerchantUrls: Erreur avec l\'URL statique: $e');
        // Si l'URL statique échoue, continuer avec l'approche dynamique
      }
    }
    
    // Extraire l'ID numérique si possible
    String numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericId.isEmpty) {
      numericId = '1'; // Fallback sur l'ID 1 si aucun ID numérique n'est trouvé
    }
    
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