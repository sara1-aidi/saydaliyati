import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../models/product.dart';
import '../providers/ui_providers.dart';

void showAddedToCart(BuildContext context, WidgetRef ref, Product product) {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF7FE0C3), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.name} added to cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View cart',
          textColor: const Color(0xFF7FE0C3),
          onPressed: () {
            navigator.popUntil((route) => route.isFirst);
            ref.read(clientTabProvider.notifier).state = 1;
          },
        ),
      ),
    );
}
