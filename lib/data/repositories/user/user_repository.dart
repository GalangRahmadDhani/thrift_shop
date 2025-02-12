import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/models/user_model.dart';
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

  // Future<void> saveUserRecord(UserModel user) async {
  //   try {
  //     // save ke firestore
  //     await _db.collection("Users").doc(user.id).set(user.toJson());

  //     // save ke realtime database
  //     await _rtdb.child("Users/${user.id}").set(user.toJson());
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
  Future<void> saveUserRecord(UserModel user) async {
    try {
      final userJson = {
        'FirstName': user.firstName,
        'LastName': user.lastName,
        'Username': user.username,
        'Email': user.email,
        'PhoneNumber': user.phoneNumber,
        'ProfilePicture': user.profilePicture,
        'Jenkel': user.jenkel,
        'TglLahir': user.tglLahir
      };

      await Future.wait([
        // Save to Firestore
        _db.collection("Users").doc(user.id).set(userJson, SetOptions(merge: true)),
        
        // Save to Realtime Database
        _rtdb.child('users/${user.id}').update(userJson)
      ]);

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

  // Function to fetch user detail based on user ID
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db.collection("Users").doc(AuthenticationRepository.instance.authUser?.uid).get();
      if(documentSnapshot.exists){
        return UserModel.fromSnapshot(documentSnapshot);
      }else{
        return UserModel.empty();
      }
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

  // Function to update user data in Firestore
  Future<void> updateUserDetails(UserModel updateUser) async {
    try {
      // await _db.collection("Users").doc(updateUser.id).update(updateUser.toJson());

      // // Update Realtime Database
      // _rtdb.child('users/${updateUser.id}').update(updateUser.toJson());
    await Future.wait([
      // Update Firestore
      _db.collection("Users").doc(updateUser.id).update(updateUser.toJson()),
      
      // Update Realtime Database
      _rtdb.child('users/${updateUser.id}').update(updateUser.toJson())
    ]);

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