import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/change/change_jenkel.dart';
import 'package:ecommerce_app/common/widgets/images/t_circular_image.dart';
import 'package:ecommerce_app/common/widgets/shimmer/shimmer.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/authentication/User/controllers/user/update_name_controller.dart';
import 'package:ecommerce_app/features/authentication/User/controllers/user/update_phone_number_controller.dart';
import 'package:ecommerce_app/features/authentication/User/controllers/user/update_tgllahir_controller.dart';
import 'package:ecommerce_app/features/authentication/User/controllers/user/update_username_controller.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    Obx(
                      () {
                        final networkImage = controller.user.value.profilePicture;
                        final image = networkImage.isNotEmpty ? networkImage : TImages.user;
                  
                        return controller.imageUploading.value
                          ? const TShimmerEffect(width: 80, height: 80, radius: 80,)
                          : TCircularImage(image: image, width: 80, height: 80, isNetworkImage: networkImage.isNotEmpty,);
                      }
                    ),
                    TextButton(onPressed: () => controller.uploadUserProfilePicture(), child: const Text('Ubah'))
                  ],
                ),
              ),

              // Heading Profile Info
              const SizedBox(height: TSizes.spaceBtwItems / 2,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              
              const TSectionHeading(title: 'Informasi Profil', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems,),

             
              Obx(() => TProfileMenu(title: 'Nama', value: controller.user.value.fullName, onPressed: () => _showUpdateNameDialog())),
              Obx(() => TProfileMenu(title: 'Username', value: controller.user.value.username, onPressed: () => _showUpdateUsernameDialog())),

              const SizedBox(height: TSizes.spaceBtwItems,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              // Heading Personal Info
              const TSectionHeading(title: 'Informasi Profil', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems,),

              TProfileMenu(
                title: 'User ID', 
                value: controller.user.value.id, 
                icon: Iconsax.copy, 
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: controller.user.value.id),
                  );
                  TLoaders.successSnackBar(
                    title: 'Berhasil',
                    message: 'User ID berhasil disalin',
                  );
                },
              ),
              TProfileMenu(title: 'E-mail', value: controller.user.value.email, onPressed: () {}, showIcon: false,),
              Obx(() => TProfileMenu(title: 'No. Telp', value: controller.user.value.phoneNumber, onPressed: () => _showUpdatePhoneNumberDialog(),)),
              TProfileMenu(title: 'Jns Kelamin', value: controller.user.value.jenkel, onPressed: () => Get.to(() => const ChangeJenkel()),),
              TProfileMenu(title: 'Tgl Lahir', value: controller.user.value.tglLahir, onPressed: () {
                final tglController = Get.put(UpdateTgllahirController());
                tglController.pickDate();
              },),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: const Text('Close Account', style: TextStyle(color: Colors.red),),
                ),
              )
            ],
          ),
        )
      ),
    );
  }


  void _showUpdateNameDialog() {
    final userController = UserController.instance;
    final updateNameController = Get.put(UpdateNameController());
    final TextEditingController firstNameController = TextEditingController(
      text: userController.user.value.firstName
    );
    final TextEditingController lastNameController = TextEditingController(
      text: userController.user.value.lastName
    );
    
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: updateNameController.updateUserNameFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Nama',
                  style: Get.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Depan',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => updateNameController.firstName.text = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Belakang',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => updateNameController.lastName.text = value,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await updateNameController.updateUserName();
                          // Get.back();
                          // Refresh user data after update
                          await userController.fetchUserRecord();
                        } catch (e) {
                          Get.back();
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }   

  void _showUpdateUsernameDialog() {
    final userController = UserController.instance;
    final updateUsernameController = Get.put(UpdateUsernameController());
    final TextEditingController usernameController = TextEditingController(
      text: userController.user.value.username
    );
    
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: updateUsernameController.updateUserUsernameFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Username',
                  style: Get.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Depan',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => updateUsernameController.usernameText.text = value,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await updateUsernameController.updateUserUserName();
                          // Get.back();
                          // Refresh user data after update
                          await userController.fetchUserRecord();
                        } catch (e) {
                          Get.back();
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdatePhoneNumberDialog() {
    final userController = UserController.instance;
    final updatePhoneNumberController = Get.put(UpdatePhoneNumberController());
    final TextEditingController phoneNumberController = TextEditingController(
      text: userController.user.value.phoneNumber
    );
    
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: updatePhoneNumberController.updateUserPhoneNumberFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Nomor Telefon',
                  style: Get.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telefon',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => updatePhoneNumberController.phoneNumber.text = value,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await updatePhoneNumberController.updateUserPhoneNumber();
                          // Get.back();
                          // Refresh user data after update
                          await userController.fetchUserRecord();
                        } catch (e) {
                          Get.back();
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

