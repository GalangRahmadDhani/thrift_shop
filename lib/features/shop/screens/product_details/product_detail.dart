import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/bottom_add_to_card_widget.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/rating_and_share.dart';
import 'package:ecommerce_app/features/shop/screens/product_reviews/product_reviews.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: const TBottomAddToCart(),
      body: SingleChildScrollView(
        child: Column(
          children: [
          // 1 - Product Image Slider
            const TProductImageSlider(),

          // 2 - Product Details
            Padding(
              padding: const EdgeInsets.only(right: TSizes.defaultSpace, left: TSizes.defaultSpace, bottom: TSizes.defaultSpace),
              child: Column(
                children: [
                  // Rating & Share
                  const TRatingAndShare(),

                  // Price, Title, Stock, & Brand
                  const TProductMetaData(),

                  // -- attribute
                  const TProductAttributes(),
                  const SizedBox(height: TSizes.spaceBtwSections,),

                  // -- Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){}, 
                      child: const Text('Checkout'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections,),

                  // Description
                  const TSectionHeading(title: 'Deskripsi', showActionButton: false,),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  const ReadMoreText(
                    'Ini adalah deskripsi produk, deskripsi di letakkan disini ',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' less',
                    moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  // Reviews
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TSectionHeading(title: 'Review(199)', showActionButton: false,),
                      IconButton(icon: const Icon(Iconsax.arrow_right_3, size: 13,), onPressed: () => Get.to(() => const ProductReviewsScreen()),)
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
