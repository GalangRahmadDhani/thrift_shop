import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../features/authentication/User/models/banner_model.dart';

class BannerRepository {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  // Create new banner

  Future<void> createBanner(BannerModel banner) async {
    try {
      // Save to Firestore
      print('Saving banner to Firestore...');
      await _db.collection('Banner').doc(banner.id).set(banner.toJson());
      print('Successfully saved banner to Firestore');

      // Save to RTDB
      try {
        print('Saving to Realtime Database...');
        await _rtdb.child('banners/${banner.id}').set(banner.toRtdbJson());  // Use toRtdbJson
        print('Successfully saved to Realtime Database');
      } catch (rtdbError) {
        print('RTDB Save failed: $rtdbError');
      }
    } catch (e) {
      throw 'Failed to create banner: $e';
    }
  }

  // Future<void> createBanner(BannerModel banner) async {
  //   await _db.collection('Banner').doc(banner.id).set(banner.toJson());
  // }

  // Get all banners
  Stream<List<BannerModel>> getAllBanners() {
    return _db.collection('Banner') // Make sure collection name matches your Firebase
        .where('isActive', isEqualTo: true) // Only get active banners
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BannerModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get banners by admin
  Stream<List<BannerModel>> getBannersByAdmin(String adminUid) {
    return _db.collection('Banner')
        .where('createdBy', isEqualTo: adminUid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BannerModel.fromJson(doc.data())).toList());
  }

  // Get banner update history
  Future<List<String>> getBannerUpdateHistory(String bannerId) async {
    final doc = await _db.collection('Banner').doc(bannerId).get();
    final data = doc.data();
    if (data != null) {
      return [data['createdBy'] as String, data['updatedBy'] as String];
    }
    return [];
  }

  // Update banner

  Future<void> updateBanner(BannerModel banner) async {
    try {
      // Update Firestore
      await _db.collection('Banner').doc(banner.id).update(banner.toJson());

      // Update RTDB
      try {
        await _rtdb.child('banners/${banner.id}').update(banner.toRtdbJson());  // Use toRtdbJson
      } catch (rtdbError) {
        print('RTDB Update failed: $rtdbError');
      }
    } catch (e) {
      throw 'Failed to update banner: $e';
    }
  }

  // Future<void> updateBanner(BannerModel banner) async {
  //   await _db.collection('Banner').doc(banner.id).update(banner.toJson());
  // }

  // Delete banner

  Future<void> deleteBanner(String bannerId) async {
    try {
      // Delete from Firestore
      await _db.collection('Banner').doc(bannerId).delete();

      // Delete from RTDB
      try {
        await _rtdb.child('banners/$bannerId').remove();
      } catch (rtdbError) {
        print('RTDB Delete failed: $rtdbError');
      }
    } catch (e) {
      throw 'Failed to delete banner: $e';
    }
  }

  // Future<void> deleteBanner(String bannerId) async {
  //   await _db.collection('Banner').doc(bannerId).delete();
  // }

  // Toggle banner status

  Future<void> toggleBannerStatus(String bannerId, bool newStatus) async {
    try {
      // Update Firestore
      await _db.collection('Banner').doc(bannerId).update({'isActive': newStatus});

      // Update RTDB
      try {
        await _rtdb.child('banners/$bannerId').update({'isActive': newStatus});
      } catch (rtdbError) {
        print('RTDB Update failed: $rtdbError');
      }
    } catch (e) {
      throw 'Failed to toggle banner status: $e';
    }
  }

  // Future<void> toggleBannerStatus(String bannerId, bool newStatus) async {
  //   await _db.collection('Banner').doc(bannerId).update({'isActive': newStatus});
  // }
}
