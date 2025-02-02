import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TShadowStyle {
  // static final verticalProductShadow = BoxShadow(
  //   color: TColors.darkGrey.withOpacity(0.1),
  //   blurRadius: 50,
  //   spreadRadius: 7,
  //   offset: const Offset(0, 2)
  // );

  // static final horizontalProductShadow = BoxShadow(
  //   color: TColors.darkGrey.withOpacity(0.1),
  //   blurRadius: 50,
  //   spreadRadius: 7,
  //   offset: const Offset(0, 2)
  // );

  // Vertical product card shadow - More subtle and modern
  static final verticalProductShadow = BoxShadow(
    color: TColors.darkerGrey.withOpacity(0.08),
    blurRadius: 24,
    spreadRadius: 0,
    offset: const Offset(0, 3),
  );

  // Horizontal product card shadow - Wider spread for cards in horizontal layout
  static final horizontalProductShadow = BoxShadow(
    color: TColors.darkerGrey.withOpacity(0.07),
    blurRadius: 20,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );

  // Soft shadow for elevated cards
  static final softProductShadow = BoxShadow(
    color: TColors.darkGrey.withOpacity(0.05),
    blurRadius: 15,
    spreadRadius: 1,
    offset: const Offset(0, 2),
  );

  // Premium shadow - Multiple layers for more depth
  static final premiumProductShadow = [
    BoxShadow(
      color: TColors.darkGrey.withOpacity(0.03),
      blurRadius: 10,
      spreadRadius: 1,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: TColors.darkGrey.withOpacity(0.05),
      blurRadius: 25,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}