import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';

enum FreskaRiderButtonVariant { primary, secondary, fresh, danger, outline }

class FreskaRiderButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final FreskaRiderButtonVariant variant;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const FreskaRiderButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = FreskaRiderButtonVariant.primary,
    this.height = 48,
    this.width,
    this.padding,
  });

  @override
  State<FreskaRiderButton> createState() => _FreskaRiderButtonState();
}

class _FreskaRiderButtonState extends State<FreskaRiderButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgTop;
    Color bgBottom;
    Color fg;
    Color borderTop;
    Color borderBottom;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case FreskaRiderButtonVariant.primary:
        bgTop = const Color(0xFFF29A52);
        bgBottom = const Color(0xFFE87532);
        fg = const Color(0xFF111315);
        borderTop = const Color(0xFFFFAE6B);
        borderBottom = const Color(0xFFC95E27);
        shadows = const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Color(0x33E87532),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ];
        break;
      case FreskaRiderButtonVariant.fresh:
        bgTop = const Color(0xFF5EBF8B);
        bgBottom = const Color(0xFF4FAF7B);
        fg = const Color(0xFF111315);
        borderTop = const Color(0xFF75D4A2);
        borderBottom = const Color(0xFF3B8A60);
        shadows = const [
          BoxShadow(
            color: Color(0x334FAF7B),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ];
        break;
      case FreskaRiderButtonVariant.secondary:
        bgTop = const Color(0xFF2A3036);
        bgBottom = const Color(0xFF22272D);
        fg = StitchColors.textPrimary;
        borderTop = const Color(0xFF3A4148);
        borderBottom = const Color(0xFF181B1F);
        shadows = const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ];
        break;
      case FreskaRiderButtonVariant.outline:
        bgTop = Colors.transparent;
        bgBottom = Colors.transparent;
        fg = StitchColors.textPrimary;
        borderTop = StitchColors.surfaceBorder;
        borderBottom = StitchColors.surfaceBorder;
        break;
      case FreskaRiderButtonVariant.danger:
        bgTop = const Color(0xFFE56A6A);
        bgBottom = const Color(0xFFD85C5C);
        fg = Colors.white;
        borderTop = const Color(0xFFFF8585);
        borderBottom = const Color(0xFFB54545);
        shadows = const [
          BoxShadow(
            color: Color(0x40D85C5C),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ];
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: (_isPressed && isEnabled) ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: _isPressed
                ? LinearGradient(
                    colors: [bgBottom, bgTop],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [bgTop, bgBottom],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(
                color: _isPressed ? borderBottom : borderTop,
                width: 1.0,
              ),
              bottom: BorderSide(
                color: _isPressed ? borderTop : borderBottom,
                width: 1.5,
              ),
              left: BorderSide(
                color: borderTop.withValues(alpha: 0.5),
                width: 1.0,
              ),
              right: BorderSide(
                color: borderTop.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            boxShadow: (_isPressed || !isEnabled) ? null : shadows,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: isEnabled ? fg : fg.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
