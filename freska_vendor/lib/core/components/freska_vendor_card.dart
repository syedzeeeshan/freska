import 'package:flutter/material.dart';
import '../theme/vendor_theme.dart';

enum FreskaVendorCardVariant { standard, elevated, subtle, inset }

class FreskaVendorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final FreskaVendorCardVariant variant;
  final BorderRadius? borderRadius;
  final Color? customColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final dynamic border;
  final Border? customBorder;
  final bool hasGlow;
  final Color? glowColor;

  const FreskaVendorCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = FreskaVendorCardVariant.standard,
    this.borderRadius,
    this.customColor,
    this.backgroundColor,
    this.borderColor,
    this.border,
    this.customBorder,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bgTop;
    Color bgBottom;
    Border defaultBorder;
    List<BoxShadow> shadows;

    switch (variant) {
      case FreskaVendorCardVariant.standard:
        bgTop = const Color(0xFF262C32);
        bgBottom = FreskaVendorColors.tactileSlate;
        defaultBorder = Border(
          top: BorderSide(color: borderColor ?? const Color(0xFF3A4148), width: 1.0),
          bottom: const BorderSide(color: Color(0xFF181B1F), width: 1.5),
          left: const BorderSide(color: Color(0xFF2A3036), width: 1.0),
          right: const BorderSide(color: Color(0xFF2A3036), width: 1.0),
        );
        shadows = [
          if (hasGlow || glowColor != null)
            BoxShadow(
              color: (glowColor ?? FreskaVendorColors.primary).withValues(alpha: 0.18),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          const BoxShadow(
            color: Color(0x59000000),
            offset: Offset(0, 3),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ];
        break;
      case FreskaVendorCardVariant.elevated:
        bgTop = const Color(0xFF2E353C);
        bgBottom = FreskaVendorColors.raisedSlate;
        defaultBorder = Border(
          top: BorderSide(color: borderColor ?? const Color(0xFF48515A), width: 1.0),
          bottom: const BorderSide(color: Color(0xFF181B1F), width: 1.5),
          left: const BorderSide(color: Color(0xFF343A40), width: 1.0),
          right: const BorderSide(color: Color(0xFF343A40), width: 1.0),
        );
        shadows = [
          if (hasGlow || glowColor != null)
            BoxShadow(
              color: (glowColor ?? FreskaVendorColors.primary).withValues(alpha: 0.24),
              offset: const Offset(0, 4),
              blurRadius: 14,
            ),
          const BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ];
        break;
      case FreskaVendorCardVariant.subtle:
        bgTop = FreskaVendorColors.deepGraphite;
        bgBottom = const Color(0xFF14171A);
        defaultBorder = Border.all(color: borderColor ?? FreskaVendorColors.divider, width: 0.8);
        shadows = const [];
        break;
      case FreskaVendorCardVariant.inset:
        bgTop = FreskaVendorColors.insetSlate;
        bgBottom = const Color(0xFF14171A);
        defaultBorder = const Border(
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

    Border? effectiveBorder;
    if (border is BorderSide) {
      effectiveBorder = Border.fromBorderSide(border as BorderSide);
    } else if (border is Border) {
      effectiveBorder = border as Border;
    } else {
      effectiveBorder = customBorder ?? defaultBorder;
    }

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
        border: effectiveBorder,
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
          splashColor: FreskaVendorColors.primary.withValues(alpha: 0.1),
          highlightColor: FreskaVendorColors.primary.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }
}
