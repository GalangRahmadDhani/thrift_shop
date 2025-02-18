import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/user%20&%20admin/user_repository.dart';
import 'package:ecommerce_app/features/authentication/Admin/Home/admin_home.dart';
import 'package:ecommerce_app/features/authentication/User/screens/login/login.dart';
import 'package:ecommerce_app/features/authentication/User/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/features/authentication/User/screens/signup/verify_email.dart';
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

  Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Check in Admin collection instead of Users collection
        final adminDoc = await _db.collection("Admin").doc(user.uid).get();
        print("Admin check for uid: ${user.uid}");
        print("Admin exists: ${adminDoc.exists}");
        return adminDoc.exists;
      }
      return false;
    } catch (e) {
      print("Error checking admin status: $e");
      return false;
    }
  }

  // Add this helper method
  bool _isAdminEmail(String email) {
    return email.toLowerCase().contains('admin');
  }

  screenRedirect() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        
        // First check if user is admin
        final isAdminUser = await isAdmin();
        
        if (isAdminUser) {
          print("Admin user detected, redirecting to admin screen");
          Get.offAll(() => const AdminHomeScreen());
          return;
        }

        // If not admin, proceed with normal user flow
        if (user.emailVerified) {
          final userRecord = await _db.collection("Users").doc(user.uid).get();
          if (userRecord.exists) {
            Get.offAll(() => const NavigationMenu());
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
      print("Error in screenRedirect: $e"); // Debug print
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

      // If email contains 'admin', create document in Admin collection
      if (_isAdminEmail(email)) {
        await _db.collection("Admin").doc(userCredential.user!.uid).set({
          'Email': email,
          'Username': 'Admin',
        });
      } else {
        await sendEmailVerification();
        Get.offAll(() => const VerifyEmailScreen());
      }

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
  Future<void> logout() async {
    try {
      // Show custom loading dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(seconds: 1));
      await FirebaseAuth.instance.signOut();
      Get.back(); // Close loading dialog
      Get.offAll(() => const LoginScreen());
      
    } on FirebaseAuthException catch (e) {
      Get.back(); // Close loading dialog
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      Get.back(); // Close loading dialog
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      Get.back(); // Close loading dialog
      throw const TFormatException();
    } on PlatformException catch (e) {
      Get.back(); // Close loading dialog
      throw TPlatformException(e.code).message;
    } catch (e) {
      Get.back(); // Close loading dialog
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