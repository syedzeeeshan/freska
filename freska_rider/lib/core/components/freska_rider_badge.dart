import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';

enum FreskaRiderBadgeVariant { primary, fresh, warning, danger, info, neutral }

class FreskaRiderBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final FreskaRiderBadgeVariant variant;
  final Color? customColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const FreskaRiderBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = FreskaRiderBadgeVariant.primary,
    this.customColor,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    if (customColor != null) {
      color = customColor!;
    } else {
      switch (variant) {
        case FreskaRiderBadgeVariant.primary:
          color = StitchColors.primary;
          break;
        case FreskaRiderBadgeVariant.fresh:
          color = StitchColors.primaryFresh;
          break;
        case FreskaRiderBadgeVariant.warning:
          color = StitchColors.warning;
          break;
        case FreskaRiderBadgeVariant.danger:
          color = StitchColors.danger;
          break;
        case FreskaRiderBadgeVariant.info:
          color = StitchColors.infoBlue;
          break;
        case FreskaRiderBadgeVariant.neutral:
          color = StitchColors.textSecondary;
          break;
      }
    }

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
