import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  String? id;
  String name;
  String? image;
  bool? isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;

  BrandModel({
    this.id,
    required this.name,
    this.image,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'isFeatured': isFeatured,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory BrandModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return BrandModel(
      id: document.id,
      name: data['name'] ?? '',
      image: data['image'],
      isFeatured: data['isFeatured'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }
}
