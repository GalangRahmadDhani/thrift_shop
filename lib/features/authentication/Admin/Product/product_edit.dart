import 'dart:io';

import 'package:ecommerce_app/features/authentication/Admin/Product/product_list.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:lottie/lottie.dart';

class ProductEditPage extends StatefulWidget {
  final ProductModel product;

  const ProductEditPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final controller = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with existing product data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.name.text = widget.product.name;
      controller.description.text = widget.product.description;
      controller.price.text = widget.product.price.toStringAsFixed(0);
      controller.discountPrice.text = widget.product.salePrice?.toStringAsFixed(0) ?? '';
      controller.brand.text = widget.product.brandId;
      controller.category.text = widget.product.categoryId;
      controller.stock.text = widget.product.stock.toString();
      controller.imageUrl.text = widget.product.images.isNotEmpty ? widget.product.images.first : '';
      
      // Set selected values for dropdowns
      controller.setSelectedBrand(controller.getBrandName(widget.product.brandId));
      controller.setSelectedCategory(controller.getCategoryName(widget.product.categoryId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrlPreview = (widget.product.images.isNotEmpty ? widget.product.images.first : "").obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.editProductFormKey, // Use editProductFormKey instead
            child: Column(
              children: [
                // Image Section
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
                        
                        // Current Image Preview
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
                            } else if (widget.product.images.isNotEmpty) {
                              return Image.network(
                                widget.product.images.first,
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
                            hintText: 'Current or new image URL',
                            prefixIcon: Icon(Iconsax.link),
                          ),
                          onChanged: (value) {
                            // Update preview when URL changes
                            if (value.trim().isNotEmpty && Uri.tryParse(value.trim())?.isAbsolute == true) {
                              imageUrlPreview.value = value.trim();
                            } else {
                              imageUrlPreview.value = widget.product.images.isNotEmpty ? widget.product.images.first : '';
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
                    Expanded(
                      child: TextFormField(
                        controller: controller.discountPrice,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount Price (Optional)',
                          prefixIcon: Icon(Iconsax.discount_shape),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Brand & Category Dropdowns - Modified Layout
                Wrap(
                  spacing: TSizes.spaceBtwInputFields,
                  runSpacing: TSizes.spaceBtwInputFields,
                  children: [
                    // Brand Dropdown
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4, // Adjust width
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          isExpanded: true, // Make dropdown expand to container width
                          value: controller.brandNames.contains(widget.product.brandId) 
                              ? widget.product.brandId 
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            prefixIcon: Icon(Iconsax.briefcase),
                          ),
                          items: controller.brandNames // Use brandNames instead of brands
                              .map((brandName) => DropdownMenuItem(
                                    value: brandName,
                                    child: Text(
                                      brandName,
                                      overflow: TextOverflow.ellipsis, // Handle text overflow
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setSelectedBrand(value);
                              controller.brand.text = value;
                            }
                          },
                          validator: (value) =>
                              TValidator.validateEmptyText('Brand', value),
                        ),
                      ),
                    ),
                    
                    // Category Dropdown
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4, // Adjust width
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          isExpanded: true, // Make dropdown expand to container width
                          value: controller.categoryNames.contains(widget.product.categoryId) 
                              ? widget.product.categoryId 
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Iconsax.category),
                          ),
                          items: controller.categoryNames // Use categoryNames instead of categories
                              .map((categoryName) => DropdownMenuItem(
                                    value: categoryName,
                                    child: Text(
                                      categoryName,
                                      overflow: TextOverflow.ellipsis, // Handle text overflow
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setSelectedCategory(value);
                              controller.category.text = value;
                            }
                          },
                          validator: (value) =>
                              TValidator.validateEmptyText('Category', value),
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
                const SizedBox(height: TSizes.spaceBtwSections),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleUpdate(controller),
                    child: const Text('Update Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleUpdate(ProductController controller) async {
    if (!controller.editProductFormKey.currentState!.validate()) return; // Update validation check

    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Handle image upload first
      String? newImageUrl;
      if (controller.selectedImage.value != null || controller.imageUrl.text.isNotEmpty) {
        newImageUrl = await controller.handleImageUpload(); // Updated method call
      }
      
      final updatedData = {
        'name': controller.name.text.trim(),
        'description': controller.description.text.trim(),
        'price': double.parse(controller.price.text.trim()).toInt(), // Convert to integer
        'salePrice': controller.discountPrice.text.isEmpty 
            ? null 
            : double.parse(controller.discountPrice.text.trim()).toInt(), // Convert to integer
        'isSale': controller.discountPrice.text.isNotEmpty,
        'brand': controller.brand.text.trim(),
        'category': controller.category.text.trim(),
        'stock': int.tryParse(controller.stock.text.trim()) ?? 0,
        'images': newImageUrl != null ? [newImageUrl] : widget.product.images,
      };

      await controller.updateProduct(widget.product.id, updatedData);
      
      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Data Product Terupdate',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Get.back();
      // Navigate back to product list
      Get.off(() => const ProductListScreen()); // Using Get.off to prevent back navigation
      
    } catch (e) {
      // Close loading dialog
      Get.back();
      
      // Show error message
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}