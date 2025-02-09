import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar_profile.dart';
import 'package:ecommerce_app/common/widgets/change/change_name.dart';
import 'package:ecommerce_app/common/widgets/images/t_circular_image.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      // AppBar
      appBar: const TAppBar(
        title: Text('Profile'),
        showBackArrow: true,
      ),

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const TCircularImage(image: TImages.user, width: 80, height: 80,),
                    TextButton(onPressed: (){}, child: const Text('Ubah'))
                  ],
                ),
              ),

              // Heading Profile Info
              const SizedBox(height: TSizes.spaceBtwItems / 2,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              
              const TSectionHeading(title: 'Informasi Profil', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems,),

             
              TProfileMenu(title: 'Nama', value: controller.user.value.fullName, onPressed: () => Get.to(() => const ChangeName(), preventDuplicates: true),),
              TProfileMenu(title: 'Username', value: controller.user.value.username, onPressed: () {},),

              const SizedBox(height: TSizes.spaceBtwItems,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              // Heading Personal Info
              const TSectionHeading(title: 'Informasi Profil', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems,),

              TProfileMenu(title: 'User ID', value: controller.user.value.id, icon: Iconsax.copy, onPressed: () {},),
              TProfileMenu(title: 'E-mail', value: controller.user.value.email, onPressed: () {},),
              TProfileMenu(title: 'No. Telp', value: controller.user.value.phoneNumber, onPressed: () {},),
              TProfileMenu(title: 'Jns Kelamin', value: 'Laki-laki', onPressed: () {},),
              TProfileMenu(title: 'Tgl Lahir', value: '18 Okt, 2006', onPressed: () {},),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              // Center(
              //   child: TextButton(
              //     onPressed: () => AuthenticationRepository.instance.logout(), 
              //     // onPressed: () {}, 
              //     child: const Text('logout', style: TextStyle(color: Colors.red),)
              //   ),
              // )

              Center(
                child: TextButton(
                  onPressed: () async {
                    bool? confirmLogout = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Konfirmasi Logout"),
                          content: const Text("Apakah Anda yakin ingin logout?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Batalkan logout
                              },
                              child: const Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Lanjutkan logout
                              },
                              child: const Text("Logout", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmLogout == true) {
                      AuthenticationRepository.instance.logout();
                    }
                  },
                  child: const Text(
                    'logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: Text('Close Account', style: TextStyle(color: Colors.red),),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}