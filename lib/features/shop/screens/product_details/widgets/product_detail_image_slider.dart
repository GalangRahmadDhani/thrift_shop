import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/curved_edge/curved_edge_widget.dart';
import 'package:ecommerce_app/common/widgets/icons/circular_icon.dart';
import 'package:ecommerce_app/common/widgets/images/t_rounded_image.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return TCurvedEdgeWidget(
      child: Container(
        color: dark ? TColors.darkerGrey : TColors.light,
        child: Stack(
          children: [
            // Gambar Utama
            const SizedBox(
              height: 400, 
              child: Padding(
                padding: EdgeInsets.all(TSizes.productImageRadius * 2),
                child: Center(
                  child: Image(image: AssetImage(TImages.productBaju1))
                ),
              )
            ),
            // Image Slider
            // Positioned(
            //   right: 0,
            //   // right: TSizes.defaultSpace,
            //   bottom: 30,
            //   left: TSizes.defaultSpace,
            //   child: SizedBox(
            //     height: 80,
            //     child: ListView.separated(
            //       separatorBuilder: (_, __) => const SizedBox(width: TSizes.spaceBtwItems,), 
            //       itemCount: 6, 
            //       shrinkWrap: true,
            //       scrollDirection: Axis.horizontal,
            //       physics: const AlwaysScrollableScrollPhysics(),
            //       itemBuilder: (_, index) => TRoundedImage(
            //       width: 80,
            //       backgroundColor: dark ? TColors.dark : TColors.white,
            //       border: Border.all(color: TColors.primary),
            //       padding: const EdgeInsets.all(TSizes.sm),
            //       imageUrl: TImages.productBaju2
            //       ), 
            //     ),
            //   ),
            // ),
    
            // Appbar Icon
            const TAppBar(
              showBackArrow: true,
              actions: [
                TCircularIcon(
                  icon: Iconsax.heart5,
                  color: Colors.red,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}