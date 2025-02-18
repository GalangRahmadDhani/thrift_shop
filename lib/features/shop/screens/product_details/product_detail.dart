import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/bottom_add_to_card_widget.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:ecommerce_app/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      bottomNavigationBar: TBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1 - Product Image Slider
            TProductImageSlider(images: product.images),

            // 2 - Product Details
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price, Title, Stock, & Brand
                  TProductMetaData(
                    product: product,
                    priceFormatted: currencyFormatter.format(product.price),
                    salePriceFormatted: product.isSale ? 
                      currencyFormatter.format(product.salePrice) : null,
                  ),

                  // Attributes if any
                  if (product.sizes.isNotEmpty) ...[
                    const TProductAttributes(),
                    const SizedBox(height: TSizes.spaceBtwSections,),
                  ],

                  // Description
                  TSectionHeading(title: 'Deskripsi', showActionButton: false,),
                  SizedBox(height: TSizes.spaceBtwItems,),
                  ReadMoreText(
                    product.description,
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' less',
                    moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  // Reviews
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
