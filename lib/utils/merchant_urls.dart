import 'package:greens_app/models/merchant_info.dart';

class MerchantUrls {
  static const Map<String, MerchantInfo> productMerchants = {
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
  
  static MerchantInfo? getMerchantForProduct(String productId) {
    return productMerchants[productId];
  }
} 