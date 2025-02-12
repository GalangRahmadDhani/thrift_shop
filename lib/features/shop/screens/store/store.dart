
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/appbar/tabbar.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/search_container.dart';
import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/common/widgets/brands/store_brand_card.dart';
import 'package:ecommerce_app/features/shop/screens/brands/all_brands.dart';
import 'package:ecommerce_app/features/shop/screens/store/widgets/category_tab.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Toko',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            TCartCounterIcon(
              onPressed: () {},
            )
          ],
        ),
        body: NestedScrollView(
            headerSliverBuilder: (_, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: true,
                    backgroundColor: THelperFunctions.isDarkMode(context)
                        ? TColors.black
                        : TColors.white,
                    expandedHeight: 440,
                    flexibleSpace: Padding(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const SizedBox(
                            height: TSizes.spaceBtwItems,
                          ),
                          const TSearchContainer(
                            text: 'Cari di Toko...',
                            showBorder: true,
                            showBackground: false,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(
                            height: TSizes.spaceBtwSections,
                          ),

                          // Feature Brands
                          // TSectionHeading(
                          //   title: 'Brand Populer',
                          //   onPressed: () => Get.to(() => const AllBrandsScreen()),
                          // ),
                          const SizedBox(
                            height: TSizes.spaceBtwItems / 1.5,
                          ),

                          // TGridLayout(
                          //     itemCount: 4,
                          //     mainAxisExtent: 80,
                          //     itemBuilder: (_, index) {
                          //       return const TBrandCard(
                          //         showBorder: true,
                          //       );
                          //     }),
                        ],
                      ),
                    ),

                    // Tabs
                    bottom: const TTabBar(
                      tabs: [
                        Tab(
                          child: Text('Kaos'),
                        ),
                        Tab(
                          child: Text('Celana'),
                        ),
                        Tab(
                          child: Text('Jaket Kulit'),
                        ),
                        Tab(
                          child: Text('Jeans'),
                        ),
                        Tab(
                          child: Text('Kemeja'),
                        ),

                      ],
                    )),
              ];
            },

            // Body
            body: const TabBarView(
              children: [
                TCategoryTab(),
                TCategoryTab(),
                TCategoryTab(),
                TCategoryTab(),
                TCategoryTab(),
              ],
          )
        ),
      ),
    );
  }
}