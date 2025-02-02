import 'package:ecommerce_app/common/widgets/custom_shape/container/rounded_container.dart';
import 'package:ecommerce_app/common/widgets/brands/store_brand_card.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TBrandShowcase extends StatelessWidget {
  const TBrandShowcase({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.md),
      showBorder: false,
      borderColor: TColors.darkGrey,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Column(
        children: [
          // Brand dengan banyak produk
          const TBrandCard(showBorder: false,),
          const SizedBox(height: TSizes.spaceBtwItems,),

          // Brand Top 3
          Row(
            children: images
                .map((image) =>
                    brandTopProductImageWidget(String, image, context))
                .toList(),
          )
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names, avoid_types_as_parameter_names
  Widget brandTopProductImageWidget(String, image, context) {
    return Expanded(
      child: TRoundedContainer(
        height: 100,
        backgroundColor: THelperFunctions.isDarkMode(context)
            ? TColors.darkGrey
            : TColors.light,
        margin: const EdgeInsets.only(right: TSizes.sm),
        padding: const EdgeInsets.all(TSizes.md),
        child: Image(
          fit: BoxFit.contain,
          image: AssetImage(image),
        ),
      ),
    );
  }
}
