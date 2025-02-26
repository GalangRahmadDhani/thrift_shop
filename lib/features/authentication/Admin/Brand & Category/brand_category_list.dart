import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/Admin/widgets/admin_sidebar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../shop/controllers/brand_controller.dart';
import '../../../shop/controllers/category_controller.dart';
import 'widgets/brand_add_form.dart';
import 'widgets/brand_edit_form.dart';
import 'widgets/category_add_form.dart';
import 'widgets/category_edit_form.dart';

class BrandCategoryList extends StatelessWidget {
  const BrandCategoryList({super.key});

  // Add this method to show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, BrandController controller, String brandId, String brandName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand'),
        content: Text('Are you sure you want to delete "$brandName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => controller.confirmDelete(brandId, brandName),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryConfirmation(BuildContext context, CategoryController controller, String categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => controller.confirmDelete(categoryId, categoryName),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldBrandCategoryKey = GlobalKey<ScaffoldState>();
    final dark = THelperFunctions.isDarkMode(context);
    final brandController = Get.put(BrandController());
    final categoryController = Get.put(CategoryController());

    return Scaffold(
      key: scaffoldBrandCategoryKey,
      appBar: TAppBar(
        showBackArrow: false,
        leadingIcon: Icons.menu,
        leadingOnPressed: () => scaffoldBrandCategoryKey.currentState?.openDrawer(),
        title: const Text('Brand & Category Management'),
        backgroundColor: dark ? TColors.dark : TColors.light,
      ),
      drawer: const AdminSidebar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brands Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Brands',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      brandController.clearForm(); // Clear form before showing dialog
                      showDialog(
                        context: context,
                        builder: (context) => const BrandAddForm(),
                      );
                    },
                    child: const Icon(Iconsax.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: brandController.brands.length,
                    itemBuilder: (context, index) {
                      final brand = brandController.brands[index];
                      return Card(
                        color: TColors.lightContainer,
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: brand.image != null && brand.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      brand.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Iconsax.image),
                                    ),
                                  )
                                : const Icon(Iconsax.image),
                          ),
                          title: Text(brand.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => BrandEditForm(brand: brand),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  brandController,
                                  brand.id!,
                                  brand.name,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),

              const Divider(height: 32, thickness: 2),

              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      categoryController.clearForm();
                      showDialog(
                        context: context,
                        builder: (context) => const CategoryAddForm(),
                      );
                    },
                    child: const Icon(Iconsax.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryController.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryController.categories[index];
                      return Card(
                        color: TColors.lightContainer,
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: category.image != null && category.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      category.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Iconsax.image),
                                    ),
                                  )
                                : const Icon(Iconsax.image),
                          ),
                          title: Text(category.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CategoryEditForm(category: category),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteCategoryConfirmation(
                                  context,
                                  categoryController,
                                  category.id!,
                                  category.name,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}