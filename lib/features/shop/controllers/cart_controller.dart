import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/User/models/cart_model.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  RxList<CartModel> cartItems = <CartModel>[].obs;
  RxDouble total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get current user's cart items when controller initializes
    final userId = AuthenticationRepository.instance.authUser?.uid;
    if (userId != null) {
      getCartItems(userId);
    }
  }

  Future<void> addToCart(CartModel item) async {
    try {
      await _db.collection('Carts').add(item.toJson());
      await getCartItems(item.userId);
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> getCartItems(String userId) async {
    try {
      final snapshot = await _db
          .collection('Carts')
          .where('userId', isEqualTo: userId)
          .get();
      
      cartItems.value = snapshot.docs
          .map((doc) => CartModel.fromJson(doc.data()))
          .toList();
      
      calculateTotal();
    } catch (e) {
      print('Error getting cart items: $e');
    }
  }

  void calculateTotal() {
    total.value = cartItems.fold(
      0, 
      (sum, item) => sum + (item.price * item.quantity)
    );
  }

  Future<void> updateItemQuantity(String productId, int change) async {
    try {
      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final newQuantity = cartItems[index].quantity + change;
        if (newQuantity > 0) {
          // Update local state
          cartItems[index].quantity = newQuantity;
          
          // Update Firestore
          final querySnapshot = await _db
              .collection('Carts')
              .where('productId', isEqualTo: productId)
              .where('userId', isEqualTo: cartItems[index].userId)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            await querySnapshot.docs.first.reference.update({
              'quantity': newQuantity
            });
          }

          cartItems.refresh();
          calculateTotal();
        } else {
          // If quantity becomes 0, remove item
          await removeFromCart(productId);
        }
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final querySnapshot = await _db
          .collection('Carts')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: AuthenticationRepository.instance.authUser?.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        cartItems.removeWhere((item) => item.productId == productId);
        calculateTotal();
      }
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  Future<void> clearAllItems() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) return;

      final batch = _db.batch();
      
      // Get all cart items for user
      final snapshot = await _db
          .collection('Carts')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete all in batch
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      
      // Clear local cart
      cartItems.clear();
      calculateTotal();
      
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
