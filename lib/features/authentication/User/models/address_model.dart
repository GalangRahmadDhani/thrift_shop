import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String street;
  final String postalCode;
  final String city;
  final String state;
  final bool isActive;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.state,
    this.isActive = false,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'street': street,
      'postalCode': postalCode,
      'city': city,
      'state': state,
      'isActive': isActive,
    };
  }

  // Factory method to create AddressModel from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      street: json['street'] ?? '',
      postalCode: json['postalCode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  factory AddressModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      street: data['street'] ?? '',
      postalCode: data['postalCode'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      isActive: data['isActive'] ?? false,
    );
  }

  // Create a copy of AddressModel with some fields changed
  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    String? street,
    String? postalCode,
    String? city,
    String? state,
    bool? isActive,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      state: state ?? this.state,
      isActive: isActive ?? this.isActive,
    );
  }
}