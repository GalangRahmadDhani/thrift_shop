import 'package:ecommerce_app/common/widgets/chips/choice_chip.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/rounded_container.dart';
import 'package:ecommerce_app/common/widgets/texts/product_price_text.dart';
import 'package:ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TProductAttributes extends StatelessWidget {
  const TProductAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        // Selected Product attribute Pricing  & Deskripsi
        TRoundedContainer(
          padding: const EdgeInsets.all(TSizes.md),
          backgroundColor: dark ? TColors.darkGrey : TColors.grey,
          child: Column(
            children: [
              // Title Pricing Status
              Row(
                children: [
                  const TSectionHeading(title: 'Variasi', showActionButton: false,),
                  const SizedBox(width: TSizes.spaceBtwItems,),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const TProductTitleText(title: 'Harga : ', smallSize: true,),

                          Text(
                            '\Rp 150.000',
                            style: Theme.of(context).textTheme.titleSmall!.apply(decoration: TextDecoration.lineThrough),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems,),

                          // Hrga jual
                          const TProductPriceText(price: '135.500'),
                        ],
                      ),

                      // Stock
                      Row(
                        children: [
                          const TProductTitleText(title: 'Stock : ', smallSize: true,),
                          Text(
                            'Stock tersedia',
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),

              // Deskripsi Variasi
              const TProductTitleText(
                title: 'Ini tempat deskripsi dawdfgrfedwfgfdgfgffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
                smallSize: true,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: TSizes.defaultSpace,),

        // Attribute
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TSectionHeading(title: 'Warna', showActionButton: false,),
            const SizedBox(height: TSizes.spaceBtwItems / 2,),

            Wrap(
              spacing: 8,
              children: [
                TChoiceChip(text: 'Hijau',selected: true, onSelected: (value) {},),
                TChoiceChip(text: 'Red',selected: false, onSelected: (value) {}),
                TChoiceChip(text: 'Blue',selected: false, onSelected: (value) {}),
              ],
            )
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TSectionHeading(title: 'Ukuran', showActionButton: false,),
            const SizedBox(height: TSizes.spaceBtwItems / 2,),

            Wrap(
              spacing: 8,
              children: [
                TChoiceChip(text: 'EU 41',selected: true, onSelected: (value) {}),
                TChoiceChip(text: 'EU 42',selected: false, onSelected: (value) {}),
                TChoiceChip(text: 'EU 43',selected: false, onSelected: (value) {}),
              ],
            )
          ],
        ),
      ],
    );
  }
}

