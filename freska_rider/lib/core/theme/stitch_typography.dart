import 'package:flutter/material.dart';
import 'stitch_colors.dart';

class StitchTypography {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: StitchColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: StitchColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: StitchColors.textPrimary,
  );

  static const TextStyle headingLarge = heading1;
  static const TextStyle headingMedium = heading2;
  static const TextStyle headingSmall = heading3;

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: StitchColors.textPrimary,
    letterSpacing: -1.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: StitchColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: StitchColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: StitchColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: StitchColors.textPrimary,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: StitchColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: StitchColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = body;

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StitchColors.textMuted,
  );

  static const TextStyle bodyEmphasis = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: StitchColors.textPrimary,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: StitchColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: StitchColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: StitchColors.textMuted,
  );

  // Captions & Buttons
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StitchColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonText = button;

  // Monospace
  static const TextStyle monoMedium = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: StitchColors.textPrimary,
  );

  static const TextStyle monoSmall = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: StitchColors.textSecondary,
  );

  // Tabular Numbers for financial values and timers to prevent jitter
  static TextStyle tabular({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
    Color color = StitchColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
