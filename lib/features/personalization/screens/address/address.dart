import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../shop/controllers/address_controller.dart';
import 'add_new_address.dart';
import 'widgets/single_address.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Alamat'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        child: const Icon(Iconsax.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(
          () => controller.addresses.isEmpty
              ? const Center(child: Text('Tidak ada alamat tersimpan'))
              : ListView.builder(
                  itemCount: controller.addresses.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    final address = controller.addresses[index];
                    return GestureDetector(
                      onTap: () => controller.setActiveAddress(address.id),
                      child: TSingleAddress(
                        address: address,
                        selectedAddress: address.isActive,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}