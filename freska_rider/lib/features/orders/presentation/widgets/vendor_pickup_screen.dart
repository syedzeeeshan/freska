import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';
import 'package:freska_rider/features/orders/domain/entities/active_order_entity.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_bloc.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_event.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_state.dart';
import 'package:freska_rider/features/orders/presentation/cubit/voice_navigation_cubit.dart';
import 'package:freska_rider/features/orders/presentation/widgets/voice_navigation_button.dart';
import 'package:freska_rider/shared/widgets/sliders/swipe_action_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen 05 – Vendor Pickup Screen
///
/// Guides rider to merchant store, displays package item checklist,
/// cold-chain alert, and two-stage confirmation controls.
/// - Stage 1: "Mark Arrived at Vendor" button
/// - Stage 2: "Swipe to Pick Up" (enabled only when full checklist is ticked)
class VendorPickupScreen extends StatefulWidget {
  final ActiveOrderEntity order;

  const VendorPickupScreen({super.key, required this.order});

  @override
  State<VendorPickupScreen> createState() => _VendorPickupScreenState();
}

class _VendorPickupScreenState extends State<VendorPickupScreen> {
  bool _hasArrivedAtVendor = false;
  late List<bool> _checklistState;

  @override
  void initState() {
    super.initState();
    _checklistState = List.generate(
      widget.order.packageDetails.itemCount.clamp(1, 20),
      (_) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VoiceNavigationCubit>().startNavigation(
              destinationName: widget.order.vendor.name,
              targetLat: widget.order.vendor.latitude,
              targetLng: widget.order.vendor.longitude,
            );
      }
    });
  }

  bool get _allChecked => _checklistState.every((v) => v);

  Future<void> _launchGoogleMaps() async {
    final vendor = widget.order.vendor;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${vendor.latitude},${vendor.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onMarkArrived(OrderLifecycleBloc bloc) {
    HapticFeedback.mediumImpact();
    context.read<VoiceNavigationCubit>().announceArrival();
    bloc.add(MarkArrivedAtVendorEvent(
      orderId: widget.order.id,
      latitude: widget.order.vendor.latitude,
      longitude: widget.order.vendor.longitude,
    ));
  }

  void _onSwipePickup(OrderLifecycleBloc bloc) {
    HapticFeedback.heavyImpact();
    bloc.add(PickupOrderEvent(
      orderId: widget.order.id,
      latitude: widget.order.vendor.latitude,
      longitude: widget.order.vendor.longitude,
      packageVerified: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderLifecycleBloc, OrderLifecycleState>(
      listener: (context, state) {
        if (state is ArrivedAtVendorSuccess) {
          setState(() => _hasArrivedAtVendor = true);
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arrival recorded. Verify the package.'),
              backgroundColor: StitchColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is OrderPickedUpSuccess) {
          context.pushReplacement(
            '/orders/delivery',
            extra: {
              'order': widget.order,
              'customerFullAddress': state.customerFullAddress,
              'customerPhone': state.customerPhone,
            },
          );
        } else if (state is OrderLifecycleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: StitchColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<OrderLifecycleBloc>();
        final isLoading = state is OrderLifecycleLoading;

        return Scaffold(
          backgroundColor: StitchColors.background,
          appBar: AppBar(
            backgroundColor: StitchColors.surface,
            elevation: 0,
            title: const Text(
              'Pick Up Order',
              style: StitchTypography.titleMedium,
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: VoiceNavigationButton(compact: true),
                ),
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: StitchColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // ── Vendor Store Card ─────────────────────────────────────
              _StitchSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: StitchColors.primaryDark.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.storefront_rounded,
                              color: StitchColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.order.vendor.name,
                                style: StitchTypography.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.order.vendor.storeCode,
                                style: StitchTypography.labelSmall.copyWith(
                                    color: StitchColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                        height: 20, color: StitchColors.surfaceBorder),
                    Text(
                      widget.order.vendor.address,
                      style: StitchTypography.bodyMedium
                          .copyWith(color: StitchColors.textSecondary),
                    ),
                    if (widget.order.vendor.landmark != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Landmark: ${widget.order.vendor.landmark}',
                        style: StitchTypography.bodySmall
                            .copyWith(color: StitchColors.textMuted),
                      ),
                    ],
                    if (widget.order.vendor.pickupInstructions != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: StitchColors.infoBlue.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: StitchColors.infoBlue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: StitchColors.infoBlue, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.order.vendor.pickupInstructions!,
                                style: StitchTypography.bodySmall
                                    .copyWith(color: StitchColors.infoBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _launchGoogleMaps,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: StitchColors.primary,
                              side:
                                  const BorderSide(color: StitchColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon:
                                const Icon(Icons.navigation_rounded, size: 18),
                            label: const Text('Google Maps'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const VoiceNavigationButton(compact: false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Cold-Chain Warning Banner ─────────────────────────────
              if (widget.order.packageDetails.isColdChain) _ColdChainBanner(),

              if (widget.order.packageDetails.isColdChain)
                const SizedBox(height: 12),

              // ── Package Checklist ─────────────────────────────────────
              _StitchSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.checklist_rounded,
                            color: StitchColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text('Package Checklist',
                            style: StitchTypography.titleSmall),
                        const Spacer(),
                        Text(
                          '${_checklistState.where((v) => v).length}/${_checklistState.length}',
                          style: StitchTypography.monoMedium
                              .copyWith(color: StitchColors.primary),
                        ),
                      ],
                    ),
                    const Divider(
                        height: 16, color: StitchColors.surfaceBorder),
                    ...List.generate(
                      _checklistState.length,
                      (index) => CheckboxListTile(
                        value: _checklistState[index],
                        onChanged: _hasArrivedAtVendor
                            ? (v) {
                                HapticFeedback.selectionClick();
                                setState(
                                    () => _checklistState[index] = v ?? false);
                              }
                            : null,
                        title: Text(
                          'Item ${index + 1}',
                          style: StitchTypography.bodyMedium.copyWith(
                            color: _hasArrivedAtVendor
                                ? StitchColors.textPrimary
                                : StitchColors.textMuted,
                          ),
                        ),
                        activeColor: StitchColors.primary,
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: _hasArrivedAtVendor
                              ? StitchColors.surfaceElevated
                              : StitchColors.textMuted,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                      ),
                    ),
                    if (!_hasArrivedAtVendor)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Checklist activates after marking arrival.',
                          style: StitchTypography.bodySmall
                              .copyWith(color: StitchColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Action Controls ───────────────────────────────────────
              if (!_hasArrivedAtVendor)
                _MarkArrivedButton(
                  isLoading: isLoading,
                  onPressed: () => _onMarkArrived(bloc),
                )
              else
                SwipeActionButton(
                  label: 'Swipe to Pick Up',
                  onSwipeComplete: () => _onSwipePickup(bloc),
                  enabled: _allChecked && !isLoading,
                  isLoading: isLoading,
                ),

              if (!_hasArrivedAtVendor && !_allChecked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Verify all checklist items to enable pickup.',
                    textAlign: TextAlign.center,
                    style: StitchTypography.bodySmall
                        .copyWith(color: StitchColors.textMuted),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _StitchSurfaceCard extends StatelessWidget {
  final Widget child;
  const _StitchSurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StitchColors.surfaceBorder, width: 1),
      ),
      child: child,
    );
  }
}

class _ColdChainBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.ac_unit_rounded, color: Color(0xFF0EA5E9), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cold-Chain Order',
                  style: StitchTypography.labelMedium
                      .copyWith(color: const Color(0xFF0EA5E9)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Contains refrigerated items. Place inside insulated thermal bag.',
                  style: StitchTypography.bodySmall
                      .copyWith(color: const Color(0xFF7DD3FC)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkArrivedButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _MarkArrivedButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: StitchColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: StitchColors.primaryDark.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Mark Arrived at Vendor',
                    style: StitchTypography.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}
