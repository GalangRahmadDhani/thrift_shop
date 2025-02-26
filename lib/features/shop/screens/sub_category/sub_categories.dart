import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/authentication/User/models/banner_model.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/authentication/Admin/Brand & Category/models/category_model.dart';
import 'package:ecommerce_app/features/shop/screens/home/widgets/home_promo_slider.dart';
import 'package:ecommerce_app/features/shop/controllers/banner_controller.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart'; // Add this import

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.put(BannerController());
    final productController = Get.put(ProductController());

    return Scaffold(
      appBar: TAppBar(title: Text(category.name), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Banner Slider
              StreamBuilder<List<BannerModel>>(
                stream: bannerController.getBanners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Banner Error: ${snapshot.error}'); // Debug print
                    return const SizedBox.shrink(); // Hide on error
                  }

                  final banners = snapshot.data ?? [];
                  if (banners.isEmpty) {
                    print('No banners found'); // Debug print
                    return const SizedBox.shrink(); // Hide if no banners
                  }

                  return TPromoSlider(banners: banners);
                },
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Products by Category - Modified Section
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Products')
                    .where('categoryId', isEqualTo: category.name) // Changed to use category name
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Modified conversion of documents to ProductModel
                  final products = snapshot.data?.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ProductModel.fromJson({
                      ...data,
                      'id': doc.id,
                    });
                  }).toList() ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.production_quantity_limits, size: 50),
                          SizedBox(height: TSizes.spaceBtwItems),
                          Text('No products found in this category'),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      TSectionHeading(
                        title: 'Products in ${category.name}',
                        showActionButton: false,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      
                      // Grid view instead of horizontal list
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: TSizes.gridViewSpacing,
                          crossAxisSpacing: TSizes.gridViewSpacing,
                          mainAxisExtent: 288,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) => TProductCardVertical(
                          product: products[index],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}