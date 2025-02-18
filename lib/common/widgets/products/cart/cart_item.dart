import 'package:ecommerce_app/common/widgets/images/t_rounded_image.dart';
import 'package:ecommerce_app/common/widgets/texts/brand_name_verified_icon.dart';
import 'package:ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/authentication/User/models/cart_model.dart';
import 'package:iconsax/iconsax.dart';

class TCartItem extends StatelessWidget {
  final CartModel cartItem;

  const TCartItem({
    super.key,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Row(
      children: [
        // Image
        TRoundedImage(
          imageUrl: cartItem.image,
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(TSizes.sm),
          backgroundColor: dark ? TColors.darkerGrey : TColors.light,
          isNetworkImage: true,
          fit: BoxFit.cover,
        ),

        const SizedBox(width: TSizes.spaceBtwItems),
    
        // Title, Price, Size
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // brand
              TBrandTitleWithVerifiedIcon(title: cartItem.productName),
              Flexible(
                child: TProductTitleText(
                  title: cartItem.productName,
                  maxLines: 1,
                ),
              ),
          
              // Atributes
              // Text.rich(
              //   TextSpan(
              //     children: [
              //       TextSpan(text: 'warna ', style: Theme.of(context).textTheme.bodySmall,),
              //       TextSpan(text: 'Blue ', style: Theme.of(context).textTheme.bodyLarge,),
              //       TextSpan(text: 'Ukuran ', style: Theme.of(context).textTheme.bodySmall,),
              //       TextSpan(text: '42 ', style: Theme.of(context).textTheme.bodyLarge,),
              //     ]
              //   )
              // )
          
            ],
          ),
        )
      ],
    );
  }
}