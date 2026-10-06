import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep; // 1 to 4
  final int totalSteps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP $currentStep OF $totalSteps',
              style: StitchTypography.caption.copyWith(
                color: StitchColors.primaryLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              _getStepLabel(currentStep),
              style: StitchTypography.bodyEmphasis.copyWith(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(totalSteps, (index) {
            final step = index + 1;
            final isCompleted = step < currentStep;
            final isActive = step == currentStep;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
                height: 4,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? StitchColors.primary
                      : isActive
                          ? StitchColors.primaryLight
                          : StitchColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 1:
        return 'Profile Setup';
      case 2:
        return 'KYC Documents';
      case 3:
        return 'Bank & Payout';
      case 4:
        return 'Emergency Contact';
      default:
        return '';
    }
  }
}
