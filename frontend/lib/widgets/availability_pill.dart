import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/product.dart';

class AvailabilityPill extends StatelessWidget {
  const AvailabilityPill({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (!product.inStock) {
      color = AppColors.danger;
      label = 'Out of stock';
    } else if (product.lowStock) {
      color = AppColors.amber;
      label = 'Only ${product.quantity} left';
    } else {
      color = AppColors.primary;
      label = 'In stock';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
