import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/User/screens/password_configuration/reset_password.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  // Variabel
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  // Send reset password mail
  sendPasswordResetMail() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog('Memproses informasi anda...', TImages.loadingJson);

      // check internet connection
      final isConnected =  await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form validasi
      if (!forgetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // send email to reset password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

      // Remove loader
      TFullScreenLoader.stopLoading();

      // show success screen
      TLoaders.successSnackBar(title: 'Email terkirim', message: 'Email Link Sent to Reset Your Password'.tr);
      
      // Redirect
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));
    } catch (e) {
      // Remove loader
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  resendPasswordResetMail(String email) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog('Memproses informasi anda...', TImages.loadingJson);

      // check internet connection
      final isConnected =  await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // send email to reset password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      // Remove loader
      TFullScreenLoader.stopLoading();

      // show success screen
      TLoaders.successSnackBar(title: 'Email terkirim', message: 'Email Link Sent to Reset Your Password'.tr);
      
    } catch (e) {
      // Remove loader
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}