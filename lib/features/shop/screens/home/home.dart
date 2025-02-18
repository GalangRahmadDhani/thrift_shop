import 'package:ecommerce_app/common/widgets/custom_shape/container/primary_header_container.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/search_container.dart';
import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/shop/screens/all_products/all_products.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_categories.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_promo_slider.dart';
import 'package:ecommerce_app/features/shop/screens/search/search.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:ecommerce_app/data/repositories/product/product_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repository first, then controller
    Get.put(ProductRepository());
    final controller = Get.put(ProductController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
             TPrimaryHeaderContainer(
              child: Column(
                children: [
                  // AppBar
                  THomeAppBar(),
                  SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // SearchBar
                  TSearchContainer(
                    text: 'Cari di Toko...',
                    onTap: () => Get.to(() => const SearchScreen()),
                  ),
                  SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // Categories
                  THomeCategories(),
                  SizedBox(height: TSizes.defaultSpace,)
                ],
              ),
            ),

          // Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Promo Slider
                  const TPromoSlider(
                    banners: [
                      TImages.promoBanner1,
                      TImages.promoBanner1,
                      TImages.promoBanner3,
                    ],
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // Heading
                  TSectionHeading(title: 'Produk Popular', onPressed: () => Get.to(() => const AllProductsScreen())),
                  const SizedBox(
                    height: TSizes.spaceBtwSections /2,
                  ),

                  // Popular Products
                  Obx(() {
                    if (controller.loading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    print('Total products: ${controller.products.length}'); // Debugging

                    if (controller.products.isEmpty) {
                      return const Center(child: Text('No products available'));
                    }

                    // Get popular products - increase limit from 4 to desired number
                    final popularProducts = controller.products.toList()
                      ..sort((a, b) => (b.totalSales + (b.rating * b.reviewCount))
                          .compareTo(a.totalSales + (a.rating * a.reviewCount)));
                    final displayProducts = popularProducts.take(8).toList(); // Increased from 4 to 8

                    return Column(
                      children: [
                        Text('Showing ${displayProducts.length} of ${controller.products.length} products'), // Debugging
                        const SizedBox(height: TSizes.spaceBtwSections),
                        TGridLayout(
                          itemCount: displayProducts.length,
                          itemBuilder: (_, index) => TProductCardVertical(
                            product: displayProducts[index],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),  
          ],
        )
      ),
    );
  }
}
