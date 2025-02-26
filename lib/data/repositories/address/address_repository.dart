import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/User/models/address_model.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  Future<String> addAddress(AddressModel address) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final docId = '${address.userId}_ADDR_$timestamp';

      final addressData = {
        ...address.toJson(),
        'id': docId,
      };

      // Save to Firestore
      debugPrint('Saving address to Firestore...');
      await _db.collection('Addresses').doc(docId).set(addressData);
      debugPrint('Successfully saved address to Firestore');

      // Save to RTDB
      try {
        debugPrint('Saving to Realtime Database...');
        await _rtdb.child('addresses/$docId').set(addressData);
        debugPrint('Successfully saved to Realtime Database');
      } catch (rtdbError) {
        debugPrint('RTDB Save failed: $rtdbError');
      }
      
      return docId;
    } catch (e) {
      debugPrint('Error adding address: $e');
      throw 'Something went wrong while adding the address';
    }
  }

  // Future<String> addAddress(AddressModel address) async {
  //   try {
  //     final timestamp = DateTime.now().millisecondsSinceEpoch;
  //     final docId = '${address.userId}_ADDR_$timestamp';

  //     final doc = _db.collection('Addresses').doc(docId);
  //     await doc.set(address.toJson());
      
  //     return docId;
  //   } catch (e) {
  //     debugPrint('Error adding address: $e');
  //     throw 'Something went wrong while adding the address';
  //   }
  // }

  // Get all addresses for a user
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      debugPrint('Fetching addresses for user: $userId'); // Debug log
      
      final snapshot = await _db
          .collection('Addresses')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('Found ${snapshot.docs.length} addresses'); // Debug log

      return snapshot.docs.map((doc) {
        debugPrint('Processing document ID: ${doc.id}'); // Debug log
        return AddressModel.fromSnapshot(doc);
      }).toList();
    } catch (e) {
      debugPrint('Error getting addresses: $e');
      throw 'Something went wrong while fetching addresses';
    }
  }

  // Get default address
  Future<AddressModel?> getUserDefaultAddress(String userId) async {
    try {
      final snapshot = await _db
          .collection('Addresses')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return AddressModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting default address: $e');
      throw 'Something went wrong while fetching default address';
    }
  }


  Future<void> updateAddress(String addressId, Map<String, dynamic> data) async {
    try {
      // Update Firestore
      await _db.collection('Addresses').doc(addressId).update(data);

      // Update RTDB
      try {
        await _rtdb.child('addresses/$addressId').update(data);
      } catch (rtdbError) {
        debugPrint('RTDB Update failed: $rtdbError');
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
      throw 'Something went wrong while updating the address';
    }
  }

  // Update address
  // Future<void> updateAddress(String addressId, Map<String, dynamic> data) async {
  //   try {
  //     await _db.collection('Addresses').doc(addressId).update(data);
  //   } catch (e) {
  //     debugPrint('Error updating address: $e');
  //     throw 'Something went wrong while updating the address';
  //   }
  // }

  Future<void> deleteAddress(String addressId) async {
    try {
      // Delete from Firestore
      await _db.collection('Addresses').doc(addressId).delete();

      // Delete from RTDB
      try {
        await _rtdb.child('addresses/$addressId').remove();
      } catch (rtdbError) {
        debugPrint('RTDB Delete failed: $rtdbError');
      }
    } catch (e) {
      debugPrint('Error deleting address: $e');
      throw 'Something went wrong while deleting the address';
    }
  }

  // Delete address
  // Future<void> deleteAddress(String addressId) async {
  //   try {
  //     await _db.collection('Addresses').doc(addressId).delete();
  //   } catch (e) {
  //     debugPrint('Error deleting address: $e');
  //     throw 'Something went wrong while deleting the address';
  //   }
  // }

  // Update all addresses to non-default except the given addressId
  Future<void> updateDefaultAddress(String userId, String defaultAddressId) async {
    try {
      // Get all addresses for the user
      final snapshot = await _db
          .collection('Addresses')
          .where('userId', isEqualTo: userId)
          .get();

      // Create a batch write
      final batch = _db.batch();

      // Update each address
      for (var doc in snapshot.docs) {
        batch.update(
          doc.reference,
          {'isDefault': doc.id == defaultAddressId},
        );
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      debugPrint('Error updating default address: $e');
      throw 'Something went wrong while updating default address';
    }
  }
}
