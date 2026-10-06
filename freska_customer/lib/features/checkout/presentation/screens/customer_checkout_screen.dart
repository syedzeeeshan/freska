import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_customer/core/components/freska_button.dart';
import 'package:freska_customer/core/components/freska_card.dart';
import 'package:freska_customer/core/di/injection.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';
import 'package:freska_customer/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:freska_customer/features/orders/data/customer_orders_repository.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  int _selectedAddressId = 1;
  String _paymentMode = 'cod';
  final TextEditingController _instructionsController = TextEditingController(text: 'Leave at door / ring once');
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);

    try {
      final ordersRepo = sl<CustomerOrdersRepository>();
      final order = await ordersRepo.placeOrder(
        addressId: _selectedAddressId,
        paymentMode: _paymentMode,
        instructions: _instructionsController.text.trim(),
      );

      if (mounted) {
        context.read<CustomerCartBloc>().add(LoadCartEvent());
        final orderId = order['id'] as int;
        context.go('/orders/$orderId/track');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: FreskaCustomerColors.statusError,
          ),
        );
      }
    }
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
        title: const Text('Checkout & Delivery'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: FreskaCustomerColors.bgSurface,
          border: Border(top: BorderSide(color: FreskaCustomerColors.bgSubtle, width: 1.5)),
          boxShadow: FreskaShadows.elevated,
        ),
        child: SafeArea(
          child: FreskaButton(
            label: 'Place Order & Track Live →',
            isLoading: _isPlacingOrder,
            width: double.infinity,
            height: 52,
            onPressed: _isPlacingOrder ? null : _placeOrder,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. Delivery Address Selection
          const Text(
            '1. Delivery Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 10),
          _buildAddressTile(
            id: 1,
            label: 'Home (Default)',
            address: '#412, 14th Main, HSR Layout Sector 1, Bengaluru 560102',
            recipient: 'Priya V. • +919988776655',
          ),
          _buildAddressTile(
            id: 2,
            label: 'Work',
            address: '4th Floor, WeWork Galaxy, 43 Residency Rd, Bengaluru 560025',
            recipient: 'Priya V. • +919988776655',
          ),
          const SizedBox(height: 20),

          // 2. Delivery Instructions
          const Text(
            '2. Delivery Instructions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 10),
          FreskaCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: FreskaCustomerColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _instructionsController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Ring bell once, leave with security...',
                      hintStyle: TextStyle(color: FreskaCustomerColors.textMuted, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Payment Method
          const Text(
            '3. Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 10),
          _buildPaymentTile(
            mode: 'cod',
            title: 'Cash on Delivery (COD)',
            subtitle: 'Pay exact cash or UPI QR upon delivery',
            icon: Icons.payments_outlined,
          ),
          _buildPaymentTile(
            mode: 'upi',
            title: 'Instant UPI',
            subtitle: 'Google Pay, PhonePe, Paytm',
            icon: Icons.qr_code_2_rounded,
          ),
          _buildPaymentTile(
            mode: 'online',
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, RuPay',
            icon: Icons.credit_card_rounded,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAddressTile({
    required int id,
    required String label,
    required String address,
    required String recipient,
  }) {
    final isSelected = _selectedAddressId == id;

    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 10),
      hasGlow: isSelected,
      padding: const EdgeInsets.all(14),
      onTap: () => setState(() => _selectedAddressId = id),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            color: isSelected ? FreskaCustomerColors.primary : FreskaCustomerColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text(address, style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary, height: 1.3)),
                const SizedBox(height: 3),
                Text(recipient, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile({
    required String mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMode == mode;

    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 10),
      hasGlow: isSelected,
      padding: const EdgeInsets.all(14),
      onTap: () => setState(() => _paymentMode = mode),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? FreskaCustomerColors.primary : FreskaCustomerColors.textSecondary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary)),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isSelected ? FreskaCustomerColors.primary : FreskaCustomerColors.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}
