import 'dart:async';

import 'package:ecommerce_app/common/widgets/success_screen/success_screen.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:ecommerce_app/data/repositories/user%20&%20admin/user_repository.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  // Timer? _timer;
  final userRepository = Get.put(UserRepository());

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
  // setTimerForAutoRedirect() async{
  //   _timer = Timer.periodic(
  //     const Duration(seconds: 2), 
  //     (timer) async {
  //       try {
  //         // Force reload user
  //         await FirebaseAuth.instance.currentUser?.reload();
  //         final user = FirebaseAuth.instance.currentUser;
          
  //         print("Checking verification status: ${user?.emailVerified}"); // Debug

  //         if (user?.emailVerified ?? false) {
  //           timer.cancel();
  //           Get.offAll(
  //             () => SuccessScreen(
  //               image: TImages.successFullyRegisterAnimation,
  //               title: TTexts.yourAccountCreatedTitle,
  //               subTitle: TTexts.yourAccountCreatedSubTitle,
  //               onPressed: () => AuthenticationRepository.instance.screenRedirect(),
  //             ),
  //             predicate: (route) => false,
  //           );
  //         }
  //       } catch (e) {
  //         print("Verification check error: $e"); // Debug
  //         timer.cancel();
  //         TLoaders.errorSnackBar(title: 'Error', message: e.toString());
  //       }
  //     }
  //   );
  // }

setTimerForAutoRedirect() {
  Timer.periodic(
    const Duration(seconds: 3), 
    (timer) async {
      try {
        // Force reload user dan cek status verifikasi
        User? currentUser = FirebaseAuth.instance.currentUser;
        await currentUser?.reload();
        final isVerified = currentUser?.emailVerified ?? false;
        
        if (isVerified) {
          timer.cancel();
          // Update user data di Realtime Database setelah verifikasi
          final user = await userRepository.fetchUserDetails();
          await userRepository.saveUserRecord(user);
          
          Get.offAll(
            () => SuccessScreen(
              image: TImages.successFullyRegisterAnimation,
              title: TTexts.yourAccountCreatedTitle,
              subTitle: TTexts.yourAccountCreatedSubTitle,
              onPressed: () => AuthenticationRepository.instance.screenRedirect(),
            ),
            predicate: (route) => false,
          );
        }
      } catch (e) {
        timer.cancel();
        TLoaders.errorSnackBar(title: 'Error', message: e.toString());
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