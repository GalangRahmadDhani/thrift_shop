import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/controllers/user/update_name_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/user/update_username_controller.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:iconsax/iconsax.dart';

class ChangeUsername extends StatelessWidget {
  const ChangeUsername({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUsernameController());

    return Scaffold(
      // Custom appbar
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Ubah username', style: Theme.of(context).textTheme.headlineSmall,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Ubah Username anda dengan menggunakan username yang unik',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),

            // Text field any button
            Form(
              key: controller.updateUserUsernameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.usernameText,
                    validator: (value) => TValidator.validateEmptyText('Username', value),
                    expands: false,
                    decoration: const InputDecoration(labelText: TTexts.username, prefixIcon: Icon(Iconsax.user)),
                  ),
                  // const SizedBox(height: TSizes.spaceBtwInputFields,),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => controller.updateUserUserName(), child: const Text('Save')),
            )
          ],
        ),
      ),
    );
  }
}