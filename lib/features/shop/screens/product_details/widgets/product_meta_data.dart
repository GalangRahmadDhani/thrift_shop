import 'package:ecommerce_app/common/widgets/custom_shape/container/rounded_container.dart';
import 'package:ecommerce_app/common/widgets/images/t_circular_image.dart';
import 'package:ecommerce_app/common/widgets/texts/brand_name_verified_icon.dart';
import 'package:ecommerce_app/common/widgets/texts/product_price_text.dart';
import 'package:ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/enums.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

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
            const TProductTitleText(title: 'Brand: '),
            TBrandTitleWithVerifiedIcon(title: product.brand),
          ],
        ),
      ],
    );
  }
}