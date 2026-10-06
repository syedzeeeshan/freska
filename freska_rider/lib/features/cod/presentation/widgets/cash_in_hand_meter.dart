import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';

class CashInHandMeter extends StatelessWidget {
  final double currentAmount;
  final double maxLimit;

  const CashInHandMeter({
    super.key,
    required this.currentAmount,
    required this.maxLimit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        (currentAmount / (maxLimit > 0 ? maxLimit : 5000)).clamp(0.0, 1.0);
    final isNearLimit = percentage >= 0.8;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNearLimit ? StitchColors.dangerSOS : StitchColors.darkBorder,
          width: isNearLimit ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Running Cash in Hand',
                style: TextStyle(
                    color: StitchColors.textSecondaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNearLimit
                      ? StitchColors.dangerSOS.withValues(alpha: 0.15)
                      : StitchColors.primaryFresh.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isNearLimit ? 'Near Limit' : 'Safe Headroom',
                  style: TextStyle(
                    color: isNearLimit
                        ? StitchColors.dangerSOS
                        : StitchColors.primaryFreshLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${currentAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isNearLimit
                  ? StitchColors.dangerSOS
                  : StitchColors.accentGold,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: StitchColors.darkSurfaceElevated,
            color:
                isNearLimit ? StitchColors.dangerSOS : StitchColors.accentGold,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Limit: ₹${maxLimit.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: StitchColors.textSecondaryDark, fontSize: 12),
              ),
              Text(
                'Remaining: ₹${(maxLimit - currentAmount).clamp(0.0, maxLimit).toStringAsFixed(0)}',
                style: const TextStyle(
                    color: StitchColors.textSecondaryDark, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
