import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_spacing.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.stepLabels = const [
      'Vehicle & Documents',
      'Bank Details',
      'Emergency Contact'
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? StitchColors.primary
                            : StitchColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    const SizedBox(width: StitchSpacing.xs),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: StitchSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: StitchColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (currentStep < stepLabels.length)
              Text(
                stepLabels[currentStep],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: StitchColors.textSecondary,
                    ),
              ),
          ],
        ),
      ],
    );
  }
}
