import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/brand/brand_repository.dart';
import '../../authentication/Admin/Brand & Category/models/brand_model.dart';
import '../../../service/cloudinary_service.dart';

class BrandController extends GetxController {
  final BrandRepository _brandRepository = BrandRepository();
  final RxList<BrandModel> brands = <BrandModel>[].obs;

  // Form related variables
  final brandFormKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final imageUrl = TextEditingController();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  void fetchBrands() {
    _brandRepository.getAllBrands().listen((brandsList) {
      brands.value = brandsList;
    });
  }

  // Pick image from gallery
  Future<void> pickBrandImage() async {
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

  // Add brand with form validation and image upload
  Future<void> addBrand() async {
    if (!brandFormKey.currentState!.validate()) return;

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

      final brand = BrandModel(
        name: name.text.trim(),
        image: imageUrl,
        isFeatured: true, // Add this - set to true for verified icon
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _brandRepository.createBrand(brand);
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Brand added successfully');
    } catch (e) {
      Get.back(); // Close loading dialog if error occurs
      Get.snackbar('Error', 'Failed to add brand: ${e.toString()}');
    }
  }

  Future<void> updateBrand(String brandId, BrandModel brand) async {
    await _brandRepository.updateBrand(brandId, brand);
  }

  Future<void> deleteBrand(String brandId) async {
    await _brandRepository.deleteBrand(brandId);
  }

  // Load brand data for editing
  void loadBrandForEditing(BrandModel brand) {
    name.text = brand.name;
    imageUrl.text = brand.image ?? '';
    selectedImage.value = null;
  }

  // Edit brand with form validation and image upload
  Future<void> editBrand(String brandId) async {
    if (!brandFormKey.currentState!.validate()) return;

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

      final brand = BrandModel(
        id: brandId,
        name: name.text.trim(),
        image: imageUrl,
        updatedAt: DateTime.now(),
      );

      await updateBrand(brandId, brand);
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Brand updated successfully');
    } catch (e) {
      Get.back(); // Close loading dialog if error occurs
      Get.snackbar('Error', 'Failed to update brand: ${e.toString()}');
    }
  }

  // Confirm and delete brand
  Future<void> confirmDelete(String brandId, String brandName) async {
    try {
      await _brandRepository.deleteBrand(brandId);
      Get.back(); // Close dialog
      Get.snackbar('Success', 'Brand "$brandName" deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete brand');
    }
  }

  // Add this new method to get brand by ID
  Stream<List<BrandModel>> getBrandById(String brandId) {
    return _brandRepository.getBrandById(brandId);
  }

  @override
  void onClose() {
    name.dispose();
    imageUrl.dispose();
    super.onClose();
  }
}
