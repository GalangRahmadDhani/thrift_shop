import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'My Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.wishlistProducts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.heart, size: 64, color: Colors.grey),
                        SizedBox(height: TSizes.spaceBtwItems),
                        Text('Your wishlist is empty'),
                      ],
                    ),
                  );
                }

                return TGridLayout(
                  itemCount: controller.wishlistProducts.length,
                  itemBuilder: (_, index) => TProductCardVertical(
                    product: controller.wishlistProducts[index],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}