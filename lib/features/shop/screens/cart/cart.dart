import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:ecommerce_app/features/shop/screens/checkout/checkout.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
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
        showBackArrow: true,
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
            final user = userController.user.value;
            
            // Format customer details sesuai Postman
            final customerDetails = {
              'first_name': user.firstName,
              'last_name': user.lastName,  // Tambahkan last name
              'email': user.email,
              'phone': user.phoneNumber,
            };

            // Format items sesuai Postman
            final items = cartController.cartItems.map((item) => {
              'id': item.productId,
              'name': item.productName,
              'price': item.price.toInt(),
              'quantity': item.quantity,
            }).toList();

            final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
            
            // Get payment token from backend
            final token = await paymentController.getPaymentToken(
              orderId: orderId,
              amount: cartController.total.value.toInt(),
              customerDetails: customerDetails,
              items: items,
            );

            if (token != null) {
              paymentController.showMidtransPayment(
                token: token,
                orderId: orderId,
                onPageFinished: (url) {
                  debugPrint('Payment page finished: $url');
                },
                onResponse: (result) {
                  debugPrint('Payment completed: ${result.toJson()}');
                  Get.back();
                  // Handle successful payment (clear cart, update order status, etc)
                },
              );
            } else {
              Get.snackbar(
                'Error',
                'Failed to initiate payment. Please try again.',
                backgroundColor: Colors.red.withOpacity(0.1),
                colorText: Colors.red,
              );
            }
          },
          child: Text('Checkout ${currencyFormatter.format(cartController.total.value)}'),
        )),
      ),
    );
  }
}



