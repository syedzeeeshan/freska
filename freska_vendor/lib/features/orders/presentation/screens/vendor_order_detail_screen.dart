import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/di/injection.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import 'package:freska_vendor/features/orders/data/vendor_orders_repository.dart';
import '../bloc/vendor_orders_bloc.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const VendorOrderDetailScreen({super.key, required this.orderId});

  @override
  State<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  bool _isLoading = true;
  bool _isActionInProgress = false;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final repo = sl<VendorOrdersRepository>();
      final data = await repo.getOrderDetail(widget.orderId);
      setState(() {
        _order = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isActionInProgress = true);
    try {
      final repo = sl<VendorOrdersRepository>();
      final updated = await repo.updateOrderStatus(orderId: widget.orderId, status: newStatus);
      if (mounted) {
        setState(() {
          _order = updated;
          _isActionInProgress = false;
        });
        context.read<VendorOrdersBloc>().add(const LoadVendorOrdersEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: FreskaVendorColors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: FreskaVendorColors.statusError,
          ),
        );
      }
    }
  }

  void _confirmMarkReady() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FreskaVendorColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FreskaRadius.xl),
          side: const BorderSide(color: FreskaVendorColors.bgSubtle),
        ),
        title: const Text('Mark Order Ready?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text(
          'Confirm that all items are prepared, inspected for freshness, and packed in certified cold-chain bags ready for rider dispatch.',
          style: TextStyle(color: FreskaVendorColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: FreskaVendorColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          FreskaVendorButton(
            label: 'Confirm Ready ✓',
            height: 40,
            variant: FreskaVendorButtonVariant.secondary,
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus('ready');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FreskaVendorColors.bgDarkest,
        appBar: AppBar(title: const Text('Kitchen Ticket')),
        body: const Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary)),
      );
    }

    final order = _order;
    if (order == null) {
      return Scaffold(
        backgroundColor: FreskaVendorColors.bgDarkest,
        appBar: AppBar(title: const Text('Order Not Found')),
        body: const Center(child: Text('Order details unavailable', style: TextStyle(color: Colors.white))),
      );
    }

    final orderNum = order['order_number'] as String? ?? 'FSK-2026-89421';
    final status = order['status'] as String? ?? 'accepted';
    final total = order['total_amount'] ?? '0.00';
    final customer = order['customer'] as Map<String, dynamic>?;
    final customerName = customer?['name'] as String? ?? 'Priya V.';
    final customerPhone = customer?['phone'] as String? ?? '+91 99887 76655';
    final instructions = order['delivery_instructions'] as String? ?? 'Leave at door / ring once';
    final items = (order['items'] as List<dynamic>?) ?? [];
    final rider = order['rider'] as Map<String, dynamic>?;

    FreskaVendorBadgeVariant badgeVariant = FreskaVendorBadgeVariant.status;
    String statusText = 'PREPARING';
    if (status == 'created') {
      badgeVariant = FreskaVendorBadgeVariant.error;
      statusText = 'NEW ORDER';
    } else if (status == 'ready' || status == 'dispatched') {
      badgeVariant = FreskaVendorBadgeVariant.coldChain;
      statusText = 'READY FOR RIDER';
    } else if (status == 'delivered') {
      badgeVariant = FreskaVendorBadgeVariant.secondary;
      statusText = 'DELIVERED';
    }

    return Scaffold(
      backgroundColor: FreskaVendorColors.bgDarkest,
      appBar: AppBar(
        backgroundColor: FreskaVendorColors.bgDarkest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Ticket #$orderNum'),
      ),
      bottomNavigationBar: _buildBottomActionBar(status),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Order Status Header Card
          FreskaVendorCard(
            hasGlow: true,
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: FreskaVendorColors.textSecondary)),
                    const SizedBox(height: 6),
                    FreskaVendorBadge(
                      label: statusText,
                      variant: badgeVariant,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('BILL VALUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: FreskaVendorColors.textMuted)),
                    const SizedBox(height: 4),
                    Text('₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer & Delivery Info Card
          FreskaVendorCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: FreskaVendorColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Customer & Dispatch Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Name: $customerName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Phone: $customerPhone', style: const TextStyle(fontSize: 13, color: FreskaVendorColors.textSecondary)),
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FreskaVendorColors.bgElevated,
                      borderRadius: BorderRadius.circular(FreskaRadius.sm),
                      border: Border.all(color: FreskaVendorColors.bgSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: FreskaVendorColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Special Instructions: $instructions',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rider Assigned (if applicable)
          if (rider != null) ...[
            FreskaVendorCard(
              border: BorderSide(color: FreskaVendorColors.coldChain.withValues(alpha: 0.4), width: 1.2),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FreskaVendorColors.coldChain.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, color: FreskaVendorColors.coldChain, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assigned Delivery Partner', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: FreskaVendorColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(rider['name'] as String? ?? 'Arjun Sharma', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('Vehicle: ${rider['vehicle_number'] ?? 'KA01EQ4921'}', style: const TextStyle(fontSize: 12, color: FreskaVendorColors.coldChain)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Item Checklist
          const Text(
            'Order Items & Cold-Chain Checklist',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildItemRow(item as Map<String, dynamic>)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final name = item['name'] as String? ?? 'Item';
    final qty = item['quantity'] ?? 1;
    final price = item['price'] ?? 0;
    final isCold = item['is_cold_chain'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FreskaVendorCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: FreskaVendorColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(FreskaRadius.sm),
                border: Border.all(color: FreskaVendorColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text('${qty}x', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: FreskaVendorColors.primary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  if (isCold) ...[
                    const SizedBox(height: 4),
                    const FreskaVendorBadge(
                      label: '4°C COLD CHAIN BAG',
                      variant: FreskaVendorBadgeVariant.coldChain,
                      icon: Icons.ac_unit_rounded,
                      fontSize: 10,
                    ),
                  ],
                ],
              ),
            ),
            Text('₹$price', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomActionBar(String status) {
    if (status == 'delivered' || status == 'cancelled') return null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: FreskaVendorColors.bgSurface,
        border: Border(top: BorderSide(color: FreskaVendorColors.bgSubtle, width: 1.5)),
      ),
      child: SafeArea(
        child: _isActionInProgress
            ? const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary)),
              )
            : status == 'created'
                ? FreskaVendorButton(
                    label: 'Accept & Begin Preparation →',
                    variant: FreskaVendorButtonVariant.primary,
                    width: double.infinity,
                    onPressed: () => _updateStatus('accepted'),
                  )
                : status == 'accepted'
                    ? FreskaVendorButton(
                        label: 'Mark Ready for Rider Pickup ✓',
                        variant: FreskaVendorButtonVariant.secondary,
                        width: double.infinity,
                        onPressed: _confirmMarkReady,
                      )
                    : Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: FreskaVendorColors.coldChain.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(FreskaRadius.md),
                          border: Border.all(color: FreskaVendorColors.coldChain.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'Ready for Rider Pickup • Live Telemetry Active',
                          style: TextStyle(color: FreskaVendorColors.coldChain, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
      ),
    );
  }
}
