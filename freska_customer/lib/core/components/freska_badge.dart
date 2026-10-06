import 'package:flutter/material.dart';
import '../theme/customer_theme.dart';

class FreskaBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? textColor;
  final bool isFilled;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const FreskaBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = FreskaCustomerColors.primary,
    this.textColor,
    this.isFilled = false,
    this.fontSize = 11,
    this.padding,
  });

  factory FreskaBadge.coldChain() {
    return const FreskaBadge(
      label: '4°C COLD CHAIN',
      icon: Icons.ac_unit,
      color: FreskaCustomerColors.coldChain,
      fontSize: 10,
    );
  }

  factory FreskaBadge.rating(String rating) {
    return FreskaBadge(
      label: rating,
      icon: Icons.star_rounded,
      color: FreskaCustomerColors.primary,
      isFilled: true,
      fontSize: 11,
    );
  }

  factory FreskaBadge.status(String text, {Color color = FreskaCustomerColors.primary}) {
    return FreskaBadge(
      label: text.toUpperCase(),
      color: color,
      fontSize: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? (isFilled ? Colors.black : color);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(FreskaRadius.pill),
        border: Border.all(
          color: isFilled ? Colors.transparent : color.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: effectiveTextColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: effectiveTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
