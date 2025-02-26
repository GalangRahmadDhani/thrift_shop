import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/data/repositories/address/address_repository.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../../features/shop/controllers/address_controller.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddressRepository());
    final controller = Get.put(AddressController());
    final addNewAddressformKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Tambah Alamat Baru'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: addNewAddressformKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controller.name,
                  validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Nama'
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                
                TextFormField(
                  controller: controller.phoneNumber,
                  validator: (value) => value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'No. Telepon'
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.street,
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Jalan tidak boleh kosong' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building_31),
                          labelText: 'Jalan'
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.postalCode,
                        keyboardType: TextInputType.number, // Set keyboard to numeric
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(5), // Limit to 5 digits for postal code
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kode pos tidak boleh kosong';
                          }
                          if (value.length < 5) {
                            return 'Kode pos harus 5 digit';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Kode pos',
                          // hintText: '12345',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.city,
                        validator: (value) => value!.isEmpty ? 'Kota tidak boleh kosong' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'Kota'
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.state,
                        validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'Alamat'
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.defaultSpace),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (addNewAddressformKey.currentState!.validate()) {
                        controller.addAddress();
                      }
                      Get.back();
                    },
                    child: const Text('Simpan Alamat'),
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}