import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../features/authentication/Admin/Brand & Category/models/brand_model.dart';

class BrandRepository {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  // Create a new brand
  // Future<void> createBrand(BrandModel brand) async {
  //   await _db.collection('Brands').add(brand.toJson());
  // }

Future<void> createBrand(BrandModel brand) async {
  try {
    // Create document reference with auto-generated ID
    final docRef = _db.collection('Brands').doc();
    
    final brandData = {
      ...brand.toJson(),
      'id': docRef.id,
    };

    // Save to Firestore
    print('Saving brand to Firestore...');
    await docRef.set(brandData);
    print('Successfully saved brand to Firestore');

    // Save to RTDB
    try {
      print('Saving to Realtime Database...');
      await _rtdb.child('brands/${docRef.id}').set(brandData);
      print('Successfully saved to Realtime Database');
    } catch (rtdbError) {
      print('RTDB Save failed: $rtdbError');
      // Log the error details
      print('Error details: ${rtdbError.toString()}');
    }
  } catch (e) {
    print('Error in createBrand: $e');
    throw 'Error creating brand: $e';
  }
}

  // Get all brands
  Stream<List<BrandModel>> getAllBrands() {
    return _db.collection('Brands').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList());
  }

  // Add this new method
  Stream<List<BrandModel>> getBrandById(String brandName) {
    return _db
        .collection('Brands')
        .where('name', isEqualTo: brandName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BrandModel.fromSnapshot(doc))
            .toList());
  }

  // Delete brand
  Future<void> deleteBrand(String brandId) async {
    await _db.collection('Brands').doc(brandId).delete();
  }

  // Update brand
  Future<void> updateBrand(String brandId, BrandModel brand) async {
    await _db.collection('Brands').doc(brandId).update(brand.toJson());
  }
}
