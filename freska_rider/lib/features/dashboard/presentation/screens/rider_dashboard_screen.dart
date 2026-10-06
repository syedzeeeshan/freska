import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_rider/core/di/injection.dart';
import 'package:freska_rider/core/theme/stitch_colors.dart';
import 'package:freska_rider/core/theme/stitch_typography.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_event.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_bloc.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_event.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_state.dart';
import 'package:freska_rider/features/dashboard/presentation/cubit/dashboard_summary_cubit.dart';
import 'package:freska_rider/features/dashboard/presentation/cubit/dashboard_summary_state.dart';
import 'package:freska_rider/features/dashboard/presentation/widgets/active_order_banner.dart';
import 'package:freska_rider/features/dashboard/presentation/widgets/metric_highlight_card.dart';
import 'package:freska_rider/features/dashboard/presentation/widgets/online_offline_switch.dart';
import 'package:freska_rider/core/network/api_client.dart';
import 'package:freska_rider/core/services/voice/voice_assistant_modal.dart';
import 'package:freska_rider/core/services/voice/voice_intent_engine.dart';
import 'package:freska_rider/core/services/voice_navigation_service.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_cubit.dart';
import 'package:freska_rider/features/orders/presentation/widgets/order_offer_overlay_modal.dart';
import 'package:freska_rider/shared/widgets/cards/stitch_surface_card.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  bool _isModalShowing = false;

  @override
  void initState() {
    super.initState();
    context.read<DashboardSummaryCubit>().loadDashboardSummary();
  }

  void _checkAndShowPendingOffer(DashboardSummaryState state) {
    final summary = state.summary;
    if (summary != null &&
        summary.hasPendingOffer &&
        summary.pendingOffer != null &&
        !_isModalShowing) {
      _isModalShowing = true;
      final offer = summary.pendingOffer!;
      context.read<OrderOfferCubit>().startOffer(offer);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: context.read<OrderOfferCubit>(),
          child: OrderOfferOverlayModal(
            offer: offer,
            onAccepted: () {
              Navigator.of(context, rootNavigator: true).pop();
              _isModalShowing = false;
              context
                  .read<DashboardSummaryCubit>()
                  .loadDashboardSummary(isRefresh: true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Order accepted! Navigate to vendor for pickup.'),
                  backgroundColor: StitchColors.primary,
                ),
              );
            },
            onDismissed: () {
              Navigator.of(context, rootNavigator: true).pop();
              _isModalShowing = false;
              context
                  .read<DashboardSummaryCubit>()
                  .loadDashboardSummary(isRefresh: true);
            },
          ),
        ),
      ).then((_) {
        _isModalShowing = false;
      });
    }
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StitchColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: StitchColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: StitchColors.primaryLight),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: StitchColors.primaryLight,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arjun Sharma',
                          style: StitchTypography.titleLarge,
                        ),
                        Text(
                          '+91 93429 31050 • Verified Partner',
                          style: TextStyle(
                            color: StitchColors.primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: StitchColors.surfaceBorder),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.two_wheeler_rounded, color: StitchColors.primaryLight),
                title: Text('Registered Vehicle'),
                subtitle: Text('Motorcycle (KA01AB1234)'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.verified_user_rounded, color: StitchColors.primaryLight),
                title: Text('KYC & Documents'),
                subtitle: Text('Verified & Approved'),
                trailing: Icon(Icons.check_circle_rounded, color: StitchColors.primaryLight),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.account_balance_rounded, color: StitchColors.primaryLight),
                title: Text('Bank Settlement'),
                subtitle: Text('HDFC Bank •••• 8231'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    sl<AuthBloc>().add(LogoutEvent());
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded, color: StitchColors.danger),
                  label: const Text('Log Out of Freska', style: TextStyle(color: StitchColors.danger)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: StitchColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DutyBloc, DutyState>(
          listener: (context, state) {
            if (state.status == DutyStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: StitchColors.danger,
                ),
              );
            } else if (state.status == DutyStatus.success) {
              context
                  .read<DashboardSummaryCubit>()
                  .loadDashboardSummary(isRefresh: true);
            }
          },
        ),
        BlocListener<DashboardSummaryCubit, DashboardSummaryState>(
          listener: (context, state) {
            if (state.status == DashboardSummaryStatus.success &&
                state.summary != null) {
              // Sync duty status with summary
              context.read<DutyBloc>().add(
                    SetInitialDutyEvent(isOnline: state.summary!.isOnline),
                  );
              // Trigger order offer modal if incoming offer is found
              _checkAndShowPendingOffer(state);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: StitchColors.background,
        appBar: AppBar(
          backgroundColor: StitchColors.background,
          elevation: 0,
          titleSpacing: 20,
          title: InkWell(
            onTap: () => _showProfileSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: StitchColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: StitchColors.primaryLight),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: StitchColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freska Partner',
                      style: StitchTypography.headingSmall.copyWith(
                        color: StitchColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Koramangala Hub',
                      style: StitchTypography.bodyMedium.copyWith(
                        color: StitchColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.mic, color: StitchColors.primaryLight),
              tooltip: 'Freska Voice AI',
              onPressed: () {
                VoiceAssistantModal.show(
                  context,
                  role: FreskaVoiceRole.rider,
                  intentEngine: VoiceIntentEngine(apiClient: sl<ApiClient>()),
                  ttsService: sl<VoiceNavigationService>(),
                  onActionTriggered: (action) {
                    if (action == 'GO_ONLINE') {
                      context.read<DutyBloc>().add(const ToggleDutyEvent(isOnline: true));
                    } else if (action == 'GO_OFFLINE') {
                      context.read<DutyBloc>().add(const ToggleDutyEvent(isOnline: false));
                    } else if (action == 'REPEAT_TTS') {
                      sl<VoiceNavigationService>().speak('Continuing on current delivery route.');
                    }
                  },
                );
              },
            ),
            BlocBuilder<DutyBloc, DutyState>(
              builder: (context, dutyState) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OnlineOfflineSwitch(
                    isOnline: dutyState.isOnline,
                    isToggling: dutyState.status == DutyStatus.toggling,
                    onToggle: (newOnline) {
                      context
                          .read<DutyBloc>()
                          .add(ToggleDutyEvent(isOnline: newOnline));
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          color: StitchColors.primaryLight,
          backgroundColor: StitchColors.surface,
          onRefresh: () async {
            await context
                .read<DashboardSummaryCubit>()
                .loadDashboardSummary(isRefresh: true);
          },
          child: BlocBuilder<DashboardSummaryCubit, DashboardSummaryState>(
            builder: (context, summaryState) {
              final summary = summaryState.summary;
              final metrics = summary?.metrics;
              final activeOrder = summary?.activeOrder;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Offline Guidance Banner
                  BlocBuilder<DutyBloc, DutyState>(
                    builder: (context, dutyState) {
                      if (!dutyState.isOnline) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                StitchColors.surfaceElevated.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: StitchColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.offline_bolt_outlined,
                                color: StitchColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You are currently Off Duty. Switch to Online to start receiving delivery offers.',
                                  style: StitchTypography.bodyMedium.copyWith(
                                    color: StitchColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Sticky Active In-Flight Order
                  if (activeOrder != null) ...[
                    Text(
                      'ACTIVE DELIVERY',
                      style: StitchTypography.bodyMedium.copyWith(
                        color: StitchColors.primaryLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ActiveOrderBanner(
                      order: activeOrder,
                      onTap: () {
                        // Navigates to active order detail/tracking
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Order #${activeOrder.orderNumber} active.'),
                            backgroundColor: StitchColors.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Performance & Daily Highlights Section
                  Text(
                    "TODAY'S OVERVIEW",
                    style: StitchTypography.bodyMedium.copyWith(
                      color: StitchColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/earnings'),
                          child: MetricHighlightCard(
                            title: "Today's Earnings",
                            value:
                                '₹${metrics?.todayEarnings.toStringAsFixed(2) ?? '0.00'}',
                            subtitle: 'Base + Distance + Tips',
                            icon: Icons.currency_rupee_rounded,
                            accentColor: StitchColors.accentGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/performance'),
                          child: MetricHighlightCard(
                            title: 'Completed Trips',
                            value: '${metrics?.todayDeliveriesCount ?? 0}',
                            subtitle: '100% on-time rate',
                            icon: Icons.check_circle_outline_rounded,
                            accentColor: StitchColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/performance'),
                          child: MetricHighlightCard(
                            title: 'Active Hours',
                            value:
                                '${metrics?.todayOnlineHours.toStringAsFixed(1) ?? '0.0'} hrs',
                            subtitle: 'Logged on duty',
                            icon: Icons.access_time_rounded,
                            accentColor: StitchColors.infoBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/performance'),
                          child: MetricHighlightCard(
                            title: 'Rating',
                            value:
                                '${metrics?.ratingAverage.toStringAsFixed(1) ?? '5.0'} ★',
                            subtitle:
                                '${metrics?.acceptanceRate.toStringAsFixed(0) ?? '100'}% Acceptance',
                            icon: Icons.star_rounded,
                            accentColor: StitchColors.accentGold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Cash in Hand vs Limit Meter
                  GestureDetector(
                    onTap: () => context.push('/cod'),
                    child: StitchSurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: StitchColors.primaryLight,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cash in Hand (COD)',
                                    style: StitchTypography.bodyLarge.copyWith(
                                      color: StitchColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${metrics?.currentCashInHand.toStringAsFixed(2) ?? '0.00'} / ₹${metrics?.maxCashLimit.toStringAsFixed(0) ?? '5000'}',
                                style: StitchTypography.bodyMedium.copyWith(
                                  color: StitchColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ((metrics?.currentCashInHand ?? 0) /
                                      (metrics?.maxCashLimit ?? 5000))
                                  .clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: StitchColors.surfaceElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ((metrics?.currentCashInHand ?? 0) >
                                        (metrics?.maxCashLimit ?? 5000) * 0.8)
                                    ? StitchColors.danger
                                    : StitchColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Action Hub: Support & Safety SOS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/support'),
                          icon: const Icon(Icons.headset_mic_rounded,
                              color: StitchColors.primaryLight, size: 18),
                          label: Text(
                            'Support',
                            style: StitchTypography.buttonText
                                .copyWith(color: StitchColors.textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: StitchColors.surfaceBorder),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/safety/sos'),
                          icon: const Icon(Icons.sos_rounded,
                              color: StitchColors.danger, size: 18),
                          label: Text(
                            'Emergency SOS',
                            style: StitchTypography.buttonText
                                .copyWith(color: StitchColors.danger),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: StitchColors.danger.withValues(alpha: 0.5)),
                            backgroundColor:
                                StitchColors.danger.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
