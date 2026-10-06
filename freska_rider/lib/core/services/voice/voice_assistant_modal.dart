import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../voice_navigation_service.dart';
import 'voice_intent_engine.dart';
import '../../theme/freska_colors.dart';
import '../../theme/freska_typography.dart';
import '../../theme/freska_radius.dart';
import '../../theme/freska_spacing.dart';

class VoiceAssistantModal extends StatefulWidget {
  final FreskaVoiceRole role;
  final VoiceIntentEngine intentEngine;
  final VoiceNavigationService ttsService;
  final Function(String action)? onActionTriggered;

  const VoiceAssistantModal({
    super.key,
    required this.role,
    required this.intentEngine,
    required this.ttsService,
    this.onActionTriggered,
  });

  static Future<void> show(
    BuildContext context, {
    required FreskaVoiceRole role,
    required VoiceIntentEngine intentEngine,
    required VoiceNavigationService ttsService,
    Function(String action)? onActionTriggered,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceAssistantModal(
        role: role,
        intentEngine: intentEngine,
        ttsService: ttsService,
        onActionTriggered: onActionTriggered,
      ),
    );
  }

  @override
  State<VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends State<VoiceAssistantModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _inputController = TextEditingController();
  bool _isProcessing = false;
  String _statusMessage = 'Listening for Freska voice commands...';
  VoiceIntentResult? _lastResult;
  bool _waitingForConfirmation = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _speakWelcomePrompt();
  }

  void _speakWelcomePrompt() {
    String welcome;
    switch (widget.role) {
      case FreskaVoiceRole.customer:
        welcome = 'Freska Voice. Ask me to find food, check your cart, or track an order.';
        break;
      case FreskaVoiceRole.vendor:
        welcome = 'Freska Kitchen Voice. What orders would you like to review?';
        break;
      case FreskaVoiceRole.rider:
        welcome = 'Freska Rider Voice. You can say Go Online, Show Order, or Repeat Navigation.';
        break;
    }
    widget.ttsService.speak(welcome);
  }

  @override
  void dispose() {
    _animController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleCommandSubmit(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Understanding intent...';
    });

    final result = await widget.intentEngine.processCommand(
      query: query,
      role: widget.role,
    );

    setState(() {
      _isProcessing = false;
      _lastResult = result;
      _statusMessage = result.spokenResponse;
      if (result.requiresConfirmation) {
        _waitingForConfirmation = true;
      }
    });

    await widget.ttsService.speak(result.spokenResponse);

    if (!result.requiresConfirmation) {
      _executeAction(result);
    }
  }

  void _executeAction(VoiceIntentResult result) {
    if (result.targetAction != null && widget.onActionTriggered != null) {
      widget.onActionTriggered!(result.targetAction!);
    }

    if (result.targetRoute != null && mounted) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          Navigator.of(context).pop();
          context.push(result.targetRoute!);
        }
      });
    }
  }

  void _confirmAction(bool confirmed) {
    setState(() {
      _waitingForConfirmation = false;
    });

    if (confirmed && _lastResult != null) {
      widget.ttsService.speak('Action confirmed and executed.');
      _executeAction(_lastResult!);
    } else {
      widget.ttsService.speak('Action cancelled.');
      setState(() {
        _statusMessage = 'Action cancelled.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: FreskaColors.bgSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: FreskaColors.bgSubtle, width: 1.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FreskaColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: FreskaSpacing.lg),

            // Header title
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: widget.role == FreskaVoiceRole.vendor
                      ? FreskaColors.vendorAccent
                      : FreskaColors.brandPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Freska Voice AI (${widget.role.name.toUpperCase()})',
                  style: FreskaTypography.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: FreskaColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: FreskaSpacing.md),

            // Animated Waveform / Mic Orb
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = 1.0 + (_animController.value * 0.15);
                final glow = _animController.value * 16.0;
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.role == FreskaVoiceRole.vendor
                            ? FreskaColors.vendorAccent
                            : FreskaColors.brandPrimary)
                        .withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.role == FreskaVoiceRole.vendor
                                ? FreskaColors.vendorAccent
                                : FreskaColors.brandPrimary)
                            .withValues(alpha: 0.3),
                        blurRadius: glow,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.graphic_eq,
                      color: widget.role == FreskaVoiceRole.vendor
                          ? FreskaColors.vendorAccent
                          : FreskaColors.brandPrimary,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: FreskaSpacing.lg),

            // Status message
            Text(
              _statusMessage,
              style: FreskaTypography.bodyLarge.copyWith(
                color: FreskaColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FreskaSpacing.md),

            // Confirmation Bar (if high risk)
            if (_waitingForConfirmation && _lastResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FreskaColors.bgDarkest,
                  borderRadius: FreskaRadius.mdBorder,
                  border: Border.all(color: FreskaColors.statusWarning, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      _lastResult!.confirmationPrompt ?? 'Please confirm this action:',
                      style: FreskaTypography.bodyMedium.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _confirmAction(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FreskaColors.textSecondary,
                              side: const BorderSide(color: FreskaColors.bgSubtle),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmAction(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FreskaColors.brandPrimary,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Confirm (Yes)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FreskaSpacing.md),
            ],

            // Input / Suggestions Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: widget.role == FreskaVoiceRole.customer
                          ? 'Speak or type: "Find strawberries"...'
                          : widget.role == FreskaVoiceRole.vendor
                              ? 'Speak or type: "Show pending orders"...'
                              : 'Speak or type: "Go online"...',
                      hintStyle: const TextStyle(color: FreskaColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: FreskaColors.bgDarkest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: const OutlineInputBorder(
                        borderRadius: FreskaRadius.mdBorder,
                        borderSide: BorderSide(color: FreskaColors.bgSubtle),
                      ),
                    ),
                    onSubmitted: (val) {
                      _handleCommandSubmit(val);
                      _inputController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.arrow_upward, color: Colors.black),
                  style: IconButton.styleFrom(
                    backgroundColor: widget.role == FreskaVoiceRole.vendor
                        ? FreskaColors.vendorAccent
                        : FreskaColors.brandPrimary,
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () {
                          _handleCommandSubmit(_inputController.text);
                          _inputController.clear();
                        },
                ),
              ],
            ),
            const SizedBox(height: FreskaSpacing.md),

            // Quick suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _getSuggestionChips().map((chipText) {
                return ActionChip(
                  label: Text(chipText, style: const TextStyle(fontSize: 12, color: FreskaColors.textPrimary)),
                  backgroundColor: FreskaColors.bgElevated,
                  side: const BorderSide(color: FreskaColors.bgSubtle),
                  onPressed: () {
                    _inputController.text = chipText;
                    _handleCommandSubmit(chipText);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: FreskaSpacing.md),
          ],
        ),
      ),
    );
  }

  List<String> _getSuggestionChips() {
    switch (widget.role) {
      case FreskaVoiceRole.customer:
        return ['Find strawberries', 'Track my order', 'Open cart', 'Saved addresses'];
      case FreskaVoiceRole.vendor:
        return ['Show pending orders', "Today's sales", 'Mark order 10842 ready', 'Close store'];
      case FreskaVoiceRole.rider:
        return ['Go online', 'Show current order', 'Show earnings', 'Repeat instruction'];
    }
  }
}
