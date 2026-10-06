import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/components/freska_vendor_states.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import '../bloc/vendor_orders_bloc.dart';

class VendorOrdersScreen extends StatefulWidget {
  final String? initialTab;
  const VendorOrdersScreen({super.key, this.initialTab});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['All', 'New', 'Preparing', 'Ready', 'Completed'];

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialTab == 'new') initialIndex = 1;
    if (widget.initialTab == 'prep' || widget.initialTab == 'pending') initialIndex = 2;
    if (widget.initialTab == 'ready') initialIndex = 3;
    if (widget.initialTab == 'completed') initialIndex = 4;

    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_onTabChanged);

    _loadCurrentTabOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadCurrentTabOrders();
  }

  void _loadCurrentTabOrders() {
    String? statusFilter;
    final idx = _tabController.index;
    if (idx == 1) statusFilter = 'created';
    if (idx == 2) statusFilter = 'accepted';
    if (idx == 3) statusFilter = 'ready';
    if (idx == 4) statusFilter = 'delivered';

    context.read<VendorOrdersBloc>().add(LoadVendorOrdersEvent(statusFilter: statusFilter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaVendorColors.bgDarkest,
      appBar: AppBar(
        backgroundColor: FreskaVendorColors.bgDarkest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Store Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: FreskaVendorColors.bgSurface,
              borderRadius: BorderRadius.circular(FreskaRadius.pill),
              border: Border.all(color: FreskaVendorColors.bgSubtle),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: FreskaVendorColors.primary,
                borderRadius: BorderRadius.circular(FreskaRadius.pill),
                boxShadow: FreskaShadows.amberGlow,
              ),
              labelColor: Colors.black,
              unselectedLabelColor: FreskaVendorColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
      ),
      body: BlocBuilder<VendorOrdersBloc, VendorOrdersState>(
        builder: (context, state) {
          if (state is VendorOrdersLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary));
          }

          if (state is VendorOrdersError) {
            return FreskaVendorErrorState(
              message: state.message,
              onRetry: _loadCurrentTabOrders,
            );
          }

          if (state is! VendorOrdersLoaded) {
            return const SizedBox.shrink();
          }

          final orders = state.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FreskaVendorColors.bgSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: FreskaVendorColors.bgSubtle),
                    ),
                    child: const Icon(Icons.inbox_rounded, size: 48, color: FreskaVendorColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders in this queue',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Incoming orders will populate automatically.',
                    style: TextStyle(color: FreskaVendorColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: FreskaVendorColors.primary,
            backgroundColor: FreskaVendorColors.bgElevated,
            onRefresh: () async => _loadCurrentTabOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final id = order['id'] as int;
    final orderNum = order['order_number'] as String? ?? 'FSK-2026-89421';
    final status = order['status'] as String? ?? 'accepted';
    final total = order['total_amount'] ?? '0.00';
    final customer = order['customer_name'] as String? ?? 'Customer';
    final itemsCount = order['item_count'] ?? 1;

    FreskaVendorBadgeVariant badgeVariant = FreskaVendorBadgeVariant.status;
    String badgeText = status.toUpperCase();

    if (status == 'created') {
      badgeVariant = FreskaVendorBadgeVariant.error;
      badgeText = 'NEW ORDER';
    } else if (status == 'accepted') {
      badgeVariant = FreskaVendorBadgeVariant.status;
      badgeText = 'PREPARING';
    } else if (status == 'ready' || status == 'dispatched') {
      badgeVariant = FreskaVendorBadgeVariant.coldChain;
      badgeText = 'READY FOR RIDER';
    } else if (status == 'delivered') {
      badgeVariant = FreskaVendorBadgeVariant.secondary;
      badgeText = 'COMPLETED';
    }

    return FreskaVendorCard(
      onTap: () => context.push('/orders/$id'),
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
                label: badgeText,
                variant: badgeVariant,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Customer: $customer • $itemsCount items',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FreskaVendorColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹$total',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: FreskaVendorColors.primary),
              ),
              const Text(
                'View Ticket Details →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FreskaVendorColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
