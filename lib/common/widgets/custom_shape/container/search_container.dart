import 'package:ecommerce_app/features/shop/screens/search/search.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/device/device_utility.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TSearchContainer extends StatefulWidget {
  const TSearchContainer({
    super.key, 
    required this.text, 
    this.icon = Iconsax.search_normal, 
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<TSearchContainer> createState() => _TSearchContainerState();
}

class _TSearchContainerState extends State<TSearchContainer> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Padding(
      padding: widget.padding,
      child: Container(
        width: TDeviceUtils.getScreenWidth(context),
        height: 80,
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: widget.showBackground ? dark ? TColors.dark : TColors.light : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: widget.showBorder ? Border.all(color: TColors.grey) : null
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: TColors.darkerGrey),
            const SizedBox(width: TSizes.spaceBtwSections),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.text,
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Get.to(() => const SearchScreen());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}