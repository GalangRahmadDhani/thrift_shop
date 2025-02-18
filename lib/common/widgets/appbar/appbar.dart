import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/device/device_utility.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.backgroundColor,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? Padding(
            padding: const EdgeInsets.only(left: TSizes.md),
            child: IconButton(
                onPressed: () => Get.back(), icon: Icon(Iconsax.arrow_left, color: dark ? TColors.white : TColors.dark,)),
          )
          : leadingIcon != null
              ? Padding(
                padding: const EdgeInsets.only(left: TSizes.md),
                child: IconButton(
                    onPressed: leadingOnPressed, icon: Icon(leadingIcon, color: dark ? TColors.white : TColors.dark,),),
              )
              : null,
      title: title,
      actions: actions,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
