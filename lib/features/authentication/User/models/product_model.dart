import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int price; // Change from double to int
  final int? salePrice; // Change from double to int
  final bool isSale;
  final String brandId;    // Ganti brand dengan brandId
  final String categoryId; // Ganti category dengan categoryId
  final Map<String, int> sizes;
  final String color;
  final int stock; // Add this field
  final bool isAvailable;
  
  // New tracking fields
  final int totalSales;
  final double rating;
  final int reviewCount;
  final DateTime lastSaleAt;
  final int viewCount;
  final int? discountPercentage; // Menambahkan persentase diskon
  final bool isFavorite; // Add this new field
  final List<String> favoriteByUsers; // Add this field to track users who favorited

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    this.salePrice,
    this.isSale = false,
    required this.brandId,    // Update constructor
    required this.categoryId, // Update constructor
    required this.sizes,
    required this.color,
    required this.stock, // Add this parameter
    this.isAvailable = true,
    this.totalSales = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.lastSaleAt,
    this.viewCount = 0,
    this.discountPercentage,
    this.isFavorite = false,
    this.favoriteByUsers = const [],
  });

  // Hanya simpan method yang benar-benar terkait dengan model
  bool get isPopular => calculateIsPopular();

  bool calculateIsPopular() {
    return totalSales > 1 || 
           (rating > 4.0 && reviewCount > 5) || 
           viewCount > 5;
  }

  double get finalPrice {
    if (!isSale || discountPercentage == null) return price.toDouble();
    final discount = (price * discountPercentage! / 100);
    return price.toDouble() - discount;
  }

  // Static helper method untuk sorting
  static List<ProductModel> sortByPopularity(List<ProductModel> products) {
    return products..sort((a, b) {
      int salesCompare = b.totalSales.compareTo(a.totalSales);
      if (salesCompare != 0) return salesCompare;
      int ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.viewCount.compareTo(a.viewCount);
    });
  }

  // Static function to create an empty product model.
  static ProductModel empty() => ProductModel(
    id: "",
    name: "",
    description: "",
    images: [],
    price: 0,
    salePrice: null,
    isSale: false,
    brandId: "",    // Update field names
    categoryId: "", // Update field names
    sizes: {},
    color: "",
    stock: 0, // Add this
    isAvailable: true,
    totalSales: 0,
    rating: 0.0,
    reviewCount: 0,
    lastSaleAt: DateTime.now(),
    viewCount: 0,
    discountPercentage: null,
    isFavorite: false,
    favoriteByUsers: [],
  );

  // Update toJson method
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'images': images,
    'price': price,
    'salePrice': salePrice,
    'isSale': isSale,
    'brandId': brandId,       // Update field names
    'categoryId': categoryId, // Update field names
    'sizes': sizes,
    'color': color,
    'stock': stock, // Add this
    'isAvailable': isAvailable,
    'totalSales': totalSales,
    'rating': rating,
    'reviewCount': reviewCount,
    'lastSaleAt': lastSaleAt.toIso8601String(),
    'viewCount': viewCount,
    'discountPercentage': discountPercentage,
    'isFavorite': isFavorite,
    'favoriteByUsers': favoriteByUsers,
  };

  // Update fromJson factory
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toInt(), // Convert to integer
      salePrice: json['salePrice']?.toInt(), // Convert to integer
      isSale: json['isSale'] ?? false,
      brandId: json['brandId'] ?? '',       // Update field names
      categoryId: json['categoryId'] ?? '', // Update field names
      sizes: Map<String, int>.from(json['sizes'] ?? {}),
      color: json['color'] ?? '',
      stock: (json['stock'] ?? 0) as int, // Fix stock parsing
      isAvailable: json['isAvailable'] ?? true,
      totalSales: json['totalSales'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      lastSaleAt: json['lastSaleAt'] != null 
          ? DateTime.parse(json['lastSaleAt']) 
          : DateTime.now(),
      viewCount: json['viewCount'] ?? 0,
      discountPercentage: json['discountPercentage'],
      isFavorite: json['isFavorite'] ?? false,
      favoriteByUsers: List<String>.from(json['favoriteByUsers'] ?? []),
    );
  }

  // Update fromSnapshot factory
  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    print('Raw product data: $data'); // Debug print
    return ProductModel(
      id: document.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toInt(), // Convert to integer
      salePrice: data['salePrice']?.toInt(), // Convert to integer
      isSale: data['isSale'] ?? false,
      brandId: data['brandId'] ?? '',       // Update field names
      categoryId: data['categoryId'] ?? '', // Update field names
      sizes: Map<String, int>.from(data['sizes'] ?? {}),
      color: data['color'] ?? '',
      stock: (data['stock'] ?? 0) as int, // Fix stock parsing
      isAvailable: data['isAvailable'] ?? true,
      totalSales: data['totalSales'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      lastSaleAt: data['lastSaleAt'] != null 
          ? DateTime.parse(data['lastSaleAt']) 
          : DateTime.now(),
      viewCount: data['viewCount'] ?? 0,
      discountPercentage: data['discountPercentage'],
      isFavorite: data['isFavorite'] ?? false,
      favoriteByUsers: List<String>.from(data['favoriteByUsers'] ?? []),
    );
  }

  // Add helper method
  bool isFavoritedBy(String userId) {
    return favoriteByUsers.contains(userId);
  }
}