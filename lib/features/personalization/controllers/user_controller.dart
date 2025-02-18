import 'package:ecommerce_app/common/widgets/change/re_auth_login_form.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:ecommerce_app/data/repositories/user%20&%20admin/user_repository.dart';
import 'package:ecommerce_app/features/authentication/User/models/user_model.dart';
import 'package:ecommerce_app/features/authentication/User/screens/login/login.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  
  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;

  final hidePassword = true.obs;
  final imageUploading = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

// Add refresh method if not exists
void refreshUserData() {
  user.refresh();
}
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  // Save user record from any registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      // First update Rx user and then check if user data is already stored. If not, store new data
      await fetchUserRecord();

      // If no record already stored
      if (user.value.id.isEmpty) {
        if (userCredentials != null) {
          // Convert name to first name and last name
          final nameParts = UserModel.nameParts(userCredentials.user!.displayName ?? '');
          final username = UserModel.generateUsername(userCredentials.user!.displayName ?? '');

          // Map data
          final user = UserModel(
            id: userCredentials.user!.uid,
            firstName: nameParts[0],
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            username: username,
            email: userCredentials.user!.email ?? '',
            phoneNumber: userCredentials.user!.phoneNumber ?? '',
            profilePicture: userCredentials.user!.photoURL ?? '',
            jenkel: '',
            tglLahir: '',
            role: '',
          );

          // Save user data
          await userRepository.saveUserRecord(user);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Data tidak tersimpan',
        message: 'Ada yang salah saat menyimpan informasi Anda. Anda dapat menyimpan kembali data Anda di profil Anda.',
      );
    }
  }

  // Delete account warning
  // void deleteAccountWarningPopup(){
  //   Get.defaultDialog(
  //     contentPadding: const EdgeInsets.all(TSizes.md),
  //     title: 'Hapus Akun',
  //     middleText: 'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat dibatalkan dan semua data Anda akan dihapus secara permanen.',
  //     confirm: ElevatedButton(
  //       onPressed: () async => deleteUserAccount(), 
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Colors.red, 
  //         side: const BorderSide(color: Colors.red),
  //         minimumSize: const Size(100, 40),
  //       ), 
  //       child: const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: TSizes.lg), 
  //         child: Text('Hapus'),
  //       )
  //     ),
  //     cancel: OutlinedButton(
  //       onPressed: () => Navigator.of(Get.overlayContext!).pop(), 
  //       style: OutlinedButton.styleFrom(
  //         side: const BorderSide(color: Colors.blue),
  //         minimumSize: const Size(100, 40),
  //       ), 
  //       child: const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: TSizes.lg), 
  //         child: Text('Batal'),
  //       ),
  //     ),
  //   );
  // }

  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Hapus Akun',
      middleText:
          'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat dibatalkan dan semua data Anda akan dihapus secara permanen.',
      actions: [
        IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(Get.overlayContext!).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 15),
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,),
                    child: Text('Batal'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: ElevatedButton(
                  onPressed: () async => deleteUserAccount(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 15),
                    backgroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,),
                    child: Text('Hapus'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Delete user account
  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog('Proses...', TImages.loadingJson);

      // First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;
      if(provider.isNotEmpty){
        // re Verify Auth Email
        if(provider == 'google.com'){
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAll(() => const LoginScreen());
        } else if (provider == 'password') {
          TFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthLoginForm());
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!' , message: e.toString());
    }
  }

  /// - RE-AUTHENTICATE before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog('Proses...', TImages.loadingJson);

      final isConnected =  await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if(!reAuthFormKey.currentState!.validate()){
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());
      await AuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!' , message: e.toString());
    }
  }

  // Upload Profile User
uploadUserProfilePicture() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      imageUploading.value = true;

      // Upload to Cloudinary and get URL
      String? imageUrl = await uploadToCloudinary(result);
      
      if (imageUrl != null) {
        // Update user image record
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await userRepository.updateSingleField(json);

        user.value.profilePicture = imageUrl;
        user.refresh();

        TLoaders.successSnackBar(
          title: 'Berhasil', 
          message: 'Foto profil berhasil diubah'
        );
      } else {
        throw 'Gagal mendapatkan URL gambar';
      }
    }
  } catch (e) {
    TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
  } finally {
    imageUploading.value = false;
  }
}
} 