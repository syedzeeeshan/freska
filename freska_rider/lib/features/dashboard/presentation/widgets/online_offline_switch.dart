import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';

class OnlineOfflineSwitch extends StatelessWidget {
  final bool isOnline;
  final bool isToggling;
  final ValueChanged<bool> onToggle;

  const OnlineOfflineSwitch({
    super.key,
    required this.isOnline,
    required this.isToggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isToggling
          ? null
          : () {
              HapticFeedback.selectionClick();
              onToggle(!isOnline);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isOnline
              ? StitchColors.primary.withValues(alpha: 0.2)
              : StitchColors.surfaceElevated,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isOnline ? StitchColors.primary : StitchColors.surfaceBorder,
            width: 1.5,
          ),
          boxShadow: isOnline
              ? [
                  BoxShadow(
                    color: StitchColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isToggling) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: StitchColors.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? StitchColors.primaryLight
                      : StitchColors.textMuted,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: StitchColors.primaryLight.withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              isOnline ? 'ON DUTY' : 'OFF DUTY',
              style: StitchTypography.buttonText.copyWith(
                color: isOnline
                    ? StitchColors.primaryLight
                    : StitchColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
