import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import '../../../../shop/controllers/brand_controller.dart';
import '../models/brand_model.dart';

class BrandEditForm extends StatelessWidget {
  final BrandModel brand;

  const BrandEditForm({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    final imageUrlPreview = "".obs;

    // Load brand data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadBrandForEditing(brand);
      if (brand.image != null) {
        imageUrlPreview.value = brand.image!;
      }
    });

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.brandFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Brand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
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
                    if (controller.selectedImage.value != null) {
                      return Image.file(
                        File(controller.selectedImage.value!.path),
                        fit: BoxFit.cover,
                      );
                    } else if (imageUrlPreview.value.isNotEmpty) {
                      return Image.network(
                        imageUrlPreview.value,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Lottie.asset(
                              TImages.loadingJson,
                              width: 100,
                              height: 100,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Iconsax.image, size: 50, color: Colors.grey),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Icon(Iconsax.image, size: 50, color: Colors.grey),
                      );
                    }
                  }),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Image URL Input
                TextFormField(
                  controller: controller.imageUrl,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    prefixIcon: Icon(Iconsax.link),
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty && 
                        Uri.tryParse(value.trim())?.isAbsolute == true) {
                      imageUrlPreview.value = value.trim();
                    } else {
                      imageUrlPreview.value = '';
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
                    onPressed: () => controller.pickBrandImage(),
                    icon: const Icon(Iconsax.image),
                    label: const Text('Pick from Gallery'),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Brand Name
                TextFormField(
                  controller: controller.name,
                  validator: (value) => TValidator.validateEmptyText('Brand Name', value),
                  decoration: const InputDecoration(
                    labelText: 'Brand Name',
                    prefixIcon: Icon(Iconsax.briefcase),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.editBrand(brand.id!),
                    child: const Text('Update Brand'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
