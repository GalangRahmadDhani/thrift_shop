class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String? userPhotoUrl;
  final String userName;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userPhotoUrl,
    required this.userName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'productId': productId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'userPhotoUrl': userPhotoUrl,
    'userName': userName,
  };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'],
    userId: json['userId'],
    productId: json['productId'],
    rating: json['rating'].toDouble(),
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
    userPhotoUrl: json['userPhotoUrl'],
    userName: json['userName'],
  );
}
