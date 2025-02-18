import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';  // Add this import

import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  // Check if current user is admin
  Future<bool> _isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final adminDoc = await _db.collection('Admin').doc(user.uid).get();
    return adminDoc.exists;
  }

  // Save product (with both Firestore and RTDB)
  Future<void> saveProduct(ProductModel product) async {
    try {
      if (!await _isAdmin()) throw 'Unauthorized: Admin access required';

      final docRef = _db.collection('Products').doc();
      final now = DateTime.now();
      final productData = {
        ...product.toJson(),
        'id': docRef.id,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // First save to Firestore
      await docRef.set(productData);

      // Then try to save to RTDB
      try {
        await _rtdb.child('products/${docRef.id}').set(productData);
      } catch (rtdbError) {
        print('RTDB Save failed: $rtdbError');
        // Continue even if RTDB save fails
      }
    } catch (e) {
      throw 'Error saving product: $e';
    }
  }

  // Get all products (with both Firestore and RTDB)
  Future<List<ProductModel>> getAllProducts() async {
    try {
      print('Fetching products from Firestore...'); // Debugging
      final snapshot = await _db.collection('Products')
          .orderBy('createdAt', descending: true)
          .get();
          
      final products = snapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();

      print('Found ${products.length} products'); // Debugging
      products.forEach((product) {
        print('Product: ${product.name}, Images: ${product.images}'); // Debugging
      });

      // Only sync to RTDB if user is admin
      if (await _isAdmin()) {
        try {
          await _rtdb.child('products').set(
            products.map((product) => product.toJson()).toList()
          );
        } catch (rtdbError) {
          print('RTDB Sync failed: $rtdbError');
          // Continue even if RTDB sync fails
        }
      }

      return products;
    } catch (e) {
      print('Error fetching products: $e'); // Debugging
      throw 'Error fetching products: $e';
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _db.collection('Products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching category products: $e';
    }
  }

  // Upload image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      if (!await _isAdmin()) throw 'Unauthorized: Admin access required';
      
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }

  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      if (!await _isAdmin()) throw 'Unauthorized: Admin access required';
      
      await _db.collection('Products').doc(id).update({
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Error updating product: $e';
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      if (!await _isAdmin()) throw 'Unauthorized: Admin access required';
      await _db.collection('Products').doc(id).delete();
    } catch (e) {
      throw 'Error deleting product: $e';
    }
  }

  // Toggle product wishlist status
  Future<void> toggleWishlist(String productId, String userId) async {
    try {
      final docRef = _db.collection('Products').doc(productId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw 'Product not found';
      }

      final product = ProductModel.fromSnapshot(doc);
      final List<String> updatedFavoriteUsers = List<String>.from(product.favoriteByUsers);

      if (updatedFavoriteUsers.contains(userId)) {
        updatedFavoriteUsers.remove(userId);
      } else {
        updatedFavoriteUsers.add(userId);
      }

      await docRef.update({
        'favoriteByUsers': updatedFavoriteUsers,
      });

    } catch (e) {
      throw 'Error toggling wishlist: $e';
    }
  }

  // Get user's wishlist products
  Future<List<ProductModel>> getWishlistProducts(String userId) async {
    try {
      final snapshot = await _db.collection('Products')
          .where('favoriteByUsers', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching wishlist: $e';
    }
  }
}
