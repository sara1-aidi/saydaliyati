import 'package:flutter/material.dart';
import '../core/app_theme.dart';

InputDecoration appInputDecoration(
  String label, {
  IconData? icon,
  Widget? suffix,
  String? hint,
  String? suffixText,
}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    prefixIcon: icon == null ? null : Icon(icon, size: 20, color: AppColors.muted),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: AppColors.muted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary, 1.6),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.6),
  );
}

/// Red banner used for server errors (wrong password, server down...).
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.danger, fontSize: 13.5, height: 1.4)),
            ),
          ],
        ),
      );
}

/// Logo + app name, used on the login and register pages.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(size * 0.3),
              boxShadow: AppShadows.soft,
            ),
            child: Icon(Icons.local_pharmacy_rounded,
                color: Colors.white, size: size * 0.55),
          ),
          const SizedBox(height: 12),
          const Text('Saydaliyati',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.5,
              )),
        ],
      );
}
