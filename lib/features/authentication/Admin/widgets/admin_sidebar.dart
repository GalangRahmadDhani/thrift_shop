import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/Admin/Banner/banner_list.dart';
import 'package:ecommerce_app/features/authentication/Admin/Brand%20&%20Category/brand_category_list.dart';
import 'package:ecommerce_app/features/authentication/Admin/Orderan/order_list_admin.dart';
import 'package:ecommerce_app/features/authentication/Admin/Product/product_list.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Drawer(
      backgroundColor: dark ? TColors.dark : TColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: dark ? TColors.light : TColors.white,
                  child: Icon(Iconsax.user, size: 30, color: dark ? TColors.dark : TColors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: dark ? TColors.light : TColors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Iconsax.home, color: dark ? TColors.light : null),
            title: Text('Dashboard', 
              style: TextStyle(color: dark ? TColors.light : TColors.black)
            ),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: Icon(Iconsax.box, color: dark ? TColors.light : null),
            title: Text('Products',
              style: TextStyle(color: dark ? TColors.light : TColors.black)
            ),
            onTap: () {
              Get.to(() => const ProductListScreen());
            },
          ),
          // ListTile(
          //   leading: Icon(Iconsax.user, color: dark ? TColors.light : null),
          //   title: Text('Akun Customer',
          //     style: TextStyle(color: dark ? TColors.light : TColors.black)
          //   ),
          //   onTap: () {
          //     Get.back();
          //   },
          // ),
          ListTile(
            leading: Icon(Iconsax.activity, color: dark ? TColors.light : null),
            title: Text('Banner',
              style: TextStyle(color: dark ? TColors.light : TColors.black)
            ),
            onTap: () {
              Get.to(() => const BannerListScreen());
            },
          ),
          ListTile(
            leading: Icon(Iconsax.category, color: dark ? TColors.light : null),
            title: Text('Brand & Categori',
              style: TextStyle(color: dark ? TColors.light : TColors.black)
            ),
            onTap: () {
              Get.to(() => const BrandCategoryList());
            },
          ),
          ListTile(
            leading: Icon(Iconsax.award, color: dark ? TColors.light : null),
            title: Text('Orderan',
              style: TextStyle(color: dark ? TColors.light : TColors.black)
            ),
            onTap: () {
              Get.to(() => const OrderListAdminScreen());
            },
          ),
          Divider(color: dark ? TColors.darkerGrey : null),
          ListTile(
            leading: Icon(Iconsax.logout, color: dark ? TColors.light : null),
            title: Text('Logout',
              style: TextStyle(color: dark ? TColors.light : TColors.black)
            ),
            onTap: () {
              Get.back();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: dark ? TColors.dark : TColors.white,
                    title: Text('Confirm Logout',
                      style: TextStyle(color: dark ? TColors.light : TColors.black)
                    ),
                    content: Text('Are you sure you want to logout?',
                      style: TextStyle(color: dark ? TColors.light : TColors.black)
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('No',
                          style: TextStyle(color: dark ? TColors.light : TColors.black)
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AuthenticationRepository.instance.logout();
                        },
                        child: const Text('Yes', 
                          style: TextStyle(color: TColors.secondary)
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
