import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/common/widgets/success_screen/success_screen.dart';
import 'package:ecommerce_app/data/repositories/address/address_repository.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/navigation_menu.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:midtrans_snap/midtrans_snap.dart';
import 'package:midtrans_snap/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';

  enum PaymentStatus {
    initial,
    processing,
    pendingVerification,
    completed,
    failed,
    canceled
  }


class PaymentController extends GetxController {
  static const String serverKey = 'SB-Mid-server-Uxiw1HjpgtxVDoz2Ceu-1Xbs';
  static const String midtransApiUrl = 'https://api.sandbox.midtrans.com/v2';
  static const String clientKey = 'SB-Mid-client-1Kdg4XRvWoDqlrFn';
  static const String backendUrl = 'https://thrift-shop-midtrans.vercel.app/api/payment';
  
  final isLoading = false.obs;
  final Rx<PaymentStatus> paymentStatus = PaymentStatus.initial.obs;
  final userController = Get.put(UserController());
  final Set<String> _processedOrders = {};

  // Add CartController instance
  final cartController = Get.put(CartController());

  Future<String?> getPaymentToken({
    required String orderId,
    required int amount,
    required Map<String, dynamic> customerDetails,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final requestBody = {
        'order_id': orderId,
        'gross_amount': amount,
        'customer_details': customerDetails,
        'items': items
      };

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }

      throw 'Failed to generate payment token: ${response.statusCode}';
    } catch (e) {
      debugPrint('Error generating payment token: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize payment',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return null;
    }
  }

  void showMidtransPayment({
    required String token,
    required String orderId,
  }) {
    Get.to(() => PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final result = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Cancel Payment?'),
                  content: const Text('Are you sure you want to cancel this payment?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
              
              if (result == true) {
                paymentStatus.value = PaymentStatus.canceled;
                Get.back();
              }
            },
          ),
        ),
        body: MidtransSnap(
          mode: MidtransEnvironment.sandbox,
          token: token,
          midtransClientKey: clientKey,
          onPageStarted: (url) => debugPrint('Payment page started: $url'),
          onResponse: (result) async {
            await handlePaymentResponse(result.toJson(), orderId);
          },
        ),
      ),
    ));
  }

  Future<void> handleMidtransStatus(Map<String, dynamic> statusData, String orderId) async {
    try {
      final statusCode = statusData['status_code']?.toString();
      final transactionStatus = statusData['transaction_status']?.toString();
      final timestamp = DateTime.now();

      debugPrint('Processing status - Code: $statusCode, Status: $transactionStatus');

      // Always save transaction data regardless of status
      await saveTransactionToFirestore(orderId, statusData);

      if (statusCode == '200' || 
          transactionStatus == 'settlement' || 
          transactionStatus == 'capture') {
        
        final verificationResult = await verifyPaymentWithMidtrans(orderId);
        
        if (verificationResult) {
          await updateTransactionStatus(orderId, 'PAID', 'Pembayaran Berhasil', statusData);
          navigateToSuccessScreen(orderId);
        } else {
          handlePaymentError('Payment verification failed');
        }
      }
      // Handle pending status
      else if (statusCode == '201' || transactionStatus == 'pending') {
        await updateTransactionStatus(orderId, 'PENDING', 'Menunggu Pembayaran', statusData);
        handlePendingPayment();
      }
      // Handle failed or cancelled status
      else if (statusCode == '202' || 
              ['deny', 'cancel', 'expire', 'failure'].contains(transactionStatus)) {
        await updateTransactionStatus(orderId, 'FAILED', 'Pembayaran Gagal', statusData);
        handlePaymentError('Payment was not successful');
      }
    } catch (e) {
      debugPrint('Error in handleMidtransStatus: $e');
      throw 'Failed to handle payment status: $e';
    }
  }

