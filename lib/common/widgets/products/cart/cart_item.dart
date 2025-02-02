import 'package:ecommerce_app/common/widgets/images/t_rounded_image.dart';
import 'package:ecommerce_app/common/widgets/texts/brand_name_verified_icon.dart';
import 'package:ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TCartItem extends StatelessWidget {
  const TCartItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Image
        TRoundedImage(
          imageUrl: TImages.productBaju1,
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(TSizes.sm),
          backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.darkerGrey : TColors.light,
        ),
        const SizedBox(width: TSizes.spaceBtwItems,),
    
        // Title, Price, Size
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // brand
              const TBrandTitleWithVerifiedIcon(title: 'Korleo'),
              const Flexible(child: TProductTitleText (title: 'Anime Blue Design', maxLines: 1,)),
          
              // Atributes
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'warna ', style: Theme.of(context).textTheme.bodySmall,),
                    TextSpan(text: 'Blue ', style: Theme.of(context).textTheme.bodyLarge,),
                    TextSpan(text: 'Ukuran ', style: Theme.of(context).textTheme.bodySmall,),
                    TextSpan(text: '42 ', style: Theme.of(context).textTheme.bodyLarge,),
                  ]
                )
              )
          
            ],
          ),
        )
      ],
    );
  }
}