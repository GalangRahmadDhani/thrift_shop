import 'package:ecommerce_app/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/shop/screens/sub_category/sub_categories.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/shop/controllers/category_controller.dart';

class THomeCategories extends StatelessWidget {
  const THomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());

    return Padding(
      padding: const EdgeInsets.only(left: TSizes.defaultSpace),
      child: Column(
        children: [
          // Heading
          const TSectionHeading(title: 'Kategori Populer', showActionButton: false, textColor: TColors.grey,),
          const SizedBox(height: TSizes.spaceBtwItems,),

          // Categories
          Obx(
            () {
              if (categoryController.categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return SizedBox(
                height: 80,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categoryController.categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    final category = categoryController.categories[index];
                    
                    return TVerticalImageText(
                      image: category.image ?? '',
                      title: category.name,
                      onTap: () {
                        Get.to(() => SubCategoriesScreen(category: category));
                                            },
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}