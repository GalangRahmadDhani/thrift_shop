import 'package:ecommerce_app/features/authentication/Admin/Product/product_list.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';  // Add this import
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final _productRepo = ProductRepository.instance;
  final loading = false.obs;
  final products = <ProductModel>[].obs;
  final categoryProducts = <ProductModel>[].obs;
  final wishlistProducts = <ProductModel>[].obs;

  // Form controllers
  final productFormKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final discountPrice = TextEditingController();
  final brand = TextEditingController();
  final category = TextEditingController();
  final stock = TextEditingController();
  final imageUrl = TextEditingController();
  final selectedImage = Rxn<XFile>();

  // Search functionality
  final searchController = TextEditingController();
  final searchResults = <ProductModel>[].obs;
  final isSearching = false.obs;

  @override
  void onInit() {
    print('ProductController onInit called'); // Debugging
    fetchAllProducts();
    super.onInit();
  }

  // Fetch all products
  Future<void> fetchAllProducts() async {
    try {
      loading.value = true;
      final List<ProductModel> allProducts = await _productRepo.getAllProducts();
      print('Fetched ${allProducts.length} products'); // Debugging
      products.value = allProducts; // Use .value instead of assignAll
    } catch (e) {
      print('Error in fetchAllProducts: $e'); // Debugging
      Get.snackbar('Error', 'Failed to fetch products: ${e.toString()}');
    } finally {
      loading.value = false;
    }
  }

  // Get products by category
  Future<void> getProductsByCategory(String category) async {
    try {
      loading.value = true;
      final List<ProductModel> categoryProds = await _productRepo.getProductsByCategory(category);
      categoryProducts.value = categoryProds; // Use .value instead of assignAll
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch category products: ${e.toString()}');
    } finally {
      loading.value = false;
    }
  }

  // Create product
  Future<void> createProduct(ProductModel product) async {
    try {
      loading.value = true;
      await _productRepo.saveProduct(product);
      await fetchAllProducts(); // Refresh list
      Get.snackbar('Success', 'Product created successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      loading.value = true;
      await _productRepo.updateProduct(id, data);
      await fetchAllProducts(); // Refresh list
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      loading.value = true;
      await _productRepo.deleteProduct(id);
      products.removeWhere((product) => product.id == id);
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  // Add product method
  Future<void> addProduct() async {
    try {
      if (!productFormKey.currentState!.validate()) return;

      loading.value = true;

      // Handle image upload or URL first
      String? imageUrl = await handleImageUpload();
      
      final product = ProductModel(
        id: '', 
        name: name.text.trim(),
        description: description.text.trim(),
        // Update images array with the new image URL if available
        images: imageUrl != null ? [imageUrl] : [],
        price: double.parse(price.text.trim()).toInt(),
        salePrice: discountPrice.text.isEmpty 
            ? null 
            : double.parse(discountPrice.text.trim()).toInt(),
        isSale: discountPrice.text.isNotEmpty,
        brand: brand.text.trim(),
        category: category.text.trim(),
        stock: int.tryParse(stock.text.trim()) ?? 0,
        sizes: {},
        color: '',
        isAvailable: true,
        totalSales: 0,
        rating: 0.0,
        reviewCount: 0,
        lastSaleAt: DateTime.now(),
        viewCount: 0,
        discountPercentage: discountPrice.text.isNotEmpty 
            ? ((double.parse(price.text.trim()) - double.parse(discountPrice.text.trim())) / 
               double.parse(price.text.trim()) * 100).round() 
            : null,
      );

      // Save product
      await _productRepo.saveProduct(product);
      
      // Clear form
      clearForm();

      // Show success message
      Get.snackbar(
        'Success',
        'Product added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Refresh product list and navigate back
      await fetchAllProducts();
      Get.off(() => const ProductListScreen());
      
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  // Clear form fields
  void clearForm() {
    name.clear();
    description.clear();
    price.clear();
    discountPrice.clear();
    brand.clear();
    category.clear();
    stock.clear();
    imageUrl.clear();
    selectedImage.value = null;
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    searchResults.value = products.where((product) {
      final nameMatch = product.name.toLowerCase().contains(query.toLowerCase());
      final brandMatch = product.brand.toLowerCase().contains(query.toLowerCase());
      final categoryMatch = product.category.toLowerCase().contains(query.toLowerCase());
      return nameMatch || brandMatch || categoryMatch;
    }).toList();
  }

  // Pick image from gallery
  Future<void> pickProductImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        selectedImage.value = image;
        // Clear URL field when image is picked
        imageUrl.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Update the image handling in update/save methods
  Future<String?> handleImageUpload() async {
    try {
      if (selectedImage.value != null) {
        // First create FilePickerResult from XFile
        final result = FilePickerResult([
          PlatformFile(
            path: selectedImage.value!.path,
            name: selectedImage.value!.name,
            size: await selectedImage.value!.length(),
          )
        ]);
        
        // Then upload to Cloudinary
        return await uploadToCloudinary(result);
      } else if (imageUrl.text.isNotEmpty) {
        // Use provided URL
        return imageUrl.text;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null;
    }
  }

  // Remove or comment out the old Firebase Storage upload method
  // Future<String> uploadProductImage(String path, XFile image) async { ... }

  // Toggle wishlist status
  Future<void> toggleWishlist(String productId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Please login first');
        return;
      }

      loading.value = true;
      await _productRepo.toggleWishlist(productId, userId);
      await fetchWishlist(); // Refresh wishlist
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  // Fetch user's wishlist
  Future<void> fetchWishlist() async {
    try {
      loading.value = true;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final List<ProductModel> userWishlist = await _productRepo.getWishlistProducts(userId);
      wishlistProducts.value = userWishlist;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    imageUrl.dispose();
    searchController.dispose();
    name.dispose();
    description.dispose();
    price.dispose();
    discountPrice.dispose();
    brand.dispose();
    category.dispose();
    stock.dispose();
    super.onClose();
  }
}
