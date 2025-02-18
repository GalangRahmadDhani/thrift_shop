import 'package:ecommerce_app/common/widgets/layouts/grid_layout.dart';
import 'package:ecommerce_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ecommerce_app/features/shop/controllers/product_controller.dart';
import 'package:ecommerce_app/features/authentication/User/models/product_model.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Column(
      children: [
        // Dropdown
        DropdownButtonFormField(
          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
          onChanged: (value){},
          items: [
            'Nama',
            'Harga Tertinggi',
            'Harga Terendah',
            'Penjualan',
            'Terbaru',
            'Populer',
          ].map((option) => DropdownMenuItem(
            value: option, child: Text(option)
          )).toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwItems,),
    
        // Products
        Obx((){
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.products.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return TGridLayout(
            itemCount: controller.products.length,
            itemBuilder: (_, index) => TProductCardVertical(
              product: controller.products[index],
            ),
          );
        }),
      ],
    );
  }
}