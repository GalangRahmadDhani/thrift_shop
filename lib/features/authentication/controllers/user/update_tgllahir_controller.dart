import 'package:ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/profile.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateTgllahirController extends GetxController{
  static UpdateTgllahirController get instance => Get.find();

  // variabel
  final tanggalLahir = TextEditingController();
  final selectedDate = ''.obs;
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateTglLahirFormKey = GlobalKey<FormState>();

  // init home data when home screen muncul
  @override
  void onInit() {
    initializeTglLahir();
    super.onInit();
  }

  // Fetch user record
  Future<void> initializeTglLahir() async {
    selectedDate.value = userController.user.value.tglLahir;
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value = "${picked.day}-${picked.month}-${picked.year}";
      await updateUserTglLahir();
    }
  }

  Future<void> updateUserTglLahir() async {
    try {
      // Start Loading
      // TFullScreenLoader.openLoadingDialog('Kami sedang mengupdate informasi anda...', TImages.loadingJson);

      // Check internet connection
      final isConnected =  await NetworkManager.instance.isConnected();
      if (!isConnected) {
        // TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'Oh Snap', message: 'Tidak ada koneksi internet');
        return;
      }

      // Form validasi
      // if (!updateJenkelFormKey.currentState!.validate()) {
      //   TFullScreenLoader.stopLoading();
      //   return;
      // }

      // Update user first name & last name in firebase firestore
      Map<String, dynamic> tglLahir = {'TglLahir': selectedDate.value};
      await userRepository.updateSingleField(tglLahir);

      // Update Firestore - make sure field name matches exactly
      userController.user.value.tglLahir = selectedDate.value;
      userController.user.refresh();

      // Get.back();

      // remove loader
      // TFullScreenLoader.stopLoading();

      // show success screen
      TLoaders.successSnackBar(title: 'Selamat', message: 'Data anda berhasil di update');

      // Pindah ke halaman sebelumnya
      // Get.back();

    } catch (e) {
      // Remove loader
      // TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}