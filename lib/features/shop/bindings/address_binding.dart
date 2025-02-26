import 'package:get/get.dart';
import '../../../data/repositories/address/address_repository.dart';
import '../controllers/address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddressRepository());
    Get.lazyPut(() => AddressController());
  }
}
