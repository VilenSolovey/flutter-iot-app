import 'package:flutter/material.dart';

abstract final class AppColors {
  static const bg = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1C1C1C);
  static const card = Color(0xFF272727);
  static const accent = Color(0xFFD4FF57);
  static const primary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF8A8A8A);
  static const border = Color(0xFF2E2E2E);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppText {
  static const h1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.3,
  );

  static const body = TextStyle(
    fontSize: 15,
    color: AppColors.primary,
    height: 1.5,
  );

  static const muted = TextStyle(fontSize: 13, color: AppColors.secondary);

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
    letterSpacing: 1.5,
  );
}

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
  );
}
