import 'package:ecommerce_app/common/widgets/texts/brand_name_verified_icon.dart';
import 'package:ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:ecommerce_app/features/authentication/Admin/Brand%20&%20Category/models/brand_model.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/features/shop/controllers/brand_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TProductMetaData extends StatelessWidget {
  final ProductModel product;
  final String priceFormatted;
  final String? salePriceFormatted;

  const TProductMetaData({
    super.key,
    required this.product,
    required this.priceFormatted,
    this.salePriceFormatted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price & Sale Price
        Row(
          children: [
            // Sale Price
            if (product.isSale && salePriceFormatted != null) ...[
              Text(
                salePriceFormatted!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              // Original Price
              Text(
                priceFormatted,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ] else
              Text(
                priceFormatted,
                style: Theme.of(context).textTheme.titleLarge,
              ),
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        // Title
        Text(product.name, style: Theme.of(context).textTheme.titleMedium),
        
        const SizedBox(height: TSizes.spaceBtwItems),

        // Stock Status
        Row(
          children: [
            const TProductTitleText(title: 'Status: '),
            Text(
              product.stock > 0 ? 'In Stock' : 'Out of Stock',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: product.stock > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        // Brand
        Row(
          children: [
            const TProductTitleText(title: 'Brand: ', smallSize: false,),
            StreamBuilder<List<BrandModel>>(
              stream: Get.find<BrandController>().getBrandById(product.brandId),
              builder: (context, snapshot) {
                String brandName = 'Unknown Brand';
                bool isFeatured = false;
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final brand = snapshot.data!.first;
                  brandName = brand.name;
                  isFeatured = brand.isFeatured ?? false;
                }
                return TBrandNameWithVerifiedIcon(
                  brandName: brandName,
                  showVerifiedIcon: isFeatured,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}