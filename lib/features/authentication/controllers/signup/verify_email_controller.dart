import 'dart:async';

import 'package:ecommerce_app/common/widgets/success_screen/success_screen.dart';
import 'package:ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  // Send Email kapanpun Verify Screen muncul & set timer untuk auto redirect
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  // Send email verification Link
  sendEmailVerification() async{
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(title: 'Email Terkirim', message: 'Silakan periksa email dan verifikasi email Anda.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  // Timer untuk redirect ketika email verification
  setTimerForAutoRedirect() async{
    Timer.periodic(
      const Duration(seconds: 1), 
      (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) { 
          timer.cancel();
          Get.off(() => SuccessScreen(
            image: TImages.successFullyRegisterAnimation, 
            title: TTexts.yourAccountCreatedTitle, 
            subTitle: TTexts.yourAccountCreatedSubTitle, 
            onPressed: () => AuthenticationRepository.instance.screenRedirect(),
            ),
          );
        }
      }
    );
  }

  // chech secara manual jika email terverifikasi
  checkEmailVerificationStatus() async{
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      Get.off(
        () => SuccessScreen(
          image: TImages.successFullyRegisterAnimation, 
          title: TTexts.yourAccountCreatedTitle, 
          subTitle: TTexts.yourAccountCreatedSubTitle, 
          onPressed: () => AuthenticationRepository.instance.screenRedirect(),
        )
      );
    }
  }
}