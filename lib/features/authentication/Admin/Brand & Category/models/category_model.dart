import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String? id;
  String name;
  String? image;
  String? parentId;
  bool? isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    this.image,
    this.parentId,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parentId': parentId,
      'isFeatured': isFeatured,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return CategoryModel(
      id: document.id,
      name: data['name'] ?? '',
      image: data['image'],
      parentId: data['parentId'],
      isFeatured: data['isFeatured'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }
}
