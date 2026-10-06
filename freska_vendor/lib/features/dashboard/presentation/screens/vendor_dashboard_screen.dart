import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/di/injection.dart';
import 'package:freska_vendor/core/services/voice/vendor_voice_intent_engine.dart';
import 'package:freska_vendor/core/services/voice/vendor_voice_modal.dart';
import 'package:freska_vendor/core/services/voice/vendor_voice_service.dart';
import 'package:freska_vendor/core/components/freska_vendor_states.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import '../bloc/vendor_dashboard_bloc.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<VendorDashboardBloc>().add(LoadVendorDashboardEvent());
  }

  void _openVoiceAI() {
    VendorVoiceModal.show(
      context,
      intentEngine: sl<VendorVoiceIntentEngine>(),
      voiceService: sl<VendorVoiceService>(),
      onDutyToggle: () {
        context.read<VendorDashboardBloc>().add(ToggleStoreStatusEvent());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaVendorColors.bgDarkest,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FreskaVendorColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.mic_rounded, size: 22),
        label: const Text(
          'Voice Terminal',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.3),
        ),
        onPressed: _openVoiceAI,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: FreskaVendorColors.bgSurface,
          border: Border(top: BorderSide(color: FreskaVendorColors.bgSubtle, width: 1.2)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: FreskaVendorColors.primary.withValues(alpha: 0.22),
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            if (index == 1) context.push('/orders');
            if (index == 2) context.push('/menu');
            if (index == 3) context.push('/earnings');
            if (index == 4) context.push('/profile');
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: FreskaVendorColors.textSecondary),
              selectedIcon: Icon(Icons.dashboard_rounded, color: FreskaVendorColors.primary),
              label: 'Terminal',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: FreskaVendorColors.textSecondary),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: FreskaVendorColors.primary),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined, color: FreskaVendorColors.textSecondary),
              selectedIcon: Icon(Icons.restaurant_menu_rounded, color: FreskaVendorColors.primary),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, color: FreskaVendorColors.textSecondary),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: FreskaVendorColors.primary),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.store_outlined, color: FreskaVendorColors.textSecondary),
              selectedIcon: Icon(Icons.store_rounded, color: FreskaVendorColors.primary),
              label: 'Store',
            ),
          ],
        ),
      ),
      body: BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
        builder: (context, state) {
          if (state is VendorDashboardLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary));
          }

          if (state is VendorDashboardError) {
            return FreskaVendorErrorState(
              message: state.message,
              onRetry: () => context.read<VendorDashboardBloc>().add(LoadVendorDashboardEvent()),
            );
          }

          final data = state is VendorDashboardLoaded ? state.data : <String, dynamic>{};
          final vendor = (data['vendor'] as Map<String, dynamic>?) ?? {};
          final storeName = vendor['name'] as String? ?? 'Koramangala Fresh Hub';
          final isOpen = vendor['is_open'] == true;
          final stats = (data['today_stats'] as Map<String, dynamic>?) ?? {};
          final newCount = stats['new_orders'] ?? 1;
          final prepCount = stats['preparing'] ?? 2;
          final readyCount = stats['ready'] ?? 1;
          final todaySales = stats['total_sales'] ?? '18,450';
          final activeOrders = (data['active_orders'] as List<dynamic>?) ?? [];

          return CustomScrollView(
            slivers: [
              // Dimensional Top App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: FreskaVendorColors.bgDarkest,
                title: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen ? FreskaVendorColors.statusSuccess : FreskaVendorColors.statusError,
                        boxShadow: [
                          BoxShadow(
                            color: (isOpen ? FreskaVendorColors.statusSuccess : FreskaVendorColors.statusError)
                                .withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isOpen ? 'Accepting Live Orders • Online' : 'Store Paused / Offline',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOpen ? FreskaVendorColors.statusSuccess : FreskaVendorColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Store Online/Offline Toggle Chip
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(FreskaRadius.pill),
                      onTap: () {
                        context.read<VendorDashboardBloc>().add(ToggleStoreStatusEvent());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? FreskaVendorColors.statusSuccess.withValues(alpha: 0.15)
                              : FreskaVendorColors.bgElevated,
                          borderRadius: BorderRadius.circular(FreskaRadius.pill),
                          border: Border.all(
                            color: isOpen ? FreskaVendorColors.statusSuccess : FreskaVendorColors.bgSubtle,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOpen ? Icons.check_circle_rounded : Icons.pause_circle_filled_rounded,
                              size: 14,
                              color: isOpen ? FreskaVendorColors.statusSuccess : FreskaVendorColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOpen ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: isOpen ? FreskaVendorColors.statusSuccess : FreskaVendorColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Operational Counters & Revenue
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Revenue Banner Card with Glowing Amber Gradient
                      FreskaVendorCard(
                        hasGlow: true,
                        glowColor: FreskaVendorColors.primary,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.trending_up_rounded, color: FreskaVendorColors.primary, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'TODAY\'S REVENUE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: FreskaVendorColors.primary,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹$todaySales',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FreskaVendorButton(
                              label: 'Statements →',
                              height: 38,
                              variant: FreskaVendorButtonVariant.outline,
                              onPressed: () => context.push('/earnings'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Kitchen Queue Status Header
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Live Kitchen Queue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          FreskaVendorBadge(
                            label: 'AUTO DISPATCH ACTIVE',
                            variant: FreskaVendorBadgeVariant.coldChain,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3-Column Queue Status Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildQueueCard(
                              title: 'NEW',
                              count: '$newCount',
                              color: FreskaVendorColors.statusError,
                              icon: Icons.notifications_active_rounded,
                              onTap: () => context.push('/orders?tab=new'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQueueCard(
                              title: 'PREPARING',
                              count: '$prepCount',
                              color: FreskaVendorColors.statusPreparing,
                              icon: Icons.soup_kitchen_rounded,
                              onTap: () => context.push('/orders?tab=prep'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQueueCard(
                              title: 'READY',
                              count: '$readyCount',
                              color: FreskaVendorColors.statusReady,
                              icon: Icons.check_circle_rounded,
                              onTap: () => context.push('/orders?tab=ready'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),

                      // Urgent Orders Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Kitchen Tickets',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          InkWell(
                            onTap: () => context.push('/orders'),
                            child: const Text(
                              'View All Orders →',
                              style: TextStyle(
                                color: FreskaVendorColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Active Orders List
              if (activeOrders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: FreskaVendorColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No active kitchen tickets right now.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FreskaVendorColors.textSecondary),
                        ),
                        Text(
                          'New orders will alert automatically.',
                          style: TextStyle(fontSize: 12, color: FreskaVendorColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = activeOrders[index] as Map<String, dynamic>;
                        return _buildOrderTicketCard(order);
                      },
                      childCount: activeOrders.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQueueCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return FreskaVendorCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      backgroundColor: FreskaVendorColors.bgSurface,
      border: BorderSide(color: color.withValues(alpha: 0.35), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: FreskaVendorColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTicketCard(Map<String, dynamic> order) {
    final orderId = order['id'] ?? 89421;
    final orderNum = order['order_number'] as String? ?? 'FSK-2026-89421';
    final status = order['status'] as String? ?? 'accepted';
    final total = order['total_amount'] ?? '620.00';
    final customer = order['customer_name'] as String? ?? 'Priya V.';
    final itemCount = order['item_count'] ?? 3;

    FreskaVendorBadgeVariant badgeVariant = FreskaVendorBadgeVariant.status;
    String statusText = 'PREPARING';
    if (status == 'created') {
      badgeVariant = FreskaVendorBadgeVariant.error;
      statusText = 'NEW ORDER';
    } else if (status == 'ready' || status == 'dispatched') {
      badgeVariant = FreskaVendorBadgeVariant.coldChain;
      statusText = 'READY FOR RIDER';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FreskaVendorCard(
        onTap: () => context.push('/orders/$orderId'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#$orderNum',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const Spacer(),
                FreskaVendorBadge(
                  label: statusText,
                  variant: badgeVariant,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Customer: $customer • $itemCount items • ₹$total',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FreskaVendorColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FreskaVendorButton(
                    label: 'View Ticket',
                    height: 38,
                    variant: FreskaVendorButtonVariant.outline,
                    onPressed: () => context.push('/orders/$orderId'),
                  ),
                ),
                const SizedBox(width: 10),
                if (status == 'created')
                  Expanded(
                    child: FreskaVendorButton(
                      label: 'Accept',
                      height: 38,
                      variant: FreskaVendorButtonVariant.primary,
                      onPressed: () => context.push('/orders/$orderId'),
                    ),
                  )
                else if (status == 'accepted')
                  Expanded(
                    child: FreskaVendorButton(
                      label: 'Mark Ready',
                      height: 38,
                      variant: FreskaVendorButtonVariant.secondary,
                      onPressed: () => context.push('/orders/$orderId'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
