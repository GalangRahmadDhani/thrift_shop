import 'package:ecommerce_app/data/repositories/authentication/user/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/address/address_repository.dart';
import '../../authentication/User/models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final addressRepository = Get.put(AddressRepository());
  RxList<AddressModel> addresses = <AddressModel>[].obs;
  
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();

  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserAddresses();
  }

  Future<void> loadUserAddresses() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        print('User not logged in'); // Debug print
        return;
      }

      print('Loading addresses for user: $userId'); // Debug print
      final userAddresses = await addressRepository.getUserAddresses(userId);
      
      addresses.assignAll(userAddresses);
      print('Loaded ${addresses.length} addresses'); // Debug print
      
      // Force refresh the list
      addresses.refresh();
    } catch (e) {
      print('Error in loadUserAddresses: $e'); // Debug print
      Get.snackbar('Error', 'Failed to load addresses: $e');
    }
  }

  Future<void> setActiveAddress(String addressId) async {
    try {
      // Update locally first
      for (var i = 0; i < addresses.length; i++) {
        final address = addresses[i];
        if (address.id == addressId) {
          addresses[i] = address.copyWith(isActive: true);
        } else {
          addresses[i] = address.copyWith(isActive: false);
        }
      }
      
      // Refresh the list
      addresses.refresh();
      
      // Then update in repository
      await Future.wait([
        for (var address in addresses)
          addressRepository.updateAddress(address.id, {'isActive': address.isActive})
      ]);
      
      Get.snackbar('Success', 'Address set as active');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update active address');
    }
  }

  Future<void> addAddress() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) throw 'User not logged in';

      final address = AddressModel(
        id: '',
        userId: userId, // Firestore will generate ID
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        postalCode: postalCode.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        isActive: false,
      );
      
      await addressRepository.addAddress(address);
      await loadUserAddresses(); // Reload addresses after adding
      Get.snackbar('Success', 'Address added successfully');
      clearForm();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateAddress(String id) async {
    try {
      final data = {
        'name': name.text.trim(),
        'phoneNumber': phoneNumber.text.trim(),
        'street': street.text.trim(),
        'postalCode': postalCode.text.trim(),
        'city': city.text.trim(),
        'state': state.text.trim(),
      };
      await addressRepository.updateAddress(id, data);
      Get.snackbar('Success', 'Address updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await addressRepository.deleteAddress(id);
      Get.snackbar('Success', 'Address deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void clearForm() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
  }
}
