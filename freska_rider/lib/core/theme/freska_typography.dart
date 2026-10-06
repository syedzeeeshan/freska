import 'package:flutter/material.dart';
import 'freska_colors.dart';

/// Freska Design System — Typography
///
/// Clear, confident, outdoor-readable type hierarchy with strong numerical weights.
class FreskaTypography {
  FreskaTypography._();

  static const String fontFamily = 'Roboto';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: FreskaColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: FreskaColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    color: FreskaColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: FreskaColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: FreskaColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: FreskaColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: FreskaColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: FreskaColors.textMuted,
    height: 1.2,
  );

  static const TextStyle numberMetric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: FreskaColors.textPrimary,
  );
}
