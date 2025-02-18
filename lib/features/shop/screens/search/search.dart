import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: const Text('Cari Produk'),
        actions: [
          TCartCounterIcon(
            onPressed: () {}, // Add empty callback instead of null
            iconColor: TColors.black,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Search TextField
              TextFormField(
                controller: controller.searchController,
                onChanged: (query) => controller.searchProducts(query),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.search_normal),
                  hintText: 'Cari di Toko...',
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  filled: true,
                  fillColor: dark ? TColors.dark : TColors.light,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    borderSide: const BorderSide(color: TColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    borderSide: const BorderSide(color: TColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    borderSide: const BorderSide(color: TColors.primary),
                  ),
                ),
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Results Count & Grid
              Obx(() {
                if (controller.isSearching.value) {
                  return Column(
                    children: [
                      // Results count
                      Text(
                        '${controller.searchResults.length} hasil ditemukan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      // Search Results Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.searchResults.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: TSizes.gridViewSpacing,
                          crossAxisSpacing: TSizes.gridViewSpacing,
                          mainAxisExtent: 288,
                        ),
                        itemBuilder: (_, index) => TProductCardVertical(
                          product: controller.searchResults[index],
                        ),
                      ),
                    ],
                  );
                }
                
                // Show empty state or initial state
                return const Center(
                  child: Text('Cari produk yang Anda inginkan'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}