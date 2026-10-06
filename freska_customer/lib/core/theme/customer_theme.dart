import 'package:flutter/material.dart';

/// FRESKA TACTILE SYSTEM — MASTER PALETTE & TOKENS
/// Neo-Skeuomorphic Tactile Design Language
class FreskaCustomerColors {
  FreskaCustomerColors._();

  // Foundation Surfaces
  static const Color obsidian = Color(0xFF111315); // Base Canvas / Background
  static const Color deepGraphite = Color(0xFF181B1F); // Level 1 / Secondary Canvas
  static const Color tactileSlate = Color(0xFF22272D); // Level 2 / Card Surface
  static const Color raisedSlate = Color(0xFF2A3036); // Level 3 / Raised Surface
  static const Color insetSlate = Color(0xFF0D0F11); // Level 0 / Inset Field Surface
  static const Color softHighlight = Color(0xFF3A4148); // Specular Top Highlight
  static const Color divider = Color(0xFF343A40); // 1px Subtle Border / Divider

  // Mappings to standard token aliases
  static const Color bgDarkest = obsidian;
  static const Color bgSurface = tactileSlate;
  static const Color bgElevated = raisedSlate;
  static const Color bgHighlight = softHighlight;
  static const Color bgSubtle = divider;
  static const Color bgInset = insetSlate;
  static const Color bgGlass = Color(0xEB111315);

  // Typography
  static const Color textPrimary = Color(0xFFF4F1EA); // High-contrast warm off-white
  static const Color textSecondary = Color(0xFFB8B7B2); // Supporting secondary text
  static const Color textMuted = Color(0xFF7F858A); // Captions and inactive labels

  // Primary Brand Accent (Warm Freska Orange)
  static const Color primary = Color(0xFFE87532); // Primary Action
  static const Color primaryLight = Color(0xFFF29A52); // Soft Amber Highlight
  static const Color primaryDark = Color(0xFFC95E27); // Pressed Depth
  static const Color primaryGlow = Color(0x33E87532);

  // Secondary Fresh Accent
  static const Color secondary = Color(0xFF4FAF7B); // Fresh Muted Green
  static const Color secondaryLight = Color(0xFF6DC497);
  static const Color secondaryDark = Color(0xFF3B8A60);
  static const Color secondaryGlow = Color(0x334FAF7B);

  // Semantic Colors
  static const Color statusSuccess = Color(0xFF4FAF7B); // Success / Ready / Available
  static const Color statusWarning = Color(0xFFD99A3D); // Alert / Pending
  static const Color statusError = Color(0xFFD85C5C); // Danger / Error / Cancel
  static const Color statusInfo = Color(0xFF5D93B8); // Information / Navigation
  static const Color coldChain = Color(0xFF66B8C9); // Cold-Chain 4°C
  static const Color coldChainGlow = Color(0x3366B8C9);
  static const Color accentBlue = Color(0xFF5D93B8);

  // Tactile Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF29A52), Color(0xFFE87532)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1AE87532), Color(0x05E87532)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coldChainGradient = LinearGradient(
    colors: [Color(0xFF66B8C9), Color(0xFF5D93B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF29A52), Color(0xFFE87532)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class FreskaRadius {
  FreskaRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));
}

class FreskaSpacing {
  FreskaSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
}

class FreskaShadows {
  FreskaShadows._();

  // Neo-Skeuomorphic Tactile Shadows: subtle top specular highlight, bottom ambient depth
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x59000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> tactileCard = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x3DE87532),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> coldGlow = [
    BoxShadow(
      color: Color(0x3366B8C9),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: -1,
    ),
  ];
}

class CustomerTheme {
  CustomerTheme._();

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FreskaCustomerColors.obsidian,
      primaryColor: FreskaCustomerColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: FreskaCustomerColors.primary,
        secondary: FreskaCustomerColors.secondary,
        surface: FreskaCustomerColors.tactileSlate,
        error: FreskaCustomerColors.statusError,
        onPrimary: Color(0xFF111315),
        onSecondary: Colors.white,
        onSurface: FreskaCustomerColors.textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: FreskaCustomerColors.tactileSlate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FreskaRadius.lg)),
          side: BorderSide(color: FreskaCustomerColors.divider, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FreskaCustomerColors.obsidian,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: FreskaCustomerColors.textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: FreskaCustomerColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FreskaCustomerColors.primary,
          foregroundColor: const Color(0xFF111315),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(FreskaRadius.md)),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
