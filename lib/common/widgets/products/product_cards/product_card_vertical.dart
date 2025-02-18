import 'package:ecommerce_app/common/styles/shadows.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/rounded_container.dart';
import 'package:ecommerce_app/common/widgets/icons/circular_icon.dart';
import 'package:ecommerce_app/common/widgets/images/t_rounded_image.dart';
import 'package:ecommerce_app/common/widgets/texts/brand_name_verified_icon.dart';
import 'package:ecommerce_app/common/widgets/texts/product_price_text.dart';
import 'package:ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:ecommerce_app/features/authentication/User/models/cart_model.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/product_detail.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';

class TProductCardVertical extends StatelessWidget {
  final ProductModel product;
  
  const TProductCardVertical({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final cartController = Get.find<CartController>();

    void addToCart() {
      // Get current user ID
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

      final cartItem = CartModel(
        productId: product.id,
        productName: product.name,
        price: product.isSale 
            ? (product.salePrice ?? 0).toDouble()  // Convert int? to double
            : (product.price ?? 0).toDouble(),     // Convert int? to double
        image: product.images.isNotEmpty ? product.images[0] : '',
        userId: userId, // Using actual user ID from authentication
      );

      cartController.addToCart(cartItem).then((_) {
        Get.snackbar(
          'Success',
          '${product.name} added to cart',
          snackPosition: SnackPosition.TOP,
          backgroundColor: TColors.primary,
          colorText: TColors.white,
        );
      }).catchError((error) {
        Get.snackbar(
          'Error',
          'Failed to add item to cart',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: TColors.white,
        );
      });
    }

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
      child: Container(
        width: 180,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          children: [
            // Thumbnail
            TRoundedContainer(
              height: 180,
              padding: EdgeInsets.zero,
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                    child: product.images.isNotEmpty 
                      ? Image.network(
                          product.images[0],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return const Center(
                              child: Icon(
                                Iconsax.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Iconsax.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                  ),

                  // Sale Tag
                  if (product.isSale && product.discountPercentage != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: TRoundedContainer(
                        radius: TSizes.sm,
                        backgroundColor: TColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm,
                          vertical: TSizes.xs,
                        ),
                        child: Text(
                          '${product.discountPercentage}%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .apply(color: TColors.white),
                        ),
                      ),
                    ),

                  // Favourite Icon
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: TCircularIcon(
                      icon: Iconsax.heart5,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Padding(
              padding: const EdgeInsets.only(left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(
                    title: product.name,
                    smallSize: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  TBrandTitleWithVerifiedIcon(title: product.brand),
                ],
              )
            ),

            const Spacer(),

            // Price & Add to Cart
            Padding(
              padding: const EdgeInsets.only(bottom: TSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Padding(
                    padding: const EdgeInsets.only(left: TSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isSale) ...[
                          TProductPriceText(
                            price: currencyFormatter.format(product.price),
                            isLarge: false,
                            lineThrough: true,
                          ),
                          TProductPriceText(
                            price: currencyFormatter.format(product.salePrice),
                            isLarge: false,
                          ),
                        ] else
                          TProductPriceText(
                            price: currencyFormatter.format(product.price),
                            isLarge: false,
                          ),
                      ],
                    ),
                  ),

                  // Replace the Container with GestureDetector
                  GestureDetector(
                    onTap: addToCart,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: TColors.dark,
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: const SizedBox(
                        width: TSizes.iconLg * 1.2,
                        height: TSizes.iconLg + 12,
                        child: Center(
                          child: Icon(
                            Iconsax.add,
                            color: TColors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}