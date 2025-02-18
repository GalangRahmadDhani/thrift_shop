import 'package:get/get.dart';
import 'package:ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Repository
    Get.lazyPut(() => ProductRepository());
    
    // Initialize Controller
    Get.lazyPut(() => ProductController());
  }
}
