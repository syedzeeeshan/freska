import 'package:flutter/material.dart';
import '../theme/customer_theme.dart';

enum FreskaCardVariant { standard, elevated, subtle, inset }

class FreskaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final FreskaCardVariant variant;
  final BorderRadius? borderRadius;
  final Color? customColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Border? customBorder;
  final bool hasGlow;

  const FreskaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = FreskaCardVariant.standard,
    this.borderRadius,
    this.customColor,
    this.backgroundColor,
    this.borderColor,
    this.customBorder,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgTop;
    Color bgBottom;
    Border border;
    List<BoxShadow> shadows;

    switch (variant) {
      case FreskaCardVariant.standard:
        bgTop = const Color(0xFF262C32);
        bgBottom = FreskaCustomerColors.tactileSlate;
        border = Border(
          top: BorderSide(color: borderColor ?? const Color(0xFF3A4148), width: 1.0),
          bottom: const BorderSide(color: Color(0xFF181B1F), width: 1.5),
          left: const BorderSide(color: Color(0xFF2A3036), width: 1.0),
          right: const BorderSide(color: Color(0xFF2A3036), width: 1.0),
        );
        shadows = [
          if (hasGlow)
            const BoxShadow(
              color: Color(0x2EE87532),
              offset: Offset(0, 3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          const BoxShadow(
            color: Color(0x59000000),
            offset: Offset(0, 3),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ];
        break;
      case FreskaCardVariant.elevated:
        bgTop = const Color(0xFF2E353C);
        bgBottom = FreskaCustomerColors.raisedSlate;
        border = Border(
          top: BorderSide(color: borderColor ?? const Color(0xFF48515A), width: 1.0),
          bottom: const BorderSide(color: Color(0xFF181B1F), width: 1.5),
          left: const BorderSide(color: Color(0xFF343A40), width: 1.0),
          right: const BorderSide(color: Color(0xFF343A40), width: 1.0),
        );
        shadows = [
          if (hasGlow)
            const BoxShadow(
              color: Color(0x3DE87532),
              offset: Offset(0, 4),
              blurRadius: 14,
              spreadRadius: 0,
            ),
          const BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ];
        break;
      case FreskaCardVariant.subtle:
        bgTop = FreskaCustomerColors.deepGraphite;
        bgBottom = const Color(0xFF14171A);
        border = Border.all(color: borderColor ?? FreskaCustomerColors.divider, width: 0.8);
        shadows = const [];
        break;
      case FreskaCardVariant.inset:
        bgTop = FreskaCustomerColors.insetSlate;
        bgBottom = const Color(0xFF14171A);
        border = const Border(
          top: BorderSide(color: Color(0xFF000000), width: 1.5),
          bottom: BorderSide(color: Color(0xFF2A3036), width: 0.5),
          left: BorderSide(color: Color(0xFF181B1F), width: 1.0),
          right: BorderSide(color: Color(0xFF181B1F), width: 1.0),
        );
        shadows = const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ];
        break;
    }

    final radius = borderRadius ?? BorderRadius.circular(FreskaRadius.lg);
    final effectiveBg = backgroundColor ?? customColor;

    Widget content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(FreskaSpacing.lg),
      decoration: BoxDecoration(
        color: effectiveBg,
        gradient: effectiveBg == null
            ? LinearGradient(
                colors: [bgTop, bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        borderRadius: radius,
        border: customBorder ?? border,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: FreskaCustomerColors.primary.withValues(alpha: 0.1),
          highlightColor: FreskaCustomerColors.primary.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }
}
