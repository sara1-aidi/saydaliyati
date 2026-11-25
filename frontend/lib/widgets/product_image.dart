import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/product.dart';

/// Placeholder "packshot" drawn from the product category.
/// Swap for Image.network(product.imageUrl) once the API returns images.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.height,
    this.iconSize = 40,
    this.radius = 16,
    this.showBrand = false,
  });

  final Product product;
  final double? height;
  final double iconSize;
  final double radius;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final c = product.category;
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.tint,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: iconSize * 3,
              height: iconSize * 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.color.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: iconSize * 2.2,
              height: iconSize * 2.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.color.withValues(alpha: 0.06),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(iconSize * 0.36),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.soft,
            ),
            child: Icon(c.icon, size: iconSize, color: c.color),
          ),
          if (showBrand)
            Positioned(
              bottom: 44,
              child: Text(
                product.brand,
                style: TextStyle(
                  color: c.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
