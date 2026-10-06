import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_spacing.dart';

class KycStatusBadge extends StatelessWidget {
  final String status;

  const KycStatusBadge({
    super.key,
    required this.status,
  });

  Color get _badgeColor {
    switch (status.toLowerCase()) {
      case 'verified':
        return StitchColors.primary;
      case 'submitted':
        return StitchColors.infoBlue;
      case 'rejected':
        return StitchColors.danger;
      case 'pending':
      default:
        return StitchColors.accentGold;
    }
  }

  IconData get _badgeIcon {
    switch (status.toLowerCase()) {
      case 'verified':
        return Icons.verified_user_rounded;
      case 'submitted':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
      default:
        return Icons.pending_actions_rounded;
    }
  }

  String get _badgeText {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'KYC Verified';
      case 'submitted':
        return 'Under Review';
      case 'rejected':
        return 'Action Required';
      case 'pending':
      default:
        return 'KYC Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StitchSpacing.sm,
        vertical: StitchSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(StitchSpacing.borderRadiusFull),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_badgeIcon, color: _badgeColor, size: 14),
          const SizedBox(width: StitchSpacing.xs),
          Text(
            _badgeText,
            style: TextStyle(
              color: _badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
