import 'package:ecommerce_app/features/authentication/Admin/Banner/banner_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/repositories/banner/banner_repository.dart';
import 'package:ecommerce_app/features/authentication/User/models/banner_model.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

class BannerController extends GetxController {
  static BannerController get instance => Get.find();
  final BannerRepository _bannerRepository = BannerRepository();
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  
  final bannerFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final imageUrlController = TextEditingController();
  final imageUrl = ''.obs;
  final Rx<bool> isActive = true.obs;
  final Rx<FilePickerResult?> selectedImage = Rx<FilePickerResult?>(null);
  final isLoading = false.obs;
  
  // Stream for banners
  Stream<List<BannerModel>> getBanners() {
    return _bannerRepository.getAllBanners();
  }

  Future<void> createBanner(String title, FilePickerResult imageFile, String adminUid) async {
    try {
      // Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadFile(imageFile);
      if (imageUrl == null) throw Exception('Failed to upload image');

      // Create banner model
      final banner = BannerModel(
        id: const Uuid().v4(),
        imageUrl: imageUrl,
        title: title,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: adminUid,
        updatedBy: adminUid,
      );

      // Save to Firestore
      await _bannerRepository.createBanner(banner);
    } catch (e) {
      throw Exception('Failed to create banner: $e');
    }
  }

  Future<void> updateBanner(BannerModel banner, FilePickerResult? newImage, String adminUid) async {
    try {
      String imageUrl = banner.imageUrl;
      if (newImage != null) {
        // Upload new image if provided
        final newImageUrl = await CloudinaryService.uploadFile(newImage);
        if (newImageUrl != null) {
          imageUrl = newImageUrl;
        }
      }

      final updatedBanner = banner.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );

      await _bannerRepository.updateBanner(updatedBanner);
    } catch (e) {
      throw Exception('Failed to update banner: $e');
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    await _bannerRepository.deleteBanner(bannerId);
  }

  Future<void> toggleBannerStatus(String bannerId, bool newStatus) async {
    try {
      isLoading.value = true;
      await _bannerRepository.toggleBannerStatus(bannerId, newStatus);
      Get.snackbar(
        'Success', 
        'Banner status updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to update banner status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      selectedImage.value = result;
      // Clear URL when file is picked
      imageUrlController.clear();
      imageUrl.value = '';
      update();
    }
  }

  Future<void> saveBanner(String adminUid) async {
    if (bannerFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        String? finalImageUrl;
        
        // Handle image upload or use URL
        if (selectedImage.value != null) {
          finalImageUrl = await CloudinaryService.uploadFile(selectedImage.value!);
        } else if (imageUrlController.text.isNotEmpty) {
          finalImageUrl = imageUrlController.text;
        }

        if (finalImageUrl == null || finalImageUrl.isEmpty) {
          Get.snackbar('Error', 'Please provide an image or URL');
          return;
        }

        // Create banner model
        final banner = BannerModel(
          id: const Uuid().v4(),
          imageUrl: finalImageUrl,
          title: titleController.text,
          isActive: isActive.value,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: adminUid,
          updatedBy: adminUid,
        );

        // Save to Firestore
        await _bannerRepository.createBanner(banner);
        
        // Clear form
        titleController.clear();
        imageUrlController.clear();
        imageUrl.value = '';
        selectedImage.value = null;
        isActive.value = true;
        
        Get.snackbar(
          'Success', 
          'Banner created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.to(() => const BannerListScreen());
      } catch (e) {
        Get.snackbar(
          'Error', 
          'Failed to create banner: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to imageUrlController changes
    imageUrlController.addListener(() {
      imageUrl.value = imageUrlController.text;
    });
    fetchBanners();
  }

  void fetchBanners() {
    try {
      _bannerRepository.getAllBanners().listen((bannersList) {
        banners.value = bannersList;
      });
    } catch (e) {
      print('Error fetching banners: $e');
      banners.value = [];
    }
  }

  @override
  void onClose() {
    imageUrlController.removeListener(() {});
    imageUrlController.dispose();
    titleController.dispose();
    super.onClose();
  }
}
