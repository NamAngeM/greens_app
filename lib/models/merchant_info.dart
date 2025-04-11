import 'package:flutter/foundation.dart';

class MerchantInfo {
  final String url;
  final String name;
  final String? logoUrl;
  
  const MerchantInfo({
    required this.url,
    required this.name,
    this.logoUrl,
  });
} 