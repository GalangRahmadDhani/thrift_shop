class CartModel {
  final String? id;
  final String productId;
  final String productName;
  final double price;
  final String image;
  int quantity;
  final String userId;

  CartModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.image,
    this.quantity = 1,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'image': image,
      'quantity': quantity,
      'userId': userId,
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      userId: json['userId'] ?? '',
    );
  }
}
