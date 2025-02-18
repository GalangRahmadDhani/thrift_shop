import 'package:ecommerce_app/common/widgets/brands/brand_showcase.dart';
import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:get/get.dart';

class TCategoryTab extends StatelessWidget {
  final String? category;
  
  const TCategoryTab({
    super.key,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            // Brands
            const TBrandShowcase(
              images: [
                TImages.productBaju2,
                TImages.productBaju2,
                TImages.productBaju1,
              ],
            ),
            const TBrandShowcase(
              images: [
                TImages.productBaju1,
                TImages.productBaju2,
                TImages.productBaju1,
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems,),
      
      
            // Products
            TSectionHeading(title: 'Anda Mungkin Suka', onPressed: (){},),
            const SizedBox(height: TSizes.spaceBtwItems,),
      
            // Products Grid with Obx
            Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = category != null 
                ? controller.products.where((p) => p.category == category).toList()
                : controller.products;

              if (products.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              return TGridLayout(
                itemCount: products.length,
                itemBuilder: (_, index) => TProductCardVertical(
                  product: products[index],
                ),
              );
            }),
            const SizedBox(height: TSizes.spaceBtwSections,),
          ],
        ),
      ),
      ],
      
    );
  }
}