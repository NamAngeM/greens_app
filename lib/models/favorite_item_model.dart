import 'package:greens_app/models/product_model.dart';

class FavoriteItemModel {
  final ProductModel product;
  int quantity;
  DateTime addedAt;

  FavoriteItemModel({
    required this.product,
    this.quantity = 1,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      'product': product.toJson(),
    };
  }

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
} 