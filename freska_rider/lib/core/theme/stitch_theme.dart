import 'package:flutter/material.dart';
import 'stitch_colors.dart';
import 'stitch_typography.dart';

class StitchTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StitchColors.obsidian,
      colorScheme: const ColorScheme.dark(
        primary: StitchColors.primary,
        secondary: StitchColors.primaryFresh,
        surface: StitchColors.tactileSlate,
        error: StitchColors.danger,
        onPrimary: Color(0xFF111315),
        onSurface: StitchColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: StitchColors.tactileSlate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StitchColors.surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StitchColors.obsidian,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: StitchTypography.heading2,
        iconTheme: IconThemeData(color: StitchColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StitchColors.primary,
          foregroundColor: const Color(0xFF111315),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: StitchTypography.button.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111315),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StitchColors.insetSlate,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: StitchTypography.caption.copyWith(
          fontSize: 14,
          color: StitchColors.textMuted,
        ),
        labelStyle: StitchTypography.body,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.surfaceBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.surfaceBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.danger, width: 1),
        ),
      ),
    );
  }
}
