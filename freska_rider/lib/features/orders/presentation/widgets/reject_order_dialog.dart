import 'package:flutter/material.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';
import 'package:freska_rider/shared/widgets/buttons/stitch_primary_button.dart';

class RejectOrderDialog extends StatefulWidget {
  final ValueChanged<String> onConfirmReject;

  const RejectOrderDialog({
    super.key,
    required this.onConfirmReject,
  });

  static Future<void> show(BuildContext context,
      {required ValueChanged<String> onConfirmReject}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: StitchColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RejectOrderDialog(onConfirmReject: onConfirmReject),
    );
  }

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  final List<String> _reasons = [
    'Vehicle puncture / mechanical breakdown',
    'Too far from current location',
    'Low phone battery / charging needed',
    'Personal emergency',
    'Severe weather / heavy rain',
  ];

  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons.first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StitchColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Decline Delivery Offer',
              style: StitchTypography.headingMedium.copyWith(
                color: StitchColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select a reason to immediately route this delivery to the next nearest partner.',
              style: StitchTypography.bodyMedium.copyWith(
                color: StitchColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedReason = reason;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? StitchColors.primary.withValues(alpha: 0.15)
                        : StitchColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? StitchColors.primaryLight
                          : StitchColors.surfaceBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? StitchColors.primaryLight
                            : StitchColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: StitchTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? StitchColors.textPrimary
                                : StitchColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            StitchPrimaryButton(
              label: 'Confirm Decline',
              backgroundColor: StitchColors.danger,
              onPressed: () {
                if (_selectedReason != null) {
                  Navigator.of(context).pop();
                  widget.onConfirmReject(_selectedReason!);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
