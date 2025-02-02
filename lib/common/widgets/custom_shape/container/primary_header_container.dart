

import 'package:ecommerce_app/common/widgets/custom_shape/container/circular_container.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/curved_edge/curved_edge_widget.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgeWidget(
      child: Container(
        color: TColors.primary,
        padding: const EdgeInsets.all(0),
        // if [size.isInfinity : is not true. In Stack] error occurred -> Read README.md file
        child: Stack(
          children: [
            // Background circles custom shapes
            Positioned(top: -150, right: -300, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: -150, right: -240, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: -150, right: -180, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: 100, right: -250, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            // Positioned(top: 100, right: -250, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: 100, right: -315, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: 0, right: -205, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: 50, right: -145, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: 50, right: -185, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            Positioned(top: -50, right: -100, child: TCircularContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),)),
            child,
          ],
        ),
      ),
    );
  }
}