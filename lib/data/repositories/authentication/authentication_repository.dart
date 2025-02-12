import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:ecommerce_app/features/authentication/screens/login/login.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/features/authentication/screens/signup/verify_email.dart';
import 'package:ecommerce_app/navigation_menu.dart';
import 'package:ecommerce_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/firebase_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/format_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  // Get authenticated user data
  User? get authUser => _auth.currentUser;
  
  // called from main.dart on app launch
  @override
  void onReady() {
    // Remove native splash screen
    FlutterNativeSplash.remove();
    // Redirect to apropriate screen
    screenRedirect();
  }

  /// [Fungsi untuk menunjukan layar revelan]
  // screenRedirect() async{
  //   final user = _auth.currentUser;
  //   if(user != null){
  //     if(user.emailVerified){
  //       Get.offAll(
  //         () => const NavigationMenu(), 
  //         transition: Transition.rightToLeftWithFade, 
  //         duration: const Duration(milliseconds: 500), 
  //         popGesture: true, 
  //         curve: Curves.easeInOut
  //       );
  //     } else {
  //       Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email,));
  //       if (kDebugMode) {
  //         print(user.getIdToken());
  //       }
  //     }
  //   } else {

  //     // if(kDebugMode){
  //     //   print('====== Get Storage Auth Repo ======');
  //     //   print(deviceStorage.read('IsFirstTime'));
  //     // }

  //     // Local storage
  //     deviceStorage.writeIfNull('IsFirstTime', true);
  //     // check apakah pertama kali membuka aplikasi
  //     deviceStorage.read('IsFirstTime') != true 
  //       ? Get.offAll(() => const LoginScreen()) 
  //       : Get.offAll(const OnboardingScreen());
  //   }
  // }

screenRedirect() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      // Reload user untuk mendapatkan status verifikasi terbaru
      await user.reload();
      
      if (user.emailVerified) {
        // Pastikan data user ada di Realtime DB
        final userRecord = await _db.collection("Users").doc(user.uid).get();
        if (userRecord.exists) {
          Get.offAll(
            () => const NavigationMenu(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 500)
          );
        } else {
          Get.offAll(() => const LoginScreen());
        }
      } else {
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);
      deviceStorage.read('IsFirstTime') != true
        ? Get.offAll(() => const LoginScreen())
        : Get.offAll(() => const OnboardingScreen());
    }
  } catch (e) {
    Get.offAll(() => const LoginScreen());
  }
}

  /* Email & Password Sign in*/ 

  /// [EmailAuthentication] - Sign In
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Register
  // Future<UserCredential> registerWithEmailAndPassword(String email, String password) async{
  //   try {
  //     return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  //   } on FirebaseAuthException catch (e) {
  //     throw TFirebaseAuthException(e.code).message;
  //   } on FirebaseException catch (e) {
  //     throw TFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw const TFormatException();
  //   } on PlatformException catch (e) {
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again.';
  //   }
  // }
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Check for temporary/disposable email domains
      if (email.contains('temp') || email.contains('disposable')) {
        throw 'Mohon gunakan email yang valid';
      }

      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Send verification email
      await sendEmailVerification();

      // Redirect to verification screen instead of saving data immediately
      Get.offAll(() => const VerifyEmailScreen());

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// [EmailAuthentication] - Mail Verification
  Future<void> sendEmailVerification() async{
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    }  on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async{
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      // Reauthenticate 
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    }  on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }


  /// [EmailAuthentication] - Forget Password
  Future<void> sendPasswordResetEmail(String email) async{
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    }  on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  } 


  /* Federated identity & social sign in*/ 

  // [GoogleAuthentication] - Sign In
  Future<UserCredential?> signInWithGoogle() async{
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      // Obtaine the auth details from request
      final GoogleSignInAuthentication? googleAuth = await userAccount?.authentication;

      // create a new credential
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken  
      );

      // Once signin, return the UserCredential
      return await _auth.signInWithCredential(credentials);

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    }  on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

  // [FacebookAuthentication] - Sign In

  /* /end Federated identity & social sign in*/ 

  // [Logout user] - valid for any authentication
  Future<void> logout() async{
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Delete user - valid for any authentication
  Future<void> deleteAccount() async{
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

}