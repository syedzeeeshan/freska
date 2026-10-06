import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/stitch_colors.dart';

class HoldToTriggerSosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final Duration holdDuration;

  const HoldToTriggerSosButton({
    super.key,
    required this.onTriggered,
    this.holdDuration = const Duration(seconds: 3),
  });

  @override
  State<HoldToTriggerSosButton> createState() => _HoldToTriggerSosButtonState();
}

class _HoldToTriggerSosButtonState extends State<HoldToTriggerSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.holdDuration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onTriggered();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.mediumImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          return Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  StitchColors.dangerSOS.withValues(alpha: 0.15 + (0.35 * progress)),
              border: Border.all(
                color: StitchColors.dangerSOS,
                width: 3 + (4 * progress),
              ),
              boxShadow: [
                BoxShadow(
                  color: StitchColors.dangerSOS.withValues(alpha: 0.3 * progress),
                  blurRadius: 20 * progress,
                  spreadRadius: 5 * progress,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: StitchColors.dangerSOS,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text(
                  'HOLD FOR SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress > 0
                      ? '${((1.0 - progress) * widget.holdDuration.inSeconds).toStringAsFixed(1)}s'
                      : 'Hold 3 Seconds',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
