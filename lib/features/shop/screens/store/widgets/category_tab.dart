import 'package:ecommerce_app/common/widgets/brands/brand_showcase.dart';
import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
      
            TGridLayout(itemCount: 4, itemBuilder: (_, index) => const TProductCardVertical()),
            const SizedBox(height: TSizes.spaceBtwSections,),
          ],
        ),
      ),
      ],
      
    );
  }
}