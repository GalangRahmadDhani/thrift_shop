import 'package:ecommerce_app/data/repositories/user%20&%20admin/user_repository.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/profile.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateJenkelController extends GetxController{
  static UpdateJenkelController get instance => Get.find();

  // variabel
  final jenkelText = TextEditingController();
  final selectedGender = ''.obs;
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateJenkelFormKey = GlobalKey<FormState>();

  // init home data when home screen muncul
  @override
  void onInit() {
    initializeJenkel();
    super.onInit();
  }

  // Set gender
  void setGender(String gender){
    selectedGender.value = gender;   
  }

  // Fetch user record
  Future<void> initializeJenkel() async {
    selectedGender.value = userController.user.value.jenkel;
  }

  Future<void> updateUserJenkel() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Kami sedang mengupdate informasi anda...', TImages.loadingJson);

      // Check internet connection
      final isConnected =  await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validasi
      // if (!updateJenkelFormKey.currentState!.validate()) {
      //   TFullScreenLoader.stopLoading();
      //   return;
      // }

      // Update user first name & last name in firebase firestore
      Map<String, dynamic> jenkel = {'Jenkel' : selectedGender.value,};
      await userRepository.updateSingleField(jenkel);

      // Update the Rx user value
      userController.user.value.jenkel = selectedGender.value;

      // remove loader
      TFullScreenLoader.stopLoading();

      // show success screen
      TLoaders.successSnackBar(title: 'Selamat', message: 'Data anda berhasil di update');

      // Pindah ke halaman sebelumnya
      // Get.back();
      Get.off(() => const ProfileScreen(), preventDuplicates: true, transition: Transition.noTransition);

    } catch (e) {
      // Remove loader
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}