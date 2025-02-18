import 'package:ecommerce_app/common/widgets/products/cart/add_remove_button.dart';
import 'package:ecommerce_app/common/widgets/products/cart/cart_item.dart';
import 'package:ecommerce_app/common/widgets/texts/product_price_text.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({
    super.key, 
    this.showAddRemoveButton = true,
  });

  final bool showAddRemoveButton;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
        itemCount: cartController.cartItems.length,
        itemBuilder: (_, index) => Column(
          children: [
            TCartItem(cartItem: cartController.cartItems[index]),
            if (showAddRemoveButton) const SizedBox(height: TSizes.spaceBtwItems),

            if (showAddRemoveButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 70),
                      TProductWithQuantityAddRemoveButton(
                        quantity: cartController.cartItems[index].quantity,
                        onIncrement: () => cartController.updateItemQuantity(
                          cartController.cartItems[index].productId, 
                          1
                        ),
                        onDecrement: () => cartController.updateItemQuantity(
                          cartController.cartItems[index].productId, 
                          -1
                        ),
                      ),
                    ],
                  ),
                  TProductPriceText(
                    price: currencyFormatter.format(
                      cartController.cartItems[index].price * 
                      cartController.cartItems[index].quantity
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
