class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> categories;
  final bool isEcoFriendly;
  final double? discountPercentage;
  final bool hasCoupon;
  final String? merchantUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categories,
    this.isEcoFriendly = false,
    this.discountPercentage,
    this.hasCoupon = false,
    this.merchantUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      isEcoFriendly: json['isEcoFriendly'] ?? false,
      discountPercentage: json['discountPercentage']?.toDouble(),
      hasCoupon: json['hasCoupon'] ?? false,
      merchantUrl: json['merchantUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categories': categories,
      'isEcoFriendly': isEcoFriendly,
      'discountPercentage': discountPercentage,
      'hasCoupon': hasCoupon,
      'merchantUrl': merchantUrl,
    };
  }
}