Future<void> updateTransactionStatus(String orderId, String status, String statusPesanan, Map<String, dynamic> statusData) async {
  try {
    final userId = AuthenticationRepository.instance.authUser?.uid;
    final timestamp = DateTime.now();
    final orderTimestamp = orderId.split('_ORDER_').last;
    final transactionDocId = '${userId}_TRX_ORDER_$orderTimestamp';

    final statusUpdate = {
      'status': status,
      'statusPesanan': statusPesanan,
      'updatedAt': timestamp.toIso8601String(),
      'statusData': statusData,
    };

    // Update both Firestore and RTDB
    await Future.wait([
      // Update Firestore Transaction
      FirebaseFirestore.instance
          .collection('Transactions')
          .doc(transactionDocId)
          .update(statusUpdate),
      
      // Update RTDB Transaction
      FirebaseDatabase.instance
          .ref()
          .child('transactions/$transactionDocId')
          .update(statusUpdate),

      // Update Firestore Order
      FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({
            'status': status,
            'statusPesanan': statusPesanan,
            'statusHistory': FieldValue.arrayUnion([{
              'status': status,
              'timestamp': timestamp.toIso8601String(),
              'updatedBy': userId,
            }])
          }),

      // Update RTDB Order
      FirebaseDatabase.instance
          .ref()
          .child('orders/$orderId')
          .update({
            'status': status,
            'statusPesanan': statusPesanan,
            'statusHistory': [{
              'status': status,
              'timestamp': timestamp.toIso8601String(),
              'updatedBy': userId,
            }]
          })
    ]);

    debugPrint('Successfully updated status to $status in both databases');
  } catch (e) {
    debugPrint('Error updating transaction status: $e');
    throw 'Failed to update transaction status: $e';
  }
}


  // Future<void> handleMidtransStatus(Map<String, dynamic> statusData, String orderId) async {
  //   final statusCode = statusData['status_code']?.toString();
  //   final transactionStatus = statusData['transaction_status']?.toString();

  //   debugPrint('Processing status - Code: $statusCode, Status: $transactionStatus');

  //   if (statusCode == '200' || 
  //       transactionStatus == 'settlement' || 
  //       transactionStatus == 'capture') {
      
  //     final verificationResult = await verifyPaymentWithMidtrans(orderId);
      
  //     if (verificationResult) {
  //       await saveTransactionToFirestore(orderId, statusData);
  //       navigateToSuccessScreen(orderId);
  //     } else {
  //       handlePaymentError('Payment verification failed');
  //     }
  //   }
  //   // Handle pending status
  //   else if (statusCode == '201' || transactionStatus == 'pending') {
  //     handlePendingPayment();
  //   }
  //   // Handle failed or cancelled status
  //   else if (statusCode == '202' || 
  //           ['deny', 'cancel', 'expire', 'failure'].contains(transactionStatus)) {
  //     handlePaymentError('Payment was not successful');
  //   }
  //   // Handle unknown status with more detailed error message
  //   else {
  //     handlePaymentError(
  //       'Unrecognized payment status. Code: ${statusCode ?? "null"}, '
  //       'Status: ${transactionStatus ?? "null"}. Please check your payment status.'
  //     );
  //   }
  // }

    Future<void> handlePaymentResponse(dynamic responseData, String orderId) async {
      try {
        // Add logging to see the complete response
        debugPrint('Raw payment response: $responseData');
        
        // If responseData is null or empty, check Midtrans status directly
        if (responseData == null || (responseData is Map && responseData.isEmpty)) {
          final transactionData = await checkMidtransStatus(orderId);
          if (transactionData != null) {
            return await handleMidtransStatus(transactionData, orderId);
          } else {
            throw 'Unable to fetch transaction status';
          }
        }

        // Convert dynamic map to Map<String, dynamic>
        final Map<String, dynamic> result = Map<String, dynamic>.from(responseData);
        
        final statusCode = result['status_code']?.toString();
        final transactionStatus = result['transaction_status']?.toString();
        
        debugPrint('Status Code: $statusCode');
        debugPrint('Transaction Status: $transactionStatus');

        // If status is not in the response, check Midtrans status
        if (statusCode == null || transactionStatus == null) {
          final transactionData = await checkMidtransStatus(orderId);
          if (transactionData != null) {
            return await handleMidtransStatus(transactionData, orderId);
          } else {
            throw 'Unable to fetch transaction status';
          }
        }

        // Process the response status
        await handleMidtransStatus(result, orderId);

      } catch (e) {
        debugPrint('Error handling payment response: $e');
        handlePaymentError('Failed to process payment response: $e');
      }
    }

  Future<bool> verifyPaymentWithMidtrans(String orderId) async {
    try {
      final transactionData = await checkMidtransStatus(orderId);
      
      if (transactionData != null) {
        final status = transactionData['transaction_status'];
        return status == 'settlement' || status == 'capture';
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    }
  }

  void handlePendingPayment() {
    Get.back();
    Get.snackbar(
      'Payment Pending',
      'Please complete your payment',
      backgroundColor: Colors.orange.withOpacity(0.1),
      duration: const Duration(seconds: 5),
    );
  }

  void handlePaymentError(String message) {
    Get.back();
    Get.snackbar(
      'Payment Failed',
      message,
      backgroundColor: Colors.red.withOpacity(0.1),
      duration: const Duration(seconds: 5),
    );
  }

  void navigateToSuccessScreen(String orderId) {
    Get.offAll(
      () => SuccessScreen(
        image: TImages.successFullyRegisterAnimation,
        title: 'Payment Success',
        subTitle: 'Your payment is being processed',
        onPressed: () => finalizeTransaction(orderId),
      ),
      predicate: (route) => false,
    );
  }

  Future<void> finalizeTransaction(String orderId) async {
    try {
      isLoading.value = true;
      debugPrint('Starting transaction finalization for orderId: $orderId'); // Add debug log

      // First check if Order exists
      final orderDoc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw 'Order document not found: $orderId';
      }

      // Check if user's Cart document exists
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId != null) {
        final cartDoc = await FirebaseFirestore.instance
            .collection('Carts')
            .doc(userId)
            .get();

        if (!cartDoc.exists) {
          // Create cart if it doesn't exist
          await FirebaseFirestore.instance
              .collection('Carts')
              .doc(userId)
              .set({'items': []});
        }
      }

      final transactionData = await checkMidtransStatus(orderId);
      if (transactionData == null) {
        throw 'Failed to fetch transaction data';
      }

      // Now perform the transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Save transaction details first
        await saveTransactionToFirestore(orderId, transactionData);
        
        // Then clear cart
        if (userId != null) {
          final cartRef = FirebaseFirestore.instance.collection('Carts').doc(userId);
          await cartRef.update({'items': []});
        }
        
        await cartController.clearAllItems();
      });

      // Navigate to home on success
      Get.offAll(() => const NavigationMenu());
      
    } catch (e) {
      debugPrint('Error in finalizeTransaction: $e');
      Get.snackbar(
        'Error',
        'Failed to process transaction: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> checkMidtransStatus(String orderId) async {
    try {
      final encodedAuth = base64Encode(utf8.encode('$serverKey:'));
      
      final response = await http.get(
        Uri.parse('$midtransApiUrl/$orderId/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $encodedAuth',
        },
      );

      debugPrint('Midtrans status check response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      
      debugPrint('Midtrans status check failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error checking Midtrans status: $e');
      return null;
    }
  }

Future<void> saveTransactionToFirestore(String orderId, Map<String, dynamic> transactionData) async {
  try {
    if (_processedOrders.contains(orderId)) {
      debugPrint('Order $orderId has already been processed. Skipping stock reduction.');
      return;
    }

    final userId = AuthenticationRepository.instance.authUser?.uid;
    final timestamp = DateTime.now();
    final orderTimestamp = orderId.split('_ORDER_').last;
    final batch = FirebaseFirestore.instance.batch();
    final _rtdb = FirebaseDatabase.instance.ref();

    final String transactionDocId = '${userId}_TRX_ORDER_$orderTimestamp';
    final String orderDocId = orderId;

    final addressRepository = Get.put(AddressRepository());
    final defaultAddress = await addressRepository.getUserDefaultAddress(userId ?? '');
    if (defaultAddress == null) {
      throw 'No default shipping address found';
    }

    // 1. Create Order document
    final orderData = {
      'orderId': orderId,
      'userId': userId,
      'createdAt': timestamp.toIso8601String(),
      'status': 'PENDING',
      'statusPesanan': 'Sedang Di Proses',
      'amount': transactionData['gross_amount'] ?? 0,
      'shippingAddress': defaultAddress.toJson(),
      'items': cartController.cartItems.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'price': item.price,
      }).toList(),
      'statusHistory': [
        {
          'status': 'Sedang Di Proses',
          'timestamp': timestamp.toIso8601String(),
          'updatedBy': userId,
        }
      ],
    };

    // Save to Firestore
    final orderRef = FirebaseFirestore.instance.collection('Orders').doc(orderDocId);
    await orderRef.set(orderData, SetOptions(merge: true));
    debugPrint('Order document created in Firestore');

    // Save to RTDB
    try {
      await _rtdb.child('orders/$orderDocId').set(orderData);
      debugPrint('Order document created in RTDB');
    } catch (rtdbError) {
      debugPrint('RTDB Order Save failed: $rtdbError');
    }

    // 2. Create Transaction document
    final transactionDetails = {
      'transactionId': transactionDocId,
      'orderId': orderId,
      'userId': userId,
      'paymentType': transactionData['payment_type'] ?? 'Unknown',
      'amount': transactionData['gross_amount'] ?? 0,
      'status': transactionData['transaction_status'] ?? 'PENDING',
      'createdAt': timestamp.toIso8601String(), // Convert DateTime to String for RTDB
      'year': timestamp.year,
      'month': timestamp.month,
      'day': timestamp.day,
      'bank': transactionData['bank'] ?? '',
      'midtransId': transactionData['transaction_id'] ?? '',
      'paymentTime': transactionData['transaction_time'],
      'settlementTime': transactionData['settlement_time'],
      'customerName': AuthenticationRepository.instance.authUser?.displayName ?? '',
      'customerEmail': AuthenticationRepository.instance.authUser?.email ?? '',
      'orderItems': cartController.cartItems.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'price': item.price,
      }).toList(),
    };

    // Save to Firestore
     // Only create transaction document if status is PAID
    final transactionStatus = transactionData['transaction_status']?.toString();
      if (transactionStatus == 'settlement' || transactionStatus == 'capture') {
        final transactionRef = FirebaseFirestore.instance
            .collection('Transactions')
            .doc(transactionDocId);
        await transactionRef.set(transactionDetails);
        debugPrint('Transaction document created in Firestore');

      // Save to RTDB
      try {
        await _rtdb.child('transactions/$transactionDocId').set(transactionDetails);
        debugPrint('Transaction document created in RTDB');
      } catch (rtdbError) {
        debugPrint('RTDB Transaction Save failed: $rtdbError');
      }
    }

    // Rest of your existing code...
  } catch (e) {
    debugPrint('Error in saveTransactionToFirestore: $e');
    throw 'Failed to save transaction: $e';
  }
}

  Future<void> clearCartAndUpdateOrder(String orderId) async {
    try {
      // Use the instance variable instead of Get.find
      await cartController.clearAllItems();

      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('Carts')
            .doc(userId)
            .update({'items': []});
      }
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}
