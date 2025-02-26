import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:ecommerce_app/navigation_menu.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/payment_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final paymentController = Get.put(PaymentController());
    final userController = Get.put(UserController());
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Scaffold(
      appBar: TAppBar(
        // showBackArrow: true,
        leadingIcon: Icons.arrow_back,
        leadingOnPressed: () => Get.to(() => const NavigationMenu()),
        title: Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: const Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: TCartItems(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() => ElevatedButton(
          onPressed: () async {
            try {
              final user = userController.user.value;
              final cartItems = cartController.cartItems;
              
              if (cartItems.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Cart is empty',
                  backgroundColor: Colors.red.withOpacity(0.1),
                );
                return;
              }

              final userId = user.id;
              final timestamp = DateTime.now().millisecondsSinceEpoch; 
              final orderId = '$userId | $timestamp' ;
              // final orderId = userId + '_ORDER_' +timestamp.toString() ;
              
              // Create order first
              await FirebaseFirestore.instance.collection('Orders').doc(orderId).set({
                'orderId': orderId,
                'userId': userId,
                'items': cartItems.map((item) => {
                  'productId': item.productId,
                  'name': item.productName,
                  'price': item.price,
                  'quantity': item.quantity,
                }).toList(),
                'total': cartController.total.value,
                'status': 'PENDING',
                'createdAt': FieldValue.serverTimestamp(),
              });

              // Format customer details & proceed with payment
              final customerDetails = {
                'first_name': user.firstName,
                'last_name': user.lastName,
                'email': user.email,
                'phone': user.phoneNumber,
              };

              final items = cartItems.map((item) => {
                'id': item.productId,
                'name': item.productName,
                'price': item.price.toInt(),
                'quantity': item.quantity,
              }).toList();

              final token = await paymentController.getPaymentToken(
                orderId: orderId,
                amount: cartController.total.value.toInt(),
                customerDetails: customerDetails,
                items: items,
              );

              if (token != null) {
                // Remove await since showMidtransPayment is void
                paymentController.showMidtransPayment(
                  token: token,
                  orderId: orderId,
                );
              }
            } catch (e) {
              debugPrint('Error processing checkout: $e');
              Get.snackbar(
                'Error',
                'Failed to process checkout: $e',
                backgroundColor: Colors.red.withOpacity(0.1),
              );
            }
          },
          child: Text('Checkout ${currencyFormatter.format(cartController.total.value)}'),
        )),
      ),
    );
  }
}



