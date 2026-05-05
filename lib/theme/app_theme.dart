import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen  = Color(0xFF6AAE35);
  static const Color darkGreen     = Color(0xFF4E8A22);
  static const Color lightGreenBg  = Color(0xFFF0F4E8);
  static const Color cardWhite     = Color(0xFFFFFFFF);
  static const Color textDark      = Color(0xFF1A1A1A);
  static const Color textMedium    = Color(0xFF555555);
  static const Color textLight     = Color(0xFF888888);
  static const Color yellowFab     = Color(0xFFF5C518);
  static const Color redLogout     = Color(0xFFE53935);
  static const Color blueIcon      = Color(0xFF29B6F6);
  static const Color orangeIcon    = Color(0xFFFF9800);
  static const Color redIcon       = Color(0xFFEF5350);
  static const Color brownIcon     = Color(0xFF795548);
  static const Color divider       = Color(0xFFE0E0E0);
  static const Color inputBorder   = Color(0xFFDDE5D0);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: AppColors.lightGreenBg,
        ),
        scaffoldBackgroundColor: AppColors.lightGreenBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: AppColors.divider, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}
