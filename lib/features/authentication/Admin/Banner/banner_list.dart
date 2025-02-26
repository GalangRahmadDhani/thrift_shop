import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/Admin/Banner/banner_add.dart';
import 'package:ecommerce_app/features/authentication/Admin/Banner/widgets/banner_card.dart';
import 'package:ecommerce_app/features/authentication/Admin/widgets/admin_sidebar.dart';
import 'package:ecommerce_app/features/authentication/User/models/banner_model.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/shop/controllers/banner_controller.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/colors.dart';

class BannerListScreen extends StatelessWidget {
  const BannerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());
    final dark = THelperFunctions.isDarkMode(context);
    final GlobalKey<ScaffoldState> scaffoldBannerListKey = GlobalKey<ScaffoldState>();

    Future<void> showStatusDialog(BannerModel banner) async {
      bool status = banner.isActive;
      await Get.dialog(
        AlertDialog(
          title: const Text('Edit Banner Status'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: const Text('Active'),
                    value: true,
                    groupValue: status,
                    onChanged: (value) {
                      setState(() => status = value!);
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('Inactive'),
                    value: false,
                    groupValue: status,
                    onChanged: (value) {
                      setState(() => status = value!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                if (status != banner.isActive) {
                  controller.toggleBannerStatus(banner.id, status);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: scaffoldBannerListKey, // Add this
      appBar: TAppBar(
        showBackArrow: false, // Add this
        leadingIcon: Icons.menu,
        leadingOnPressed: () => scaffoldBannerListKey.currentState?.openDrawer(),
        title: const Text('Banner Management'),
        backgroundColor: dark ? TColors.dark : TColors.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const BannerAddScreen()),
          ),
        ],
      ),
      drawer: const AdminSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search banners...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  PopupMenuButton(
                    icon: const Icon(Icons.filter_list),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      const PopupMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            // Banner Grid with Firestore Data
            Expanded(
              child: StreamBuilder<List<BannerModel>>(
                stream: controller.getBanners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final banners = snapshot.data ?? [];
                  if (banners.isEmpty) {
                    return const Center(child: Text('No banners available'));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 16/9,
                      mainAxisSpacing: TSizes.gridViewSpacing,
                      crossAxisSpacing: TSizes.gridViewSpacing,
                    ),
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return BannerCard(
                        imageUrl: banner.imageUrl,
                        title: banner.title,
                        isActive: banner.isActive,
                        onEdit: () => showStatusDialog(banner),
                        onDelete: () async {
                          final confirm = await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('Delete Banner'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Get.back(result: true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await controller.deleteBanner(banner.id);
                          }
                        },
                        onToggleStatus: () => controller.toggleBannerStatus(
                          banner.id,
                          !banner.isActive,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

