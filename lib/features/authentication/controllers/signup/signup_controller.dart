import 'package:ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:ecommerce_app/features/authentication/models/user_model.dart';
import 'package:ecommerce_app/features/authentication/screens/signup/verify_email.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // Variables
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Sign up
  void signup() async{
    try {

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
          title: 'Menerima Kebijakan Privasi', 
          message: 'Untuk membuat akun, Anda harus membaca dan menerima Kebijakan Privasi & Ketentuan Penggunaan.'
        );
        return;
      }

      // Start loading
      TFullScreenLoader.openLoadingDialog("Kami sedang memproses informasi anda...", TImages.loadingJson);

      // Check Internet Connection
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
       // Remove Loader
       TFullScreenLoader.stopLoading();
       return; 
      }
      
      // Form validation
      if(!signupFormKey.currentState!.validate()){
        // Remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }
      

      // Register user in the firebase Authentication & save user data in the firebase
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(email.text.trim(), password.text.trim());

      // save authenticated user data in the firebase firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: username.text.trim(),
        // password: password.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
        jenkel: '',
        tglLahir: '',
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // show success message
      TLoaders.successSnackBar(title: 'Selamat!', message: 'Akun anda sudah di buat! Verifikasi email untuk lanjut.');

      // move to verify email screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim(),));

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // show some generic error to the user 
      TLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
    } 
  }
}