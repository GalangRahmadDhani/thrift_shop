import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'dart:io';

import 'package:lottie/lottie.dart';

class ProductAddForm extends StatelessWidget {
  const ProductAddForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final imageUrlPreview = "".obs;
    
    // Clear form when opening add page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearForm();
    });

    return Form(
      key: controller.productFormKey,
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
                    'Product Image',
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
                  
                  // Image URL Input with preview functionality
                  TextFormField(
                    controller: controller.imageUrl,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      prefixIcon: Icon(Iconsax.link),
                    ),
                    onChanged: (value) {
                      // Update preview when URL changes
                      if (value.trim().isNotEmpty && Uri.tryParse(value.trim())?.isAbsolute == true) {
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
                      onPressed: () => controller.pickProductImage(),
                      icon: const Icon(Iconsax.image),
                      label: const Text('Pick from Gallery'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Product Name
          TextFormField(
            controller: controller.name,
            validator: (value) => TValidator.validateEmptyText('Product Name', value),
            decoration: const InputDecoration(
              labelText: 'Product Name',
              prefixIcon: Icon(Iconsax.shop),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Product Description
          TextFormField(
            controller: controller.description,
            validator: (value) => TValidator.validateEmptyText('Description', value),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Iconsax.document_text),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Price & Discount Row
          Row(
            children: [
              // Price
              Expanded(
                child: TextFormField(
                  controller: controller.price,
                  validator: (value) => TValidator.validateEmptyText('Price', value),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Iconsax.money),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              // Discount Price
              Expanded(
                child: TextFormField(
                  controller: controller.discountPrice,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga diskon (Optional)' ,
                    prefixIcon: Icon(Iconsax.discount_shape),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Brand & Category Row
          Row(
            children: [
              // Brand
              Expanded(
                child: TextFormField(
                  controller: controller.brand,
                  validator: (value) => TValidator.validateEmptyText('Brand', value),
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    prefixIcon: Icon(Iconsax.briefcase),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              // Category
              Expanded(
                child: TextFormField(
                  controller: controller.category,
                  validator: (value) => TValidator.validateEmptyText('Category', value),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Iconsax.category),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Stock
          TextFormField(
            controller: controller.stock,
            validator: (value) => TValidator.validateEmptyText('Stock', value),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Stock',
              prefixIcon: Icon(Iconsax.box),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.addProduct(),
              child: const Text('Add Product'),
            ),
          ),
        ],
      ),
    );
  }
}
