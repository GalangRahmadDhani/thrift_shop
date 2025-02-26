import 'package:ecommerce_app/common/widgets/custom_shape/container/primary_header_container.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/search_container.dart';
import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/authentication/User/models/banner_model.dart';
import 'package:ecommerce_app/features/shop/screens/all_products/all_products.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_categories.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_promo_slider.dart';
import 'package:ecommerce_app/features/shop/screens/search/search.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:ecommerce_app/features/shop/controllers/banner_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(ProductRepository());
    final productController = Get.put(ProductController());
    final bannerController = Get.put(BannerController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
             TPrimaryHeaderContainer(
              child: Column(
                children: [
                  // AppBar
                  const THomeAppBar(),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // SearchBar
                  TSearchContainer(
                    text: 'Cari di Toko...',
                    onTap: () => Get.to(() => const SearchScreen()),
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // Categories
                  const THomeCategories(),
                  const SizedBox(height: TSizes.defaultSpace,)
                ],
              ),
            ),

          // Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Promo Slider with StreamBuilder
                  StreamBuilder<List<BannerModel>>(
                    stream: bannerController.getBanners(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text('Error loading banners');
                      }

                      final activeBanners = snapshot.data
                          ?.where((banner) => banner.isActive)
                          .toList() ?? [];

                      if (activeBanners.isEmpty) {
                        return const SizedBox(); // Hide if no active banners
                      }

                      return TPromoSlider(banners: activeBanners);
                    },
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // Heading
                  TSectionHeading(title: 'Produk Kami', onPressed: () => Get.to(() => const AllProductsScreen())),
                  const SizedBox(
                    height: TSizes.spaceBtwSections /2,
                  ),

                  // Popular Products
                  Obx(() {
                    if (productController.loading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    print('Total products: ${productController.products.length}'); // Debugging

                    if (productController.products.isEmpty) {
                      return const Center(child: Text('No products available'));
                    }

                    // Get popular products - increase limit from 4 to desired number
                    final popularProducts = productController.products.toList()
                      ..sort((a, b) => (b.totalSales + (b.rating * b.reviewCount))
                          .compareTo(a.totalSales + (a.rating * a.reviewCount)));
                    final displayProducts = popularProducts.take(8).toList(); // Increased from 4 to 8

                    return Column(
                      children: [
                        Text('Showing ${displayProducts.length} of ${productController.products.length} products'), // Debugging
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
