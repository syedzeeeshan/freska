import 'package:flutter/material.dart';
import 'freska_colors.dart';
import 'freska_typography.dart';
import 'freska_radius.dart';

/// Freska Master Theme Provider with Role Specializations
class FreskaTheme {
  FreskaTheme._();

  static ThemeData riderTheme() {
    return _buildTheme(
      primary: FreskaColors.riderAccent,
      secondary: FreskaColors.riderSecondary,
      surface: FreskaColors.bgSurface,
      scaffold: FreskaColors.bgDarkest,
    );
  }

  static ThemeData customerTheme() {
    return _buildTheme(
      primary: FreskaColors.customerAccent,
      secondary: FreskaColors.customerSecondary,
      surface: FreskaColors.bgSurface,
      scaffold: FreskaColors.bgDarkest,
    );
  }

  static ThemeData vendorTheme() {
    return _buildTheme(
      primary: FreskaColors.vendorAccent,
      secondary: FreskaColors.vendorSecondary,
      surface: FreskaColors.bgSurface,
      scaffold: FreskaColors.bgDarkest,
    );
  }

  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color scaffold,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: FreskaColors.statusError,
        onPrimary: FreskaColors.textInverse,
        onSecondary: Colors.white,
        onSurface: FreskaColors.textPrimary,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: FreskaRadius.lgBorder,
          side: BorderSide(color: FreskaColors.bgSubtle, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FreskaColors.bgDarkest,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: FreskaTypography.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: FreskaColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: FreskaRadius.mdBorder,
          ),
          textStyle: FreskaTypography.labelLarge,
        ),
      ),
    );
  }
}
