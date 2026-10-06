import 'package:flutter/material.dart';
import '../theme/vendor_theme.dart';

enum FreskaVendorBadgeVariant {
  primary,
  secondary,
  coldChain,
  status,
  warning,
  error,
  neutral,
}

class FreskaVendorBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final FreskaVendorBadgeVariant variant;
  final Color? customColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const FreskaVendorBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = FreskaVendorBadgeVariant.primary,
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
        case FreskaVendorBadgeVariant.primary:
          color = FreskaVendorColors.primary;
          break;
        case FreskaVendorBadgeVariant.secondary:
          color = FreskaVendorColors.secondary;
          break;
        case FreskaVendorBadgeVariant.coldChain:
          color = FreskaVendorColors.coldChain;
          break;
        case FreskaVendorBadgeVariant.status:
          color = FreskaVendorColors.statusPreparing;
          break;
        case FreskaVendorBadgeVariant.warning:
          color = FreskaVendorColors.statusWarning;
          break;
        case FreskaVendorBadgeVariant.error:
          color = FreskaVendorColors.statusError;
          break;
        case FreskaVendorBadgeVariant.neutral:
          color = FreskaVendorColors.textSecondary;
          break;
      }
    }

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(FreskaRadius.pill),
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
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
