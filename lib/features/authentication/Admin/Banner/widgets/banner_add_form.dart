import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/features/shop/controllers/banner_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../utils/constants/sizes.dart';

class BannerAddForm extends StatelessWidget {
  final String adminUid;

  const BannerAddForm({
    super.key,
    required this.adminUid,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());

    return Form(
      key: controller.bannerFormKey,
      child: Column(
        children: [
          // Image Upload Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Banner Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  
                  // Image Preview
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() {
                      // First check for selected file
                      if (controller.selectedImage.value != null) {
                        return Image.file(
                          File(controller.selectedImage.value!.files.first.path!),
                          fit: BoxFit.cover,
                        );
                      }
                      // Then check for URL
                      else if (controller.imageUrl.value.isNotEmpty) {
                        return CachedNetworkImage(
                          imageUrl: controller.imageUrl.value,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Lottie.asset(
                              TImages.loadingJson,
                              width: 100,
                              height: 100,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        );
                      }
                      // Default empty state
                      return const Center(
                        child: Icon(Iconsax.gallery_add, size: 50, color: Colors.grey),
                      );
                    }),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  
                  // Image URL Input
                  TextFormField(
                    controller: controller.imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      prefixIcon: Icon(Iconsax.link),
                    ),
                    onChanged: (value) {
                      // Clear selected file when URL is entered
                      if (value.isNotEmpty) {
                        controller.selectedImage.value = null;
                        controller.imageUrl.value = value;
                      } else {
                        controller.imageUrl.value = '';
                      }
                    },
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  
                  // OR Divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  
                  // Gallery Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickImage(),
                      icon: const Icon(Iconsax.image),
                      label: const Text('Pick from Gallery'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwSections),

          // Title Field
          TextFormField(
            controller: controller.titleController,
            validator: (value) => value!.isEmpty ? 'Please enter banner title' : null,
            decoration: const InputDecoration(
              labelText: 'Banner Title',
              hintText: 'Enter banner title',
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwSections),

          // Active Status
          Obx(() => SwitchListTile(  // Use Obx for reactive UI
            title: const Text('Active Status'),
            value: controller.isActive.value,
            onChanged: (value) => controller.isActive.value = value,
          )),

          const SizedBox(height: TSizes.spaceBtwSections),

          // Submit Button with Loading State
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => controller.isLoading.value
                  ? Center(
                      child: Lottie.asset(
                        TImages.loadingJson,
                        width: 100,
                        height: 100,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => controller.saveBanner(adminUid),
                      child: const Text('Save Banner'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}