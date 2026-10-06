import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_customer/core/components/freska_card.dart';
import 'package:freska_customer/core/di/injection.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';
import 'package:freska_customer/features/orders/data/customer_orders_repository.dart';

class CustomerOrderTrackingScreen extends StatefulWidget {
  final int orderId;
  const CustomerOrderTrackingScreen({super.key, required this.orderId});

  @override
  State<CustomerOrderTrackingScreen> createState() => _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState extends State<CustomerOrderTrackingScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _trackingData;

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    setState(() => _isLoading = true);
    try {
      final repo = sl<CustomerOrdersRepository>();
      final data = await repo.getTrackingData(widget.orderId);
      setState(() {
        _trackingData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FreskaCustomerColors.bgDarkest,
        appBar: AppBar(title: const Text('Live Tracking')),
        body: const Center(child: CircularProgressIndicator(color: FreskaCustomerColors.primary)),
      );
    }

    final data = _trackingData;
    final order = (data?['order'] as Map<String, dynamic>?) ?? {};
    final orderNumber = order['order_number'] as String? ?? 'FSK-2026-89421';
    final status = data?['status'] as String? ?? order['status'] as String? ?? 'accepted';
    final deliveryOtp = data?['delivery_otp'] as String? ?? order['delivery_otp'] as String? ?? '4821';
    final rider = data?['rider'] as Map<String, dynamic>?;
    final vendor = data?['vendor'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Order #$orderNumber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTracking,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Delivery Confirmation OTP Hero Card
          FreskaCard(
            hasGlow: true,
            padding: const EdgeInsets.all(18),
            backgroundColor: FreskaCustomerColors.primary.withValues(alpha: 0.12),
            borderColor: FreskaCustomerColors.primary.withValues(alpha: 0.5),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERY CONFIRMATION OTP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: FreskaCustomerColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share this 4-digit code with the rider upon arrival:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: FreskaCustomerColors.primary,
                    borderRadius: BorderRadius.circular(FreskaRadius.sm),
                    boxShadow: FreskaShadows.primaryGlow,
                  ),
                  child: Text(
                    deliveryOtp,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lifecycle Stepper Card
          FreskaCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 16),
                _buildStep(
                  title: 'Order Placed & Confirmed',
                  subtitle: 'Store received your fresh order',
                  isCompleted: true,
                  isActive: false,
                ),
                _buildStep(
                  title: 'Store Preparing & Cold-Chain Packing',
                  subtitle: 'Item temperature inspected and packed',
                  isCompleted: status != 'created',
                  isActive: status == 'accepted' || status == 'dispatched',
                ),
                _buildStep(
                  title: 'Rider Assigned & In-Transit',
                  subtitle: 'Rider is on the way with your order',
                  isCompleted: status == 'picked_up' || status == 'in_transit' || status == 'delivered',
                  isActive: status == 'picked_up' || status == 'in_transit',
                ),
                _buildStep(
                  title: 'Order Delivered',
                  subtitle: 'Completed successfully',
                  isCompleted: status == 'delivered',
                  isActive: false,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Rider Details Card (if assigned)
          if (rider != null) ...[
            FreskaCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: FreskaCustomerColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, color: FreskaCustomerColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rider['name'] as String? ?? 'Arjun Sharma',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          'Vehicle: ${rider['vehicle_number'] ?? 'KA01EQ4921'} • ⭐ ${rider['rating'] ?? '4.95'}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: FreskaCustomerColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.call_rounded, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling rider at ${rider['phone']}')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Store Details
          if (vendor != null)
            FreskaCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: FreskaCustomerColors.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor['name'] as String? ?? 'Freska Hub',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          vendor['address'] as String? ?? 'Koramangala, Bengaluru',
                          style: const TextStyle(fontSize: 11, color: FreskaCustomerColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? FreskaCustomerColors.primary
                    : isActive
                        ? FreskaCustomerColors.primary.withValues(alpha: 0.3)
                        : FreskaCustomerColors.bgElevated,
                border: Border.all(
                  color: isCompleted || isActive ? FreskaCustomerColors.primary : FreskaCustomerColors.bgSubtle,
                  width: 2,
                ),
                boxShadow: isActive ? FreskaShadows.primaryGlow : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                  : isActive
                      ? const Center(child: CircleAvatar(radius: 4, backgroundColor: FreskaCustomerColors.primary))
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? FreskaCustomerColors.primary : FreskaCustomerColors.bgSubtle,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isCompleted || isActive ? Colors.white : FreskaCustomerColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
