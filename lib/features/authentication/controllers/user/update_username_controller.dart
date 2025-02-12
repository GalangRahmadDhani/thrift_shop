import 'package:ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/profile.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';

class UpdateUsernameController extends GetxController {
  static UpdateUsernameController get instance => Get.find();

  // variabel
  final usernameText = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserUsernameFormKey = GlobalKey<FormState>();

  // init home data when home screen muncul
  @override
  void onInit() {
    initializeUsernames();
    super.onInit();
  }

  // Fetch user record
  Future<void> initializeUsernames() async {
    usernameText.text = userController.user.value.username;
  }

  Future<void> updateUserUserName() async {
    try {
      // Start Loading
      // TFullScreenLoader.openLoadingDialog('Kami sedang mengupdate informasi anda...', TImages.loadingJson);

      // Check internet connection
      final isConnected =  await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validasi
      if (!updateUserUsernameFormKey.currentState!.validate()) {
        // TFullScreenLoader.stopLoading();
        return;
      }

      // Update user first name & last name in firebase firestore
      Map<String, dynamic> username = {'Username' : usernameText.text.trim(),};
      await userRepository.updateSingleField(username);

      // Update the Rx user value
      userController.user.value.username = usernameText.text.trim();

      // Close dialog
      Get.back();

      // remove loader
      // TFullScreenLoader.stopLoading();

      // show success screen
      TLoaders.successSnackBar(title: 'Selamat', message: 'Data anda berhasil di update');

      // Pindah ke halaman sebelumnya
      // Get.back();
      // Get.off(() => const ProfileScreen(), preventDuplicates: true, transition: Transition.noTransition);

    } catch (e) {
      // Remove loader
      // TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  
}