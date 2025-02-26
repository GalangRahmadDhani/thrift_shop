import 'package:ecommerce_app/common/widgets/icons/circular_icon.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/features/authentication/User/models/cart_model.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:get/get.dart';

class TBottomAddToCart extends StatelessWidget {
  final ProductModel product;
  final cartController = Get.find<CartController>();
  // Add a loading state
  final _isLoading = false.obs;

  TBottomAddToCart({
    super.key,
    required this.product,
  });

  Future<void> _addToCart() async {
    // Prevent multiple clicks while processing
    if (_isLoading.value) return;
    
    try {
      _isLoading.value = true;
      
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'Please login first to add items to cart',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: TColors.white,
        );
        return;
      }

      // Add debug print to check current cart state
      print('Current cart items before adding: ${cartController.cartItems.length}');
      
      final cartItem = CartModel(
        productId: product.id,
        productName: product.name,
        price: product.isSale 
            ? (product.salePrice ?? 0).toDouble()
            : (product.price ?? 0).toDouble(),
        image: product.images.isNotEmpty ? product.images[0] : '',
        userId: userId,
        quantity: cartController.tempQuantity.value,
      );

      await cartController.addToCart(cartItem);
      
      // Add debug print to check cart state after adding
      print('Cart items after adding: ${cartController.cartItems.length}');
      
      cartController.resetTempQuantity();
      Get.snackbar(
        'Success',
        '${product.name} added to cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: TColors.primary,
        colorText: TColors.white,
      );
    } catch (error) {
      print('Error adding to cart: $error');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: TColors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.defaultSpace/2),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TCircularIcon(
                icon: Iconsax.minus,
                backgroundColor: TColors.darkGrey,
                width: 40,
                height: 40,
                color: TColors.white,
                onPressed: () => cartController.decrementTempQuantity(),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Obx(() => Text(
                '${cartController.tempQuantity.value}',
                style: Theme.of(context).textTheme.titleSmall,
              )),
              const SizedBox(width: TSizes.spaceBtwItems),
              TCircularIcon(
                icon: Iconsax.add,
                backgroundColor: TColors.black,
                width: 40,
                height: 40,
                color: TColors.white,
                onPressed: () => cartController.incrementTempQuantity(product.stock),
              ),
            ],
          ),
          Obx(() => ElevatedButton(
            onPressed: product.stock > 0 && !_isLoading.value ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: product.stock > 0 ? TColors.black : Colors.grey,
              side: BorderSide(color: product.stock > 0 ? TColors.black : Colors.grey)
            ),
            child: Text(
              _isLoading.value 
                ? 'Adding...' 
                : (product.stock > 0 ? 'Add to Cart' : 'Out of Stock'),
            ),
          )),
        ],
      ),
    );
  }
}