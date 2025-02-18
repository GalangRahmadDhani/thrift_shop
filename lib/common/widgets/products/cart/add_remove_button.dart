import 'package:ecommerce_app/common/widgets/icons/circular_icon.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TProductWithQuantityAddRemoveButton extends StatelessWidget {
  const TProductWithQuantityAddRemoveButton({
    super.key,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(
            Iconsax.minus_cirlce,
            color: TColors.darkGrey,
          ),
        ),
        Text(
          quantity.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(
            Iconsax.add_circle,
            color: TColors.darkGrey,
          ),
        ),
      ],
    );
  }
}