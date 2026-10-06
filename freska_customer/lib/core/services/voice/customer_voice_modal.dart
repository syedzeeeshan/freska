import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/customer_theme.dart';
import 'voice_intent_engine.dart';
import 'voice_service.dart';

class CustomerVoiceModal extends StatefulWidget {
  final CustomerVoiceIntentEngine intentEngine;
  final VoiceService voiceService;

  const CustomerVoiceModal({
    super.key,
    required this.intentEngine,
    required this.voiceService,
  });

  static Future<void> show(
    BuildContext context, {
    required CustomerVoiceIntentEngine intentEngine,
    required VoiceService voiceService,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerVoiceModal(
        intentEngine: intentEngine,
        voiceService: voiceService,
      ),
    );
  }

  @override
  State<CustomerVoiceModal> createState() => _CustomerVoiceModalState();
}

class _CustomerVoiceModalState extends State<CustomerVoiceModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  String _statusText = 'Ask Freska Voice Assistant...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    widget.voiceService.speak('How can I help you with your order today?');
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitCommand(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Processing your request...';
    });

    final result = await widget.intentEngine.processCommand(query);

    setState(() {
      _isProcessing = false;
      _statusText = result.spokenResponse;
    });

    await widget.voiceService.speak(result.spokenResponse);

    if (result.targetRoute != null && mounted) {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) {
          Navigator.of(context).pop();
          context.push(result.targetRoute!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: FreskaCustomerColors.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(FreskaRadius.xl)),
          border: Border.all(color: FreskaCustomerColors.bgSubtle, width: 1.5),
          boxShadow: FreskaShadows.elevated,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: FreskaCustomerColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(FreskaRadius.pill),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FreskaCustomerColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(FreskaRadius.sm),
                  ),
                  child: const Icon(Icons.mic, color: FreskaCustomerColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freska Voice AI',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'Hands-free rapid grocery ordering',
                      style: TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: FreskaCustomerColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = 1.0 + (_animController.value * 0.12);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          FreskaCustomerColors.primary.withValues(alpha: 0.25),
                          FreskaCustomerColors.coldChain.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: FreskaCustomerColors.primary.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: FreskaShadows.primaryGlow,
                    ),
                    child: const Icon(Icons.graphic_eq_rounded, color: FreskaCustomerColors.primary, size: 38),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: FreskaCustomerColors.bgElevated,
                borderRadius: BorderRadius.circular(FreskaRadius.md),
                border: Border.all(color: FreskaCustomerColors.bgSubtle),
              ),
              child: Text(
                _statusText,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Speak or type: "Find strawberries"...',
                      hintStyle: const TextStyle(color: FreskaCustomerColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: FreskaCustomerColors.bgDarkest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FreskaRadius.md),
                        borderSide: const BorderSide(color: FreskaCustomerColors.bgSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FreskaRadius.md),
                        borderSide: const BorderSide(color: FreskaCustomerColors.bgSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FreskaRadius.md),
                        borderSide: const BorderSide(color: FreskaCustomerColors.primary, width: 1.5),
                      ),
                    ),
                    onSubmitted: (val) {
                      _submitCommand(val);
                      _textController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: FreskaCustomerColors.primary,
                  borderRadius: BorderRadius.circular(FreskaRadius.md),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(FreskaRadius.md),
                    onTap: _isProcessing
                        ? null
                        : () {
                            _submitCommand(_textController.text);
                            _textController.clear();
                          },
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Find strawberries',
                'Organic farm milk',
                'Open my cart',
                'Track my order',
                'Saved addresses',
              ].map((chip) {
                return InkWell(
                  borderRadius: BorderRadius.circular(FreskaRadius.pill),
                  onTap: () {
                    _textController.text = chip;
                    _submitCommand(chip);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: FreskaCustomerColors.bgElevated,
                      borderRadius: BorderRadius.circular(FreskaRadius.pill),
                      border: Border.all(color: FreskaCustomerColors.bgSubtle),
                    ),
                    child: Text(chip, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

