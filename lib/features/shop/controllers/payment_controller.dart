import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/features/shop/models/transaction_status_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:midtrans_snap/midtrans_snap.dart';
import 'package:midtrans_snap/models.dart';
import '../../../data/repositories/payment/payment_repository.dart';
import '../../../features/authentication/User/models/payment_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentController extends GetxController {
  static const String clientKey = 'SB-Mid-client-1Kdg4XRvWoDqlrFn';
  
  // Update URL: hapus trailing slash dan ID yang tidak diperlukan
  static const String backendUrl = 'https://thrift-shop-midtrans.vercel.app/api/payment';
  static const String statusUrl = 'https://thrift-shop-midtrans.vercel.app/api/payment/status';
  final maxRetries = 3;
  final timeout = const Duration(minutes: 5);

  final isLoading = false.obs;

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

      debugPrint('=================== PAYMENT DEBUG ===================');
      debugPrint('URL: $backendUrl');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Tambahkan header untuk mencegah redirect
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(requestBody),
      );

      // Handle potential redirects
      if (response.statusCode == 308 || response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectResponse = await http.post(
            Uri.parse('$backendUrl$redirectUrl'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: jsonEncode(requestBody),
          );
          
          if (redirectResponse.statusCode == 200) {
            final data = jsonDecode(redirectResponse.body);
            return data['token'];
          }
        }
      }

      // Debug response
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('=================== END DEBUG =====================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          debugPrint('Token received successfully: $token');
          return token;
        }
        throw 'No token in response';
      }

      // If error, print detailed error information
      debugPrint('Error Response: ${response.body}');
      final errorBody = jsonDecode(response.body);
      throw 'Server error (${response.statusCode}): ${errorBody['error'] ?? 'Unknown error'}';
      
    } catch (e, stackTrace) {
      // Print both error and stack trace for debugging
      debugPrint('Error Details: $e');
      debugPrint('Stack Trace: $stackTrace');
      Get.snackbar(
        'Payment Error',
        'Detailed error: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 10), // Longer duration to read error
      );
      return null;
    }
  }

  Future<bool> checkPaymentStatus(String orderId) async {
    int retryCount = 0;
    final stopTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(stopTime)) {
      try {
        final response = await http.get(
          Uri.parse('$statusUrl/$orderId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['transaction_status'];

          if (status == 'settlement' || status == 'capture') {
            await _saveTransactionStatus(orderId, status, data['transaction_id']);
            await _clearCartAndUpdateOrder(orderId);
            return true;
          } else if (status == 'deny' || status == 'cancel' || status == 'expire') {
            return false;
          }
        } else {
          retryCount++;
          if (retryCount >= maxRetries) return false;
        }

        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Error checking payment status: $e');
        retryCount++;
        if (retryCount >= maxRetries) return false;
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    return false;
  }

  Future<void> _saveTransactionStatus(String orderId, String status, String transactionId) async {
    try {
      final transactionStatus = TransactionStatus(
        orderId: orderId,
        status: status,
        transactionId: transactionId,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('Transactions')
          .doc(orderId)
          .set(transactionStatus.toJson());
    } catch (e) {
      debugPrint('Error saving transaction status: $e');
    }
  }

  Future<void> _clearCartAndUpdateOrder(String orderId) async {
    try {
      final cartController = Get.find<CartController>();
      
      // Clear cart items
      await cartController.clearAllItems();
      
      // Update order status in your database
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({'status': 'paid'});

      Get.snackbar(
        'Sukses',
        'Pembayaran berhasil',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      debugPrint('Error clearing cart and updating order: $e');
    }
  }

  void showMidtransPayment({
    required String token,
    required String orderId,
    Function(String)? onPageFinished,
    Function(String)? onPageStarted,
    Function(dynamic)? onResponse,
  }) {
    Get.to(() => Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: MidtransSnap(
        mode: MidtransEnvironment.sandbox,
        token: token,
        midtransClientKey: clientKey,
        onPageFinished: (url) async {
          debugPrint('Payment Page Finished URL: $url');
          if (url.contains('status_code=200') || 
              url.contains('transaction_status=settlement')) {
            // Handle successful payment
            await _clearCartAndUpdateOrder(orderId);
            Get.back(); // Close payment page
          }
          onPageFinished?.call(url);
        },
        onPageStarted: (url) {
          debugPrint('Payment Page Started URL: $url');
          onPageStarted?.call(url);
        },
        onResponse: (result) async {
          debugPrint('Payment Result: ${result.toJson()}');
          // Check if payment is successful from result
          if (result.statusCode == '200' || 
              result.transactionStatus == 'settlement' ||
              result.transactionStatus == 'capture') {
            await _saveTransactionStatus(
              orderId,
              result.transactionStatus ?? 'success',
              result.transactionId ?? '',
            );
            await _clearCartAndUpdateOrder(orderId);
          }
          onResponse?.call(result);
          print(result);
        },
      ),
    ));
  }

  // Fungsi helper untuk menghapus cart
  void _clearCart(CartController cartController) async {
    try {
      // Hapus semua item dari cart
      for (var item in cartController.cartItems) {
        await cartController.removeFromCart(item.productId);
      }
      // Refresh total
      cartController.calculateTotal();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
