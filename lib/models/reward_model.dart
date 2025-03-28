class RewardModel {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String? imageUrl;
  final String type; // 'coupon', 'badge', etc.
  final DateTime expiryDate;
  final String? productId; // Pour les coupons liés à des produits spécifiques
  final double discountPercentage; // Pour les coupons
  final bool isRedeemed;
  final String userId;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    this.imageUrl,
    required this.type,
    required this.expiryDate,
    this.productId,
    this.discountPercentage = 0,
    this.isRedeemed = false,
    required this.userId,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pointsCost: json['pointsCost'] ?? 0,
      imageUrl: json['imageUrl'],
      type: json['type'] ?? 'coupon',
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : DateTime.now().add(const Duration(days: 30)),
      productId: json['productId'],
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      isRedeemed: json['isRedeemed'] ?? false,
      userId: json['userId'] ?? '',
    );
  }

  get isUsed => null;

  get usedDate => null;

  get couponCode => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'imageUrl': imageUrl,
      'type': type,
      'expiryDate': expiryDate.toIso8601String(),
      'productId': productId,
      'discountPercentage': discountPercentage,
      'isRedeemed': isRedeemed,
      'userId': userId,
    };
  }
}
