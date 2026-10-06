import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';

class SwipeActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onSwipeComplete;
  final bool isLoading;
  final bool enabled;
  final Color activeColor;
  final IconData thumbIcon;

  const SwipeActionButton({
    super.key,
    required this.label,
    required this.onSwipeComplete,
    this.isLoading = false,
    this.enabled = true,
    this.activeColor = StitchColors.primary,
    this.thumbIcon = Icons.arrow_forward_rounded,
  });

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  static const double _buttonHeight = 56.0;
  static const double _thumbPadding = 4.0;
  static const double _thumbSize = _buttonHeight - (_thumbPadding * 2);

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _dragPosition = _resetAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!widget.enabled || widget.isLoading) return;

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxDrag) {
    if (!widget.enabled || widget.isLoading) return;

    if (_dragPosition >= maxDrag * 0.85) {
      // Completed swipe
      HapticFeedback.heavyImpact();
      widget.onSwipeComplete();
      _resetToStart();
    } else {
      // Rebound back to start
      _resetToStart();
    }
  }

  void _resetToStart() {
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
    );
    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - _buttonHeight;
        final progress =
            maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: _buttonHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: StitchColors.surfaceElevated,
            borderRadius: BorderRadius.circular(_buttonHeight / 2),
            border: Border.all(
              color: StitchColors.surfaceBorder,
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Dynamic Fill Track
              FractionallySizedBox(
                widthFactor:
                    widget.isLoading ? 1.0 : (progress > 0.05 ? progress : 0.0),
                child: Container(
                  height: _buttonHeight,
                  decoration: BoxDecoration(
                    color: widget.activeColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(_buttonHeight / 2),
                  ),
                ),
              ),

              // Centered Prompt Label
              Center(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: StitchColors.primaryLight,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: StitchTypography.buttonText.copyWith(
                              color: widget.enabled
                                  ? StitchColors.textPrimary
                                  : StitchColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            color: widget.enabled
                                ? StitchColors.textSecondary.withValues(alpha: 0.6)
                                : StitchColors.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
              ),

              // Draggable Slider Thumb
              if (!widget.isLoading)
                Positioned(
                  left: _thumbPadding + _dragPosition,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) =>
                        _onHorizontalDragUpdate(details, maxDrag),
                    onHorizontalDragEnd: (details) =>
                        _onHorizontalDragEnd(details, maxDrag),
                    child: Container(
                      height: _thumbSize,
                      width: _thumbSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.enabled
                                ? widget.activeColor
                                : StitchColors.surface,
                            widget.enabled
                                ? widget.activeColor.withValues(alpha: 0.85)
                                : StitchColors.surfaceElevated,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.enabled
                                ? widget.activeColor.withValues(alpha: 0.4)
                                : Colors.transparent,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.thumbIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
