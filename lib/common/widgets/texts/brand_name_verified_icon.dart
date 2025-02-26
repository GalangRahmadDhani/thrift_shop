import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class TBrandNameWithVerifiedIcon extends StatelessWidget {
  const TBrandNameWithVerifiedIcon({
    super.key,
    required this.brandName,
    this.maxLines = 1,
    this.textColor,
    this.iconColor = TColors.primary,
    this.textAlign = TextAlign.center,
    this.brandTextAlignment = TextAlign.center,
    this.showVerifiedIcon = false,
  });

  final String brandName;
  final int maxLines;
  final Color? textColor;
  final Color iconColor;
  final TextAlign textAlign;
  final TextAlign brandTextAlignment;
  final bool showVerifiedIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            brandName,
            textAlign: brandTextAlignment,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
          ),
        ),
        if (showVerifiedIcon) const SizedBox(width: TSizes.xs),
        if (showVerifiedIcon)
          Icon(
            Iconsax.verify5,
            color: iconColor,
            size: TSizes.iconXs,
          ),
      ],
    );
  }
}

