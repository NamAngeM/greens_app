import 'package:greens_app/models/merchant_info.dart';

class MerchantUrls {
  static const Map<String, MerchantInfo> productMerchants = {
    // Produits avec les nouvelles URLs
    '1': MerchantInfo(
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/1',
      name: 'Green Commerce',
    ),
    '2': MerchantInfo(
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/2',
      name: 'Green Commerce',
    ),
    '3': MerchantInfo(
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/3',
      name: 'Green Commerce',
    ),
    '4': MerchantInfo(
      url: 'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app/produit/4',
      name: 'Green Commerce',
    ),
    '5': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/5',
      name: 'Green Commerce',
    ),
    '6': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/6',
      name: 'Green Commerce',
    ),
    '7': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/7',
      name: 'Green Commerce',
    ),
    '8': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/8',
      name: 'Green Commerce',
    ),
    '9': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/9',
      name: 'Green Commerce',
    ),
    '10': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/10',
      name: 'Green Commerce',
    ),
    '11': MerchantInfo(
      url: 'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app/produit/11',
      name: 'Green Commerce',
    ),
    
    // Conserver les anciens produits pour la rétrocompatibilité
    'amoseeds-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/amoseeds-chia-seeds',
      name: 'GreenMinds',
    ),
    'juneshine-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/juneshine-kombucha',
      name: 'GreenMinds',
    ),
    'jens-sorbet-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/jens-sorbet',
      name: 'GreenMinds',
    ),
    'amoseeds-2': MerchantInfo(
      url: 'https://www.greenminds.com/products/amoseeds-zen-bio',
      name: 'GreenMinds',
    ),
    'allbirds-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/allbirds-runners',
      name: 'GreenMinds',
    ),
    'organic-basics-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/organic-basics-tee',
      name: 'GreenMinds',
    ),
    'qapel-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/qapel-leather-bag',
      name: 'GreenMinds',
    ),
    'organic-basics-2': MerchantInfo(
      url: 'https://www.greenminds.com/products/organic-basics-black',
      name: 'GreenMinds',
    ),
    'ecobottle-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/ecobottle',
      name: 'GreenMinds',
    ),
    'lift-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/lift-ergonomic',
      name: 'GreenMinds',
    ),
    'mofpw-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/mofpw-keyboard',
      name: 'GreenMinds',
    ),
    'lenovo-1': MerchantInfo(
      url: 'https://www.greenminds.com/products/lenovo-thinkpad',
      name: 'GreenMinds',
    ),
  };
  
  /// Récupère les informations du marchand pour un produit donné
  static MerchantInfo? getMerchantForProduct(String productId) {
    // Essayer d'abord avec l'ID tel quel
    if (productMerchants.containsKey(productId)) {
      return productMerchants[productId];
    }
    
    // Si l'ID n'est pas trouvé directement, essayer de le convertir en format numérique
    // pour les nouveaux produits qui utilisent des IDs numériques
    try {
      final numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericId.isNotEmpty && productMerchants.containsKey(numericId)) {
        return productMerchants[numericId];
      }
    } catch (e) {
      print('Erreur lors de la conversion de l\'ID: $e');
    }
    
    // Si aucune correspondance n'est trouvée, retourner null
    return null;
  }
}