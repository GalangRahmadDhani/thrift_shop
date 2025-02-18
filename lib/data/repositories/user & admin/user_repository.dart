import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/User/models/user_model.dart';
import 'package:ecommerce_app/utils/exceptions/firebase_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/format_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();


  // Function to save user data to Firestore.

  Future<void> saveUserRecord(UserModel user) async {
    try {
      final userData = {
        'FirstName': user.firstName,
        'LastName': user.lastName,
        'Username': user.username,
        'Email': user.email,
        'PhoneNumber': user.phoneNumber,
        'ProfilePicture': user.profilePicture,
        'Jenkel': user.jenkel,
        'TglLahir': user.tglLahir,
        'Role': user.role, // Pastikan field Role ada
      };

      // Log untuk debugging
      print('Saving user data: $userData');

      await Future.wait([
        _db.collection("Users").doc(user.id).set(userData),
        _rtdb.child('users/${user.id}').set(userData)
      ]);

      // Verifikasi data tersimpan
      final savedData = await _db.collection("Users").doc(user.id).get();
      print('Saved data: ${savedData.data()}');

    } catch (e) {
      print('Error saving user data: $e');
      throw 'Error saving user data: $e';
    }
  }

  // Function to fetch user detail based on user ID
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db.collection("Users").doc(AuthenticationRepository.instance.authUser?.uid).get();
      
      if(documentSnapshot.exists){
        final data = documentSnapshot.data()!;
        // Explicitly check for role field
        if (!data.containsKey('Role')) {
          // If role field doesn't exist, update document with default role
          await _db.collection("Users").doc(documentSnapshot.id).update({'Role': 'user'});
          data['Role'] = 'user';
        }
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Error fetching user details: $e';
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUserDetails(UserModel updateUser) async {
    try {
      final userJson = updateUser.toJson();
      // Pastikan role tidak bisa diubah melalui update biasa
      if (userJson.containsKey('Role')) {
        userJson.remove('Role');
      }

      await Future.wait([
        _db.collection("Users").doc(updateUser.id).update(userJson),
        _rtdb.child('users/${updateUser.id}').update(userJson)
      ]);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Error updating user details: $e';
    }
  }  

  // Update any field in spesific Users collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
    String? userId = AuthenticationRepository.instance.authUser?.uid;
    if (userId == null) throw 'User ID not found';

    // Update Firestore
    await _db.collection("Users").doc(userId).update(json);

    // Update Realtime Database
    await _rtdb.child('users/$userId').update(json);

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

  // function to remove user data from firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      // hapus dari firestore
      await _db.collection("Users").doc(userId).delete();

      // Remove from Realtime Database
      await _rtdb.child('users/$userId').remove();
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

  // Uploade Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;

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