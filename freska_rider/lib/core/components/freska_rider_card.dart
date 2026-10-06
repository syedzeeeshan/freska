import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';

enum FreskaRiderCardVariant { standard, elevated, subtle, inset }

class FreskaRiderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final FreskaRiderCardVariant variant;
  final BorderRadius? borderRadius;
  final Color? customColor;
  final Border? customBorder;

  const FreskaRiderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = FreskaRiderCardVariant.standard,
    this.borderRadius,
    this.customColor,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    Color bgTop;
    Color bgBottom;
    Border border;
    List<BoxShadow> shadows;

    switch (variant) {
      case FreskaRiderCardVariant.standard:
        bgTop = const Color(0xFF262C32);
        bgBottom = StitchColors.tactileSlate;
        border = const Border(
          top: BorderSide(color: Color(0xFF3A4148), width: 1.0),
          bottom: BorderSide(color: Color(0xFF181B1F), width: 1.5),
          left: BorderSide(color: Color(0xFF2A3036), width: 1.0),
          right: BorderSide(color: Color(0xFF2A3036), width: 1.0),
        );
        shadows = const [
          BoxShadow(
            color: Color(0x59000000),
            offset: Offset(0, 3),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ];
        break;
      case FreskaRiderCardVariant.elevated:
        bgTop = const Color(0xFF2E353C);
        bgBottom = StitchColors.raisedSlate;
        border = const Border(
          top: BorderSide(color: Color(0xFF48515A), width: 1.0),
          bottom: BorderSide(color: Color(0xFF181B1F), width: 1.5),
          left: BorderSide(color: Color(0xFF343A40), width: 1.0),
          right: BorderSide(color: Color(0xFF343A40), width: 1.0),
        );
        shadows = const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ];
        break;
      case FreskaRiderCardVariant.subtle:
        bgTop = StitchColors.deepGraphite;
        bgBottom = const Color(0xFF14171A);
        border = Border.all(color: StitchColors.surfaceBorder, width: 0.8);
        shadows = const [];
        break;
      case FreskaRiderCardVariant.inset:
        bgTop = StitchColors.insetSlate;
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

    final radius = borderRadius ?? BorderRadius.circular(16);

    Widget content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColor,
        gradient: customColor == null
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
          splashColor: StitchColors.primary.withValues(alpha: 0.1),
          highlightColor: StitchColors.primary.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }
}
