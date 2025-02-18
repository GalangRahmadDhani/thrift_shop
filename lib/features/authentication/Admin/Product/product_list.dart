import 'package:ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:ecommerce_app/features/authentication/Admin/Product/product_add.dart';
import 'package:ecommerce_app/features/authentication/Admin/Product/product_edit.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart'; // Add this import
import 'package:ecommerce_app/features/authentication/Admin/Product/widgets/product_search.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/Admin/widgets/admin_sidebar.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repository first, then controller
    Get.put(ProductRepository());
    final controller = Get.put(ProductController());
    
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: TAppBar(
        title: const Text('Product List'),
        leadingIcon: Icons.menu,
        leadingOnPressed: () => scaffoldKey.currentState?.openDrawer(),
        backgroundColor: dark ? TColors.dark : TColors.light,
      ),
      drawer: const AdminSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(const ProductAddScreen()),
        child: const Icon(Iconsax.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchAllProducts();
        },
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Add SearchBar
              const ProductSearchBar(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Products Grid
              Expanded(
                child: Obx(
                  () => controller.loading.value 
                    ? const Center(child: CircularProgressIndicator())
                    : controller.isSearching.value
                      ? controller.searchResults.isEmpty
                        ? const Center(child: Text('No products found'))
                        : buildProductGrid(controller.searchResults)
                      : controller.products.isEmpty
                        ? const Center(child: Text('No products found'))
                        : buildProductGrid(controller.products),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductGrid(List<ProductModel> products) {
    final controller = Get.find<ProductController>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: TSizes.gridViewSpacing,
        crossAxisSpacing: TSizes.gridViewSpacing,
        mainAxisExtent: 288,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Default background
                  ),
                  child: product.images.isEmpty
                      ? const Center(
                          child: Icon(
                            Iconsax.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              product.images.first,
                              fit: BoxFit.fill,
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
                                  child: Icon(
                                    Iconsax.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TSizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.isSale) ...[
                              // Harga diskon (harga yang berlaku)
                              Text(
                                currencyFormatter.format(product.salePrice),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              // Harga asli (dicoret)
                              Text(
                                currencyFormatter.format(product.price),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ] else
                              // Harga normal jika tidak ada diskon
                              Text(
                                currencyFormatter.format(product.price),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            
                            const SizedBox(height: TSizes.spaceBtwItems),
                            // Add Stock Information
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9,),
                              decoration: BoxDecoration(
                                color: product.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Stock: ${product.stock}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: product.stock > 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.only(top: 0, right: 8, left: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit),
                      onPressed: () => Get.to(
                        () => ProductEditPage(product: product), // Asumsikan ada ProductEditScreen
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash),
                      onPressed: () => _showDeleteDialog(context, controller, product.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ProductController controller, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteProduct(productId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
