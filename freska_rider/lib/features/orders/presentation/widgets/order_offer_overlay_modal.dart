import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';
import 'package:freska_rider/features/orders/domain/entities/order_offer_entity.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_cubit.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_state.dart';
import 'package:freska_rider/features/orders/presentation/widgets/reject_order_dialog.dart';
import 'package:freska_rider/shared/widgets/cards/stitch_surface_card.dart';
import 'package:freska_rider/shared/widgets/sliders/swipe_action_button.dart';

class OrderOfferOverlayModal extends StatelessWidget {
  final OrderOfferEntity offer;
  final VoidCallback onAccepted;
  final VoidCallback onDismissed;

  const OrderOfferOverlayModal({
    super.key,
    required this.offer,
    required this.onAccepted,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderOfferCubit, OrderOfferState>(
      listener: (context, state) {
        if (state.status == OrderOfferStatus.accepted) {
          onAccepted();
        } else if (state.status == OrderOfferStatus.rejected ||
            state.status == OrderOfferStatus.expired) {
          onDismissed();
        }
      },
      builder: (context, state) {
        final remaining = state.remainingSeconds;
        final progress = (remaining / 30.0).clamp(0.0, 1.0);
        final isAccepting = state.status == OrderOfferStatus.accepting;
        final isRejecting = state.status == OrderOfferStatus.rejecting;

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: StitchColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side:
                const BorderSide(color: StitchColors.surfaceBorder, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Header: Countdown Circle & Alert Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: StitchColors.accentGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NEW DELIVERY OFFER',
                          style: StitchTypography.bodyMedium.copyWith(
                            color: StitchColors.accentGold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),

                    // Circular Countdown Ring (30s)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor: StitchColors.surfaceElevated,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              remaining > 10
                                  ? StitchColors.primaryLight
                                  : StitchColors.danger,
                            ),
                          ),
                        ),
                        Text(
                          '${remaining}s',
                          style: StitchTypography.headingSmall.copyWith(
                            color: StitchColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // High-Visibility Payout Banner
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: StitchColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: StitchColors.accentGold.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ESTIMATED EARNING',
                        style: StitchTypography.bodyMedium.copyWith(
                          color: StitchColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${offer.totalRiderPayout.toStringAsFixed(2)}',
                        style: StitchTypography.headingLarge.copyWith(
                          color: StitchColors.accentGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.route_rounded,
                            size: 16,
                            color: StitchColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.estimatedDistanceKm.toStringAsFixed(1)} km',
                            style: StitchTypography.bodyMedium.copyWith(
                              color: StitchColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: StitchColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~${offer.estimatedDurationMins} mins',
                            style: StitchTypography.bodyMedium.copyWith(
                              color: StitchColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Route Details (Vendor & Customer)
                StitchSurfaceCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // Pickup
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: StitchColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: StitchColors.primaryLight,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PICKUP',
                                  style: StitchTypography.bodyMedium.copyWith(
                                    color: StitchColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  offer.vendorName,
                                  style: StitchTypography.bodyLarge.copyWith(
                                    color: StitchColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  offer.vendorAddress,
                                  style: StitchTypography.bodyMedium.copyWith(
                                    color: StitchColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                            color: StitchColors.surfaceBorder, height: 1),
                      ),

                      // Delivery
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: StitchColors.accentGold.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: StitchColors.accentGold,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DELIVER TO',
                                  style: StitchTypography.bodyMedium.copyWith(
                                    color: StitchColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  offer.deliveryArea,
                                  style: StitchTypography.bodyLarge.copyWith(
                                    color: StitchColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Order Tags (Cold Chain / Item Count / Payment Mode)
                Row(
                  children: [
                    if (offer.isColdChain) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: StitchColors.infoBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: StitchColors.infoBlue.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.ac_unit_rounded,
                                size: 14, color: StitchColors.infoBlue),
                            const SizedBox(width: 4),
                            Text(
                              'COLD CHAIN',
                              style: StitchTypography.bodyMedium.copyWith(
                                color: StitchColors.infoBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: StitchColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${offer.itemCount} Items',
                        style: StitchTypography.bodyMedium.copyWith(
                          color: StitchColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: StitchColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        offer.paymentMode == 'cod'
                            ? 'COD ₹${offer.codAmount.toStringAsFixed(0)}'
                            : 'PREPAID',
                        style: StitchTypography.bodyMedium.copyWith(
                          color: StitchColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Google Stitch Signature "Swipe to Accept" slider
                SwipeActionButton(
                  label: 'Swipe to Accept',
                  isLoading: isAccepting,
                  enabled: remaining > 0 && !isRejecting,
                  onSwipeComplete: () {
                    context.read<OrderOfferCubit>().acceptCurrentOffer();
                  },
                ),

                const SizedBox(height: 12),

                // Decline Option
                TextButton(
                  onPressed: (remaining > 0 && !isAccepting && !isRejecting)
                      ? () {
                          RejectOrderDialog.show(
                            context,
                            onConfirmReject: (reason) {
                              context
                                  .read<OrderOfferCubit>()
                                  .rejectCurrentOffer(reason);
                            },
                          );
                        }
                      : null,
                  child: Text(
                    'Decline Offer',
                    style: StitchTypography.bodyMedium.copyWith(
                      color: StitchColors.textMuted,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
