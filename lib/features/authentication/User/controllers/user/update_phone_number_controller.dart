import 'package:ecommerce_app/data/repositories/user%20&%20admin/user_repository.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePhoneNumberController extends GetxController {
  static UpdatePhoneNumberController get instance => Get.find();

  // variabel
  final phoneNumber = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserPhoneNumberFormKey = GlobalKey<FormState>();

  // init home data when home screen muncul
  @override
  void onInit() {
    initializePhoneNumber();
    super.onInit();
  }

  // Fetch user record
  Future<void> initializePhoneNumber() async {
    phoneNumber.text = userController.user.value.phoneNumber;
  }

  Future<void> updateUserPhoneNumber() async {
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
      if (!updateUserPhoneNumberFormKey.currentState!.validate()) {
        // TFullScreenLoader.stopLoading();
        return;
      }

      // Update user first name & last name in firebase firestore
      Map<String, dynamic> nomorHp = {'PhoneNumber' : phoneNumber.text.trim(),};
      await userRepository.updateSingleField(nomorHp);

      // Update the Rx user value
      userController.user.value.phoneNumber = phoneNumber.text.trim();

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