import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),  // Convert to Timestamp for Firestore
      'updatedAt': Timestamp.fromDate(updatedAt),  
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  Map<String, dynamic> toRtdbJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,  // Convert to timestamp for RTDB
      'updatedAt': updatedAt.millisecondsSinceEpoch,  // Convert to timestamp for RTDB
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  // Create model from RTDB snapshot
  factory BannerModel.fromRtdb(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
    );
  }

  // Create model from JSON
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
    );
  }

  // Create empty banner model
  static BannerModel empty() => BannerModel(
        id: '',
        imageUrl: '',
        title: '',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: '',
        updatedBy: '',
      );

  // Copy with method for updating banner
  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
