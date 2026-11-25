import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0B7A63);
  static const primaryDark = Color(0xFF065A49);
  static const primarySoft = Color(0xFFE4F3EE);
  static const background = Color(0xFFF5F8F7);
  static const ink = Color(0xFF14302A);
  static const muted = Color(0xFF6C807A);
  static const border = Color(0xFFE3EBE8);
  static const amber = Color(0xFFB26B00);
  static const amberSoft = Color(0xFFFFF3D9);
  static const danger = Color(0xFFD64545);
  static const dangerSoft = Color(0xFFFCE9E9);
}

class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x0F14302A), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const bar = [
    BoxShadow(color: Color(0x1214302A), blurRadius: 24, offset: Offset(0, -6)),
  ];
}

ThemeData buildLightTheme() {
  final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(primary: AppColors.primary, error: AppColors.danger);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primarySoft,
      elevation: 8,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
