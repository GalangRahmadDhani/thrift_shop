import 'package:ecommerce_app/features/shop/screens/cart/cart.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';

class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key, 
    required this.onPressed, 
    this.iconColor = TColors.black,
  });

  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not exists
    final cartController = Get.put(CartController());
    
    return Padding(
      padding: const EdgeInsets.only(right: 16.0), // Tambahkan padding untuk geser keseluruhan stack
      child: Stack(
        children: [
          IconButton(
            onPressed: () => Get.to(() => const CartScreen()), 
            icon: Icon(
              Iconsax.shopping_cart, 
              color: iconColor,
            )
          ),
          Positioned(
            right: 0,  // Diubah dari 0 ke 8 untuk menggeser ke kiri
            top: 8,    // Ditambahkan untuk menyesuaikan posisi vertikal
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: TColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                // Use Obx to observe changes in cart items count
                child: Obx(() => Text(
                  '${cartController.cartItems.length}',
                  style: Theme.of(context).textTheme.labelLarge!
                  .apply(
                    color: TColors.white,
                    fontSizeFactor: 0.8
                  ),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}