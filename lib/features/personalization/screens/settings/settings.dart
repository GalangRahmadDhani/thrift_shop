import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/primary_header_container.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:ecommerce_app/features/personalization/screens/address/address.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/profile.dart';
import 'package:ecommerce_app/features/shop/screens/cart/cart.dart';
import 'package:ecommerce_app/features/shop/screens/order/order.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TAppBar(
                    title: Text(
                      'Akun',
                      style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections,),

                  // User Profile Card
                  TUserProfileTile(onPressed: () => Get.to(() => const ProfileScreen(),),),
                  const SizedBox(height: TSizes.spaceBtwSections,)
                ],
              )
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Account Settings
                  const TSectionHeading(title: 'Setting Akun', showActionButton: false,),
                  const SizedBox(height: TSizes.spaceBtwItems,),

                  TSettingMenuTile(
                    icon: Iconsax.safe_home, 
                    title: 'Alamat Saya', 
                    subtitle: 'Atur Alamat Pengiriman',
                    onTap: () => Get.to(() => const UserAddressScreen(),),
                  ),
                  TSettingMenuTile(
                    icon: Iconsax.shopping_cart, 
                    title: 'Keranjang Saya', 
                    subtitle: 'Tambah, hapus barang and pindahkan ke checkout',
                    onTap: () => Get.to(() => const CartScreen()),
                  ),
                  TSettingMenuTile(
                    icon: Iconsax.bag_tick, 
                    title: 'Pesanan Saya', 
                    subtitle: 'Sedang dalam progress',
                    onTap: () => Get.to(() => const OrderScreen(),),
                  ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.bank, 
                  //   title: 'Akun Bank', 
                  //   subtitle: 'Tarik tunai ke akun bank',
                  //   onTap: () {},
                  // ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.discount_shape, 
                  //   title: 'Kupon Diskon', 
                  //   subtitle: 'List semua kupon',
                  //   onTap: () {},
                  // ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.notification, 
                  //   title: 'Notifikasi', 
                  //   subtitle: 'Atur segala notifikasi',
                  //   onTap: () {},
                  // ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.security_card, 
                  //   title: 'Privasi Akun', 
                  //   subtitle: 'Atur pengelolahan akun',
                  //   onTap: () {},
                  // ),

                  // App Settings
                  // const SizedBox(height: TSizes.spaceBtwSections,),
                  // const TSectionHeading(title: 'App Settings', showActionButton: false,),
                  // const SizedBox(height: TSizes.spaceBtwItems,),
                  // TSettingMenuTile(icon: Iconsax.document_upload, title: 'Load Data', subtitle: 'Upload data ke Firebase', trailing: Switch(value: true, onChanged: (value){}),
                  // ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.location, 
                  //   title: 'Geolokasi', 
                  //   subtitle: 'Atur rekomendasi berdasarkan lokasi',
                  //   trailing: Switch(value: true, onChanged: (value){}),
                  // ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.security_user, 
                  //   title: 'Safe Mode', 
                  //   subtitle: 'Hasil pencarian aman untuk segala usia',
                  //   trailing: Switch(value: true, onChanged: (value){}),
                  // ),
                  // TSettingMenuTile(
                  //   icon: Iconsax.image, 
                  //   title: 'Kualitas Gambar HD', 
                  //   subtitle: 'Atur kualitas gambar',
                  //   trailing: Switch(value: true, onChanged: (value){}),
                  // ),
                  const SizedBox(height: TSizes.spaceBtwSections,),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text('Apakah Anda yakin ingin logout?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Tutup dialog tanpa logout
                                  },
                                  child: const Text('Batal', style: TextStyle(color: Colors.black),),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Tutup dialog
                                    AuthenticationRepository.instance.logout();
                                  },
                                  child: const Text('Logout', style: TextStyle(color: Colors.red),),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
