import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';

class TierProgressCard extends StatelessWidget {
  final String currentTier;
  final double multiplier;
  final String? nextTier;
  final int deliveriesRemaining;
  final double progressPercentage;

  const TierProgressCard({
    super.key,
    required this.currentTier,
    required this.multiplier,
    this.nextTier,
    required this.deliveriesRemaining,
    required this.progressPercentage,
  });

  Color _getTierColor() {
    switch (currentTier.toLowerCase()) {
      case 'platinum':
        return const Color(0xFFE5E7EB);
      case 'gold':
        return StitchColors.accentGold;
      case 'silver':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tierColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: tierColor, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '${currentTier.toUpperCase()} PARTNER',
                    style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${multiplier}x Payout',
                  style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (nextTier != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Tier: ${nextTier!.toUpperCase()}',
                  style: const TextStyle(
                      color: StitchColors.textSecondaryDark, fontSize: 13),
                ),
                Text(
                  '$deliveriesRemaining deliveries to go',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (progressPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: StitchColors.darkSurfaceElevated,
              color: tierColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ] else ...[
            const Text(
              'Highest Tier Achieved! VIP dispatcher status & maximum payout multiplier unlocked.',
              style: TextStyle(
                  color: StitchColors.textSecondaryDark, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
