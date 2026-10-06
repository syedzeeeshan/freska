import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_customer/core/components/freska_button.dart';
import 'package:freska_customer/core/components/freska_card.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';
import 'package:freska_customer/features/cart/presentation/bloc/cart_bloc.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerCartBloc>().add(LoadCartEvent());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: FreskaCustomerColors.textSecondary),
            tooltip: 'Clear Cart',
            onPressed: () {
              context.read<CustomerCartBloc>().add(ClearCartEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerCartBloc, CustomerCartState>(
        builder: (context, state) {
          if (state is CustomerCartLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaCustomerColors.primary));
          }

          if (state is! CustomerCartLoaded) {
            return const SizedBox.shrink();
          }

          final cart = state.cart;
          final items = (cart['items'] as List<dynamic>?) ?? [];
          final subtotal = cart['subtotal'] ?? 0.0;
          final deliveryFee = cart['delivery_fee'] ?? 0.0;
          final taxes = cart['taxes'] ?? 0.0;
          final discount = cart['discount_amount'] ?? 0.0;
          final total = cart['total_amount'] ?? 0.0;
          final isCold = cart['is_cold_chain'] == true;
          final vendor = cart['vendor'] as Map<String, dynamic>?;

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FreskaCustomerColors.bgSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: FreskaCustomerColors.bgSubtle),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: FreskaCustomerColors.textMuted, size: 56),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your cart is currently empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore nearby farm markets and artisan bakeries to add fresh items.',
                      style: TextStyle(fontSize: 13, color: FreskaCustomerColors.textSecondary, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FreskaButton(
                      label: 'Explore Fresh Markets',
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    if (vendor != null) ...[
                      FreskaCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_rounded, color: FreskaCustomerColors.primary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ordering from ${vendor['name']}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Items list
                    ...items.map((it) => _buildCartItemTile(context, it as Map<String, dynamic>)),
                    const SizedBox(height: 14),

                    // Cold Chain Badge
                    if (isCold)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FreskaCustomerColors.coldChain.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(FreskaRadius.md),
                          border: Border.all(color: FreskaCustomerColors.coldChain.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.ac_unit_rounded, color: FreskaCustomerColors.coldChain, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Includes Temperature-Sensitive Cold-Chain Items (Transported at 4°C in insulated packaging)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: FreskaCustomerColors.coldChain),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Bill Details Card
                    FreskaCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bill Summary',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 14),
                          _buildBillRow('Item Subtotal', '₹$subtotal'),
                          _buildBillRow('Delivery Fee', deliveryFee == 0 ? 'FREE' : '₹$deliveryFee', isPositive: deliveryFee == 0),
                          _buildBillRow('GST & Fresh Packing (5%)', '₹$taxes'),
                          if (discount > 0)
                            _buildBillRow('Special Discount', '-₹$discount', isPositive: true),
                          const Divider(color: FreskaCustomerColors.bgSubtle, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('To Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                              Text('₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: FreskaCustomerColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Checkout Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: FreskaCustomerColors.bgSurface,
                  border: Border(top: BorderSide(color: FreskaCustomerColors.bgSubtle, width: 1.5)),
                  boxShadow: FreskaShadows.elevated,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: FreskaCustomerColors.textMuted, letterSpacing: 0.5)),
                          Text('₹$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      FreskaButton(
                        label: 'Proceed to Checkout →',
                        height: 48,
                        onPressed: () => context.push('/checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, Map<String, dynamic> item) {
    final itemId = item['id'] as int;
    final menuItem = item['menu_item'] as Map<String, dynamic>?;
    final name = menuItem != null ? menuItem['name'] as String : 'Item';
    final price = item['unit_price'];
    final quantity = item['quantity'] as int;
    final itemTotal = (double.tryParse(price.toString()) ?? 0.0) * quantity;

    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text('₹$price each • Total ₹$itemTotal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: FreskaCustomerColors.bgElevated,
              borderRadius: BorderRadius.circular(FreskaRadius.sm),
              border: Border.all(color: FreskaCustomerColors.primary, width: 1.0),
            ),
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 34),
                  icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                  onPressed: () {
                    context.read<CustomerCartBloc>().add(
                          UpdateCartItemQuantityEvent(itemId: itemId, quantity: quantity - 1),
                        );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('$quantity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 34),
                  icon: const Icon(Icons.add, size: 16, color: FreskaCustomerColors.primary),
                  onPressed: () {
                    context.read<CustomerCartBloc>().add(
                          UpdateCartItemQuantityEvent(itemId: itemId, quantity: quantity + 1),
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: FreskaCustomerColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isPositive ? FreskaCustomerColors.statusSuccess : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
