import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import 'vendor_voice_intent_engine.dart';
import 'vendor_voice_service.dart';

class VendorVoiceModal extends StatefulWidget {
  final VendorVoiceIntentEngine intentEngine;
  final VendorVoiceService voiceService;
  final VoidCallback? onDutyToggle;

  const VendorVoiceModal({
    super.key,
    required this.intentEngine,
    required this.voiceService,
    this.onDutyToggle,
  });

  static void show(
    BuildContext context, {
    required VendorVoiceIntentEngine intentEngine,
    required VendorVoiceService voiceService,
    VoidCallback? onDutyToggle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VendorVoiceModal(
        intentEngine: intentEngine,
        voiceService: voiceService,
        onDutyToggle: onDutyToggle,
      ),
    );
  }

  @override
  State<VendorVoiceModal> createState() => _VendorVoiceModalState();
}

class _VendorVoiceModalState extends State<VendorVoiceModal> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _textController = TextEditingController();
  String _statusMessage = 'Listening for kitchen & dispatch commands...';
  String _recognizedText = '';
  bool _isProcessing = false;
  VendorVoiceIntentResult? _pendingConfirmationResult;

  final List<String> _quickCommands = [
    'Show pending orders',
    'Check today\'s sales',
    'Open store menu',
    'Mark order 89421 ready',
    'Close store',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleCommand(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    setState(() {
      _recognizedText = query;
      _isProcessing = true;
      _statusMessage = 'Processing command...';
      _pendingConfirmationResult = null;
    });

    final result = await widget.intentEngine.processCommand(query);

    if (!mounted) return;

    if (result.requiresConfirmation && result.confirmationPrompt != null) {
      setState(() {
        _isProcessing = false;
        _pendingConfirmationResult = result;
        _statusMessage = result.confirmationPrompt!;
      });
      await widget.voiceService.speak(result.confirmationPrompt!);
      return;
    }

    _executeResult(result);
  }

  Future<void> _executeResult(VendorVoiceIntentResult result) async {
    setState(() {
      _isProcessing = false;
      _statusMessage = result.responseText;
      _pendingConfirmationResult = null;
    });

    await widget.voiceService.speak(result.responseText);

    if (result.intent == 'TOGGLE_STORE_STATUS' && widget.onDutyToggle != null) {
      widget.onDutyToggle!();
    }

    if (result.targetRoute != null && mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).pop();
        context.push(result.targetRoute!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: FreskaVendorColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(FreskaRadius.xl)),
        border: Border.all(color: FreskaVendorColors.primary.withValues(alpha: 0.6), width: 1.5),
        boxShadow: FreskaShadows.elevated,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: FreskaVendorColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(FreskaRadius.pill),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FreskaVendorColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(FreskaRadius.sm),
                ),
                child: const Icon(Icons.mic_rounded, color: FreskaVendorColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Freska Kitchen Voice AI',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    'Hands-free rapid merchant command terminal',
                    style: TextStyle(fontSize: 12, color: FreskaVendorColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: FreskaVendorColors.textSecondary, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Animated Mic Orb
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.12);
              return Transform.scale(
                scale: _isProcessing ? 1.0 : scale,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        FreskaVendorColors.primary.withValues(alpha: 0.3),
                        FreskaVendorColors.bgElevated,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: FreskaVendorColors.primary.withValues(alpha: 0.7),
                      width: 2,
                    ),
                    boxShadow: FreskaShadows.amberGlow,
                  ),
                  child: Center(
                    child: _isProcessing
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(color: FreskaVendorColors.primary, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.graphic_eq_rounded, color: FreskaVendorColors.primary, size: 38),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Status & Response Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: FreskaVendorColors.bgElevated,
              borderRadius: BorderRadius.circular(FreskaRadius.md),
              border: Border.all(color: FreskaVendorColors.bgSubtle),
            ),
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _pendingConfirmationResult != null ? FreskaVendorColors.statusWarning : Colors.white,
                height: 1.4,
              ),
            ),
          ),
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"$_recognizedText"',
              style: const TextStyle(fontSize: 12, color: FreskaVendorColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 18),

          // Confirmation Prompt buttons if high-risk action
          if (_pendingConfirmationResult != null) ...[
            Row(
              children: [
                Expanded(
                  child: FreskaVendorButton(
                    label: 'Cancel',
                    variant: FreskaVendorButtonVariant.outline,
                    onPressed: () {
                      setState(() {
                        _pendingConfirmationResult = null;
                        _statusMessage = 'Action cancelled.';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FreskaVendorButton(
                    label: 'Yes, Confirm',
                    variant: FreskaVendorButtonVariant.primary,
                    onPressed: () => _executeResult(_pendingConfirmationResult!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Quick Voice Commands',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FreskaVendorColors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickCommands.map((cmd) {
              return InkWell(
                borderRadius: BorderRadius.circular(FreskaRadius.pill),
                onTap: () => _handleCommand(cmd),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: FreskaVendorColors.bgElevated,
                    borderRadius: BorderRadius.circular(FreskaRadius.pill),
                    border: Border.all(color: FreskaVendorColors.bgSubtle),
                  ),
                  child: Text(cmd, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Direct text input
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: FreskaVendorColors.bgDarkest,
              borderRadius: BorderRadius.circular(FreskaRadius.md),
              border: Border.all(color: FreskaVendorColors.bgSubtle),
            ),
            child: TextField(
              controller: _textController,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Speak or type: "Mark order 89421 ready"...',
                hintStyle: const TextStyle(fontSize: 12, color: FreskaVendorColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: FreskaVendorColors.primary, size: 20),
                  onPressed: () {
                    final txt = _textController.text;
                    _textController.clear();
                    _handleCommand(txt);
                  },
                ),
              ),
              onSubmitted: (val) {
                _textController.clear();
                _handleCommand(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
