import 'package:ecommerce_app/features/authentication/Admin/Brand%20&%20Category/models/brand_model.dart';
import 'package:ecommerce_app/features/authentication/Admin/Brand%20&%20Category/models/category_model.dart';
import 'package:ecommerce_app/features/authentication/Admin/Product/product_list.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';
import 'package:ecommerce_app/utils/popups/loaders.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';  // Add this import
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';  // Add this import at the top

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  
  // Add this line near other instance declarations
  final firestore = FirebaseFirestore.instance;
  final isBrandsLoading = false.obs;
  final isCategoriesLoading = false.obs;

  final _productRepo = ProductRepository.instance;
  final loading = false.obs;
  final products = <ProductModel>[].obs;
  final categoryProducts = <ProductModel>[].obs;
  final wishlistProducts = <ProductModel>[].obs;

  // Separate form keys for add and edit
  final addProductFormKey = GlobalKey<FormState>();
  final editProductFormKey = GlobalKey<FormState>();

  // Form controllers
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

  // Variables for dropdown - Rename these to be more specific
  RxList<String> brandNames = <String>[].obs;
  RxList<String> categoryNames = <String>[].obs;
  RxString selectedCategory = ''.obs;
  RxString selectedBrand = ''.obs;

  // Tambahkan map untuk menyimpan relasi nama kategori ke ID
  // final categoryNameToId = <String, String>{}.obs;

  // Add maps to store brand and category names
  // final brandIdToName = <String, String>{}.obs;
  // final categoryIdToName = <String, String>{}.obs;

  // Tambahkan variabel untuk menyimpan ID yang dipilih
  final selectedBrandId = ''.obs;
  final selectedCategoryId = ''.obs;

  // Gunakan RxList untuk menyimpan data brand dan category
  final brands = <BrandModel>[].obs;
  final categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    print('ProductController onInit called'); // Debugging
    fetchAllProducts();
    // Call fetch immediately and add a small delay to ensure data is loaded
  
    fetchCategoriesAndBrands();
 
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
  Stream<List<ProductModel>> getProductsByCategory(String? categoryId) {
    print('Querying products for category: $categoryId'); // Debug print
    
    if (categoryId == null) {
      print('CategoryId is null'); // Debug print
      return Stream.value([]);
    }

    return firestore
        .collection('Products')
        .where('categoryId', isEqualTo: categoryId) // Pastikan field name sesuai dengan yang ada di database
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} products'); // Debug print
          return snapshot.docs
              .map((doc) {
                print('Product data: ${doc.data()}'); // Debug print
                return ProductModel.fromSnapshot(doc);
              })
              .toList();
        });
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
      
      // Unformat numbers before saving
      if (data.containsKey('price')) {
        data['price'] = int.parse(unformatNumber(data['price'].toString()));
      }
      if (data.containsKey('salePrice') && data['salePrice'] != null) {
        data['salePrice'] = int.parse(unformatNumber(data['salePrice'].toString()));
      }

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
      if (!addProductFormKey.currentState!.validate()) return;

      loading.value = true;

      // Handle image upload or URL first
      String? imageUrl = await handleImageUpload();
      
      // Unformat numbers before saving
      final unformattedPrice = unformatNumber(price.text.trim());
      final unformattedDiscountPrice = discountPrice.text.isEmpty 
          ? null 
          : unformatNumber(discountPrice.text.trim());

      // Make sure brand and category are set
      if (selectedBrand.value.isEmpty || selectedCategory.value.isEmpty) {
        throw 'Please select both brand and category';
      }

      final product = ProductModel(
        id: '', 
        name: name.text.trim(),
        description: description.text.trim(),
        images: imageUrl != null ? [imageUrl] : [],
        price: int.parse(unformattedPrice),
        salePrice: unformattedDiscountPrice != null 
            ? int.parse(unformattedDiscountPrice) 
            : null,
        isSale: discountPrice.text.isNotEmpty,
        brandId: selectedBrand.value, // Langsung gunakan nama brand
        categoryId: selectedCategory.value, // Langsung gunakan nama category
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
    selectedBrandId.value = '';
    selectedCategoryId.value = '';
    selectedBrand.value = '';
    selectedCategory.value = '';
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
      final brandMatch = product.brandId.toLowerCase().contains(query.toLowerCase());
      final categoryMatch = product.categoryId.toLowerCase().contains(query.toLowerCase());
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
        return await uploadImage(result);
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

  Future<String?> uploadImage(FilePickerResult result) async {
    return await CloudinaryService.uploadFile(result);
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

  // Fetch categories and brands from Firestore
  Future<void> fetchCategoriesAndBrands() async {
    try {
      isBrandsLoading.value = true;
      isCategoriesLoading.value = true;
      
      print('Fetching categories and brands...');

      // Fetch categories
      final categoriesSnapshot = await firestore.collection('Categories').get();
      categories.clear();
      categoryNames.clear(); // Clear before adding
      for (var doc in categoriesSnapshot.docs) {
        categories.add(CategoryModel.fromSnapshot(doc));
        categoryNames.add(doc.data()['name'] as String);
      }
      
      // Fetch brands
      final brandsSnapshot = await firestore.collection('Brands').get();
      brands.clear();
      brandNames.clear(); // Clear before adding
      for (var doc in brandsSnapshot.docs) {
        brands.add(BrandModel.fromSnapshot(doc));
        brandNames.add(doc.data()['name'] as String);
      }

      print('Loaded: Categories: ${categoryNames.length}, Brands: ${brandNames.length}');

    } catch (e) {
      print('Error fetching categories and brands: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load categories and brands'
      );
    } finally {
      isBrandsLoading.value = false;
      isCategoriesLoading.value = false;
    }
  }


    Future<void> updateProductStock(String productId, int quantity, {bool isIncrement = true}) async {
    try {
      final docRef = firestore.collection('Products').doc(productId);
      
      await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw 'Product not found';
        }

        final currentStock = doc.data()?['stock'] ?? 0;
        final newStock = isIncrement ? currentStock + quantity : currentStock - quantity;
        
        if (newStock < 0) {
          throw 'Insufficient stock';
        }

        transaction.update(docRef, {'stock': newStock});
        debugPrint('Stock updated for product $productId. New stock: $newStock');
      });
    } catch (e) {
      debugPrint('Error updating product stock: $e');
      throw 'Failed to update product stock: $e';
    }
  }

  // Update selected values
  // void setSelectedCategory(String categoryName) {
  //   selectedCategory.value = categoryName;
  //   category.text = categoryName; // Set the category text controller value
  // }

  void setSelectedCategory(String? categoryName) {
    if (categoryName != null) {
      selectedCategory.value = categoryName;
      category.text = categoryName; // Update the category text controller
      debugPrint('Selected category: $categoryName');
    }
  }

  // void setSelectedBrand(String brandName) {
  //   selectedBrand.value = brandName;
  //   brand.text = brandName; // Set the brand text controller value
  // }
  void setSelectedBrand(String? brandName) {
    if (brandName != null) {
      selectedBrand.value = brandName;
      brand.text = brandName; // Update the brand text controller
      debugPrint('Selected brand: $brandName'); // Add debug log
    }
  }

  // Helper methods to get names from IDs
  String getBrandName(String brandId) {
    final brand = brands.firstWhereOrNull((b) => b.id == brandId);
    return brand?.name ?? 'Unknown Brand';
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Unknown Category';
  }

  // Add these utility methods for number formatting
  String formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll('.', ''));
    if (number == null) return '';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String unformatNumber(String value) {
    return value.replaceAll('.', '');
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
