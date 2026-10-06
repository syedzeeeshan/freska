import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/freska_badge.dart';
import '../../../../core/components/freska_card.dart';
import '../../../../core/theme/customer_theme.dart';
import '../bloc/customer_orders_bloc.dart';

class CustomerOrdersHistoryScreen extends StatefulWidget {
  const CustomerOrdersHistoryScreen({super.key});

  @override
  State<CustomerOrdersHistoryScreen> createState() => _CustomerOrdersHistoryScreenState();
}

class _CustomerOrdersHistoryScreenState extends State<CustomerOrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerOrdersBloc>().add(LoadCustomerOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('My Orders'),
      ),
      body: BlocBuilder<CustomerOrdersBloc, CustomerOrdersState>(
        builder: (context, state) {
          if (state is CustomerOrdersLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaCustomerColors.primary));
          }

          if (state is CustomerOrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<CustomerOrdersBloc>().add(LoadCustomerOrdersEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! CustomerOrdersLoaded) {
            return const SizedBox.shrink();
          }

          final orders = state.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FreskaCustomerColors.bgSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: FreskaCustomerColors.bgSubtle),
                    ),
                    child: const Icon(Icons.receipt_long_outlined, size: 48, color: FreskaCustomerColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('No past orders yet.', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: FreskaCustomerColors.primary,
            onRefresh: () async {
              context.read<CustomerOrdersBloc>().add(LoadCustomerOrdersEvent());
            },
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
    final status = order['status'] as String? ?? 'delivered';
    final total = order['total_amount'] ?? '0.00';
    final vendor = order['vendor'] as Map<String, dynamic>?;
    final vendorName = vendor?['name'] as String? ?? 'Freska Hub';
    final itemsCount = order['item_count'] ?? 1;

    Color badgeColor = FreskaCustomerColors.statusSuccess;
    if (status == 'created' || status == 'accepted' || status == 'in_transit') {
      badgeColor = FreskaCustomerColors.primary;
    } else if (status == 'cancelled') {
      badgeColor = FreskaCustomerColors.statusError;
    }

    return FreskaCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/orders/$id/track'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#$orderNum', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
              const Spacer(),
              FreskaBadge.status(status, color: badgeColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(vendorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text('$itemsCount items • Total ₹$total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary)),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Track / View Details →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FreskaCustomerColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
