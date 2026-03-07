import 'package:flutter/material.dart';

// ── Colour tokens ────────────────────────────────────────────────────────────
abstract final class AppColors {
  // Backgrounds
  static const Color primaryDark    = Color(0xFF0D1B2A); // deepest navy
  static const Color secondaryDark  = Color(0xFF152235); // card navy
  static const Color cardBackground = Color(0xFF1C2E42); // raised surface
  static const Color inputFill      = Color(0xFF1A2C3D);

  // Accent
  static const Color accent      = Color(0xFFFFA500); // amber/orange
  static const Color accentLight = Color(0xFFFFBE4F);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BECA);
  static const Color textMuted     = Color(0xFF607A8F);

  // Semantic
  static const Color success    = Color(0xFF4CAF50);
  static const Color error      = Color(0xFFEF5350);
  static const Color starColor  = Color(0xFFFFA500);
  static const Color divider    = Color(0xFF243447);
  static const Color chipActive = Color(0xFF1E3A52);
}

// ── Theme ────────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.secondaryDark,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.secondaryDark,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.secondaryDark,
          selectedColor: AppColors.accent,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
      );
}