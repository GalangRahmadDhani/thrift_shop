import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../authentication/Admin/Brand & Category/models/category_model.dart';
import '../../../service/cloudinary_service.dart';  // Update import path

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Form related variables
  final categoryFormKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final imageUrl = TextEditingController();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Initialize categories list as empty before fetching
    categories.value = [];
    fetchCategories();
  }

  void fetchCategories() {
    try {
      _categoryRepository.getAllCategories().listen((categoriesList) {
        // Filter out null values and update the list
        categories.value = categoriesList.where((category) => category != null).toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
      categories.value = [];
    }
  }


  // Pick image from gallery
  Future<void> pickCategoryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
    }
  }

  // Clear form
  void clearForm() {
    name.clear();
    imageUrl.clear();
    selectedImage.value = null;
  }

  // Add category with form validation and image upload
  Future<void> addCategory() async {
    if (!categoryFormKey.currentState!.validate()) return;

    try {
      String? imageUrl;
      
      // If image is selected from gallery, upload it to Cloudinary
      if (selectedImage.value != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        
        imageUrl = await CloudinaryService.uploadFile(selectedImage.value!);
        Get.back(); // Close loading dialog

        if (imageUrl == null) {
          Get.snackbar('Error', 'Failed to upload image');
          return;
        }
      } else if (this.imageUrl.text.isNotEmpty) {
        // If URL is provided, use it directly
        imageUrl = this.imageUrl.text.trim();
      }

      final category = CategoryModel(
        name: name.text.trim(),
        image: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _categoryRepository.createCategory(category);
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Category added successfully');
    } catch (e) {
      Get.back(); // Close loading dialog if error occurs
      Get.snackbar('Error', 'Failed to add category: ${e.toString()}');
    }
  }

  // Load category data for editing
  void loadCategoryForEditing(CategoryModel category) {
    name.text = category.name;
    imageUrl.text = category.image ?? '';
    selectedImage.value = null;
  }

  // Edit category with form validation and image upload
  Future<void> editCategory(String categoryId) async {
    if (!categoryFormKey.currentState!.validate()) return;

    try {
      String? imageUrl;
      
      // If image is selected from gallery, upload it to Cloudinary
      if (selectedImage.value != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        
        imageUrl = await CloudinaryService.uploadFile(selectedImage.value!);
        Get.back(); // Close loading dialog

        if (imageUrl == null) {
          Get.snackbar('Error', 'Failed to upload image');
          return;
        }
      } else if (this.imageUrl.text.isNotEmpty) {
        // If URL is provided, use it directly
        imageUrl = this.imageUrl.text.trim();
      }

      final category = CategoryModel(
        id: categoryId,
        name: name.text.trim(),
        image: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _categoryRepository.updateCategory(categoryId, category);
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Category updated successfully');
    } catch (e) {
      Get.back(); // Close loading dialog if error occurs
      Get.snackbar('Error', 'Failed to update category: ${e.toString()}');
    }
  }

  // Confirm and delete category
  Future<void> confirmDelete(String categoryId, String categoryName) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);
      Get.back();
      Get.snackbar('Success', 'Category "$categoryName" deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category');
    }
  }

  @override
  void onClose() {
    name.dispose();
    imageUrl.dispose();
    super.onClose();
  }
}
