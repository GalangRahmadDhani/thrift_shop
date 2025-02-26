import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../features/authentication/Admin/Brand & Category/models/category_model.dart';

class CategoryRepository {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance.ref();

  // Create a new category
  // Future<void> createCategory(CategoryModel category) async {
  //   await _db.collection('Categories').add(category.toJson());
  // }
  Future<void> createCategory(CategoryModel category) async {
    try {
      // Create document reference with auto-generated ID
      final docRef = _db.collection('Categories').doc();
      
      final categoryData = {
        ...category.toJson(),
        'id': docRef.id,
      };

      // Save to Firestore
      print('Saving category to Firestore...');
      await docRef.set(categoryData);
      print('Successfully saved category to Firestore');

      // Save to RTDB
      try {
        print('Saving to Realtime Database...');
        await _rtdb.child('categories/${docRef.id}').set(categoryData);
        print('Successfully saved to Realtime Database');
      } catch (rtdbError) {
        print('RTDB Save failed: $rtdbError');
        print('Error details: ${rtdbError.toString()}');
      }
    } catch (e) {
      print('Error in createCategory: $e');
      throw 'Error creating category: $e';
    }
  }

  // Get all categories
  Stream<List<CategoryModel>> getAllCategories() {
    return _db.collection('Categories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList());
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('Categories').doc(categoryId).delete();
  }

  // Update category
  Future<void> updateCategory(String categoryId, CategoryModel category) async {
    await _db.collection('Categories').doc(categoryId).update(category.toJson());
  }
}
