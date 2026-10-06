import 'package:flutter/material.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';
import 'package:freska_rider/features/orders/domain/entities/active_order_entity.dart';

class ActiveOrderBanner extends StatelessWidget {
  final ActiveOrderEntity order;
  final VoidCallback onTap;

  const ActiveOrderBanner({
    super.key,
    required this.order,
    required this.onTap,
  });

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              StitchColors.surface,
              StitchColors.surfaceElevated,
            ],
          ),
          border: Border.all(
            color: StitchColors.primaryLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: StitchColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: StitchColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: StitchColors.primaryLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatStatus(order.status),
                        style: StitchTypography.bodyMedium.copyWith(
                          color: StitchColors.primaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${order.totalRiderPayout.toStringAsFixed(2)}',
                  style: StitchTypography.bodyLarge.copyWith(
                    color: StitchColors.accentGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: StitchColors.primaryLight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.vendor.name,
                    style: StitchTypography.bodyLarge.copyWith(
                      color: StitchColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: StitchColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customer.deliveryArea,
                    style: StitchTypography.bodyMedium.copyWith(
                      color: StitchColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: StitchTypography.bodyMedium.copyWith(
                    color: StitchColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'View Route',
                      style: StitchTypography.bodyMedium.copyWith(
                        color: StitchColors.primaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: StitchColors.primaryLight,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
