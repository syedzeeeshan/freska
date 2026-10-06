import 'package:flutter/material.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';

class StitchPrimaryButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  const StitchPrimaryButton({
    super.key,
    this.text,
    this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  String get _buttonText => label ?? text ?? '';

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? StitchColors.primary,
        disabledBackgroundColor: StitchColors.surfaceElevated,
      ),
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  _buttonText,
                  style: StitchTypography.button.copyWith(color: Colors.white),
                ),
              ],
            ),
    );
  }
}
