import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/User/models/cart_model.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  RxList<CartModel> cartItems = <CartModel>[].obs;
  RxDouble total = 0.0.obs;
  RxInt tempQuantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final userId = AuthenticationRepository.instance.authUser?.uid;
    if (userId != null) {
      getCartItems(userId);
    }
  }

  void incrementTempQuantity(int maxStock) {
    if (tempQuantity.value < maxStock) {
      tempQuantity.value++;
    }
  }

  void decrementTempQuantity() {
    if (tempQuantity.value > 1) {
      tempQuantity.value--;
    }
  }

  void resetTempQuantity() {
    tempQuantity.value = 1;
  }

  Future<void> addToCart(CartModel newItem) async {
    try {
      debugPrint('Adding item to cart: ${newItem.productName}');
      
      // Check Firestore first
      final querySnapshot = await _db
          .collection('Carts')
          .where('productId', isEqualTo: newItem.productId)
          .where('userId', isEqualTo: newItem.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        final docId = docRef.id;
        
        // Update Firestore
        await _db.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          final currentQuantity = snapshot.data()?['quantity'] ?? 0;
          transaction.update(docRef, {
            'quantity': currentQuantity + newItem.quantity
          });
        });

        // Update RTDB
        try {
          await _rtdb.child('carts/$docId').update({
            'quantity': (querySnapshot.docs.first.data()['quantity'] ?? 0) + newItem.quantity
          });
        } catch (rtdbError) {
          print('RTDB Update failed: $rtdbError');
        }
      } else {
        // Add new item to Firestore
        final docRef = _db.collection('Carts').doc();
        final cartData = {
          ...newItem.toJson(),
          'id': docRef.id,
        };
        
        await docRef.set(cartData);

        // Add to RTDB
        try {
          await _rtdb.child('carts/${docRef.id}').set(cartData);
        } catch (rtdbError) {
          print('RTDB Save failed: $rtdbError');
        }
      }

      await getCartItems(newItem.userId);
      calculateTotal();
      
      debugPrint('Successfully added to cart');
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  // Future<void> addToCart(CartModel newItem) async {
  //   try {
  //     debugPrint('Adding item to cart: ${newItem.productName}');
      
  //     final querySnapshot = await _db
  //         .collection('Carts')
  //         .where('productId', isEqualTo: newItem.productId)
  //         .where('userId', isEqualTo: newItem.userId)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       final docRef = querySnapshot.docs.first.reference;
        
  //       await _db.runTransaction((transaction) async {
  //         final snapshot = await transaction.get(docRef);
  //         final currentQuantity = snapshot.data()?['quantity'] ?? 0;
  //         transaction.update(docRef, {
  //           'quantity': currentQuantity + newItem.quantity
  //         });
  //       });
  //     } else {
  //       await _db.collection('Carts').add(newItem.toJson());
  //     }

  //     await getCartItems(newItem.userId);
  //     calculateTotal();
      
  //     debugPrint('Successfully added to cart');
  //   } catch (e) {
  //     debugPrint('Error adding to cart: $e');
  //     rethrow;
  //   }
  // }

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
      debugPrint('Error getting cart items: $e');
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
          final querySnapshot = await _db
              .collection('Carts')
              .where('productId', isEqualTo: productId)
              .where('userId', isEqualTo: cartItems[index].userId)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            await querySnapshot.docs.first.reference.update({
              'quantity': newQuantity
            });
            
            cartItems[index].quantity = newQuantity;
            cartItems.refresh();
            calculateTotal();
          }
        } else {
          await removeFromCart(productId);
        }
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
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

  // Future<void> removeFromCart(String productId) async {
  //   try {
  //     final querySnapshot = await _db
  //         .collection('Carts')
  //         .where('productId', isEqualTo: productId)
  //         .where('userId', isEqualTo: AuthenticationRepository.instance.authUser?.uid)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       await querySnapshot.docs.first.reference.delete();
  //       cartItems.removeWhere((item) => item.productId == productId);
  //       calculateTotal();
  //     }
  //   } catch (e) {
  //     print('Error removing item from cart: $e');
  //   }
  // }

  Future<void> clearAllItems() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      debugPrint('Starting cart clear process...');

      // Clear from Firestore
      final batch = _db.batch();
      final snapshot = await _db
          .collection('Carts')
          .where('userId', isEqualTo: userId)
          .get();

      // Add all deletes to batch
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        // Delete from RTDB
        try {
          await _rtdb.child('carts/${doc.id}').remove();
        } catch (rtdbError) {
          print('RTDB Delete failed for ${doc.id}: $rtdbError');
        }
      }
      await batch.commit();
      cartItems.clear();
      total.value = 0;
      update();
      
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  // Future<void> clearAllItems() async {
  //   try {
  //     final userId = AuthenticationRepository.instance.authUser?.uid;
  //     if (userId == null) throw 'User not authenticated';

  //     debugPrint('Starting cart clear process...');
  //     debugPrint('Current cart items: ${cartItems.length}');

  //     // Use batch for atomic operation
  //     final batch = _db.batch();
      
  //     final snapshot = await _db
  //         .collection('Carts')
  //         .where('userId', isEqualTo: userId)
  //         .get();

  //     debugPrint('Found ${snapshot.docs.length} items to delete');

  //     // Add all deletes to batch
  //     for (var doc in snapshot.docs) {
  //       batch.delete(doc.reference);
  //     }

  //     // Commit batch
  //     await batch.commit();

  //     // Clear local state
  //     cartItems.clear();
  //     total.value = 0;
      
  //     debugPrint('Cart cleared. Items count: ${cartItems.length}');
  //     debugPrint('Cart total: ${total.value}');

  //     // Force UI refresh
  //     update();
  //     Get.forceAppUpdate(); // Force global UI update
      
  //   } catch (e) {
  //     debugPrint('Error clearing cart: $e');
  //     rethrow;
  //   }
  // }
}
