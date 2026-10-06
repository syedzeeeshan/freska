import 'package:flutter/material.dart';

/// FRESKA TACTILE SYSTEM — VENDOR KITCHEN & OPERATIONAL PALETTE
/// Neo-Skeuomorphic Tactile Design Language
class FreskaVendorColors {
  FreskaVendorColors._();

  // Foundation Surfaces
  static const Color obsidian = Color(0xFF111315); // Base Kitchen Terminal Canvas
  static const Color deepGraphite = Color(0xFF181B1F); // Level 1 Canvas
  static const Color tactileSlate = Color(0xFF22272D); // Level 2 Card Surface
  static const Color raisedSlate = Color(0xFF2A3036); // Level 3 Raised Action Tile
  static const Color insetSlate = Color(0xFF0D0F11); // Level 0 Inset Field / Queue
  static const Color softHighlight = Color(0xFF3A4148); // Top Specular Highlight
  static const Color divider = Color(0xFF343A40); // 1px Subtle Border

  // Token Aliases
  static const Color bgDarkest = obsidian;
  static const Color bgSurface = tactileSlate;
  static const Color bgElevated = raisedSlate;
  static const Color bgHighlight = softHighlight;
  static const Color bgSubtle = divider;
  static const Color bgInset = insetSlate;
  static const Color bgGlass = Color(0xEB111315);

  // Typography
  static const Color textPrimary = Color(0xFFF4F1EA);
  static const Color textSecondary = Color(0xFFB8B7B2);
  static const Color textMuted = Color(0xFF7F858A);

  // Primary Brand Accent (Warm Freska Orange - Primary Kitchen Action)
  static const Color primary = Color(0xFFE87532);
  static const Color primaryLight = Color(0xFFF29A52);
  static const Color primaryDark = Color(0xFFC95E27);
  static const Color primaryGlow = Color(0x33E87532);

  // Secondary Fresh Accent (Fresh Green - Ready / In-Stock / Success)
  static const Color secondary = Color(0xFF4FAF7B);
  static const Color secondaryLight = Color(0xFF6DC497);
  static const Color secondaryDark = Color(0xFF3B8A60);
  static const Color secondaryGlow = Color(0x334FAF7B);

  // Status & Telemetry
  static const Color statusSuccess = Color(0xFF4FAF7B);
  static const Color statusWarning = Color(0xFFD99A3D);
  static const Color statusError = Color(0xFFD85C5C);
  static const Color statusPreparing = Color(0xFFE87532); // Preparing Order
  static const Color statusReady = Color(0xFF4FAF7B); // Ready for Driver Pickup
  static const Color statusInfo = Color(0xFF5D93B8);
  static const Color coldChain = Color(0xFF66B8C9);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF29A52), Color(0xFFE87532)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient amberGlowGradient = LinearGradient(
    colors: [Color(0x26E87532), Color(0x05E87532)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient readyGradient = LinearGradient(
    colors: [Color(0xFF6DC497), Color(0xFF4FAF7B)],
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

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x3DE87532),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> amberGlow = primaryGlow;
}

class VendorTheme {
  VendorTheme._();

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FreskaVendorColors.obsidian,
      primaryColor: FreskaVendorColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: FreskaVendorColors.primary,
        secondary: FreskaVendorColors.secondary,
        surface: FreskaVendorColors.tactileSlate,
        error: FreskaVendorColors.statusError,
        onPrimary: Color(0xFF111315),
        onSecondary: Colors.white,
        onSurface: FreskaVendorColors.textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: FreskaVendorColors.tactileSlate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FreskaRadius.lg)),
          side: BorderSide(color: FreskaVendorColors.divider, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FreskaVendorColors.obsidian,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: FreskaVendorColors.textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: FreskaVendorColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FreskaVendorColors.primary,
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
