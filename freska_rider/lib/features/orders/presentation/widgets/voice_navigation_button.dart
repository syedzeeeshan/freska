import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../cubit/voice_navigation_cubit.dart';

class VoiceNavigationButton extends StatefulWidget {
  final bool compact;

  const VoiceNavigationButton({
    super.key,
    this.compact = false,
  });

  @override
  State<VoiceNavigationButton> createState() => _VoiceNavigationButtonState();
}

class _VoiceNavigationButtonState extends State<VoiceNavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceNavigationCubit, VoiceNavigationState>(
      listener: (context, state) {
        if (state.isSpeaking) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      },
      builder: (context, state) {
        final isEnabled = state.isVoiceEnabled;
        final isSpeaking = state.isSpeaking;

        final Color backgroundColor = isEnabled
            ? (isSpeaking
                ? StitchColors.primary.withValues(alpha: 0.25)
                : StitchColors.primary.withValues(alpha: 0.15))
            : StitchColors.darkSurfaceElevated;

        final Color borderColor = isEnabled
            ? (isSpeaking ? StitchColors.primaryFresh : StitchColors.primary)
            : StitchColors.darkBorder;

        final Color iconColor = isEnabled
            ? (isSpeaking ? StitchColors.primaryFresh : StitchColors.primary)
            : StitchColors.textSecondary;

        final IconData icon = !isEnabled
            ? Icons.volume_off_rounded
            : (isSpeaking
                ? Icons.record_voice_over_rounded
                : Icons.volume_up_rounded);

        final String label = !isEnabled
            ? 'Voice Off'
            : (isSpeaking ? 'Speaking...' : 'Voice Nav');

        final buttonChild = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<VoiceNavigationCubit>().toggleVoice();
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 12 : 16,
                vertical: widget.compact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: borderColor, width: isSpeaking ? 1.8 : 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  if (!widget.compact) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: StitchTypography.labelMedium.copyWith(
                        color: isEnabled
                            ? Colors.white
                            : StitchColors.textSecondary,
                        fontWeight:
                            isSpeaking ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );

        if (isSpeaking) {
          return ScaleTransition(
            scale: _pulseAnimation,
            child: buttonChild,
          );
        }

        return buttonChild;
      },
    );
  }
}
