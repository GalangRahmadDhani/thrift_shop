import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String? id;
  final String email;
  final String username;

  const AdminModel({
    this.id,
    required this.email,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'Email': email, // tetap menggunakan 'Email' sebagai key untuk Firestore
      'Username': username, // tetap menggunakan 'Username' sebagai key untuk Firestore
    };
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      email: json['Email'] ?? '', // mengambil dari key 'Email' di Firestore
      username: json['Username'] ?? '', // mengambil dari key 'Username' di Firestore
    );
  }

  factory AdminModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return AdminModel(
      id: document.id,
      email: data['Email'] ?? '', // mengambil dari key 'Email' di Firestore
      username: data['Username'] ?? '', // mengambil dari key 'Username' di Firestore
    );
  }

  AdminModel copyWith({
    String? id,
    String? email,
    String? username,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}
