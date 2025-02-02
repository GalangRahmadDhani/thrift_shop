import 'package:ecommerce_app/common/widgets/custom_shape/container/rounded_container.dart';
import 'package:ecommerce_app/common/widgets/products/rating/rating_indicator.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage(TImages.userProfileImage1),
              ),
              const SizedBox(width: TSizes.spaceBtwItems,),
              Text('John Doe', style: Theme.of(context).textTheme.titleLarge,)
            ],
          ),
          IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert))
        ],
       ),
       const SizedBox(height: TSizes.spaceBtwItems,),

       // Review
       Row(
        children: [
          const TRatingBarIndicator(rating: 4),
          const SizedBox(width: TSizes.spaceBtwItems,),
          Text('01 Nov 2025', style: Theme.of(context).textTheme.bodyMedium),
        ],
       ),
       const SizedBox(height: TSizes.spaceBtwItems,),

       const ReadMoreText(
        'The user interface of the app is quite intuitive. I was able to navigate and make purchase seamlessly, Great job!',
        trimLines: 2,
        trimMode: TrimMode.Line,
        trimExpandedText: ' show less',
        trimCollapsedText: ' show more',
        moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary,),
        lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary,),
       ),
       const SizedBox(height: TSizes.spaceBtwItems,),

       // Company Reviews
       TRoundedContainer(
        backgroundColor: dark ? TColors.darkerGrey : TColors.grey,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GT Store', style: Theme.of(context).textTheme.bodyLarge),
                  Text('02  Nov 2025', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems,),
              const ReadMoreText(
                'The user interface of the app is quite intuitive. I was able to navigate and make purchase seamlessly, Great job!',
                trimLines: 2,
                trimMode: TrimMode.Line,
                trimExpandedText: ' show less',
                trimCollapsedText: ' show more',
                moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary,),
                lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary,),
              ),
            ],
          ),
        ),
       ),
       const SizedBox(height: TSizes.spaceBtwSections,)
      ],
    );
  }
}