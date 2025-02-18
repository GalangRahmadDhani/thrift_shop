import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    super.key, 
    this.width,
    this.height, 
    required this.imageUrl, 
    this.applyImageRadius = true, 
    this.border,  
    this.backgroundColor, 
    this.fit = BoxFit.contain, 
    this.padding, 
    this.isNetworkImage = false, 
    this.onPressed, 
    this.borderRadius = TSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
          child: isNetworkImage 
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: fit,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
              )
            : Image(
                image: AssetImage(imageUrl),
                fit: fit,
              ),
        ),
      ),
    );
  }
}