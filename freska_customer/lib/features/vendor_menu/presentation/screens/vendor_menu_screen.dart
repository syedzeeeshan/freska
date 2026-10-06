import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_customer/core/components/freska_badge.dart';
import 'package:freska_customer/core/components/freska_button.dart';
import 'package:freska_customer/core/components/freska_card.dart';
import 'package:freska_customer/core/components/freska_stepper.dart';
import 'package:freska_customer/core/di/injection.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';
import 'package:freska_customer/features/cart/data/cart_repository.dart';
import 'package:freska_customer/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:freska_customer/features/vendor_menu/presentation/bloc/vendor_menu_bloc.dart';

class VendorMenuScreen extends StatefulWidget {
  final int vendorId;
  const VendorMenuScreen({super.key, required this.vendorId});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  final Map<int, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    context.read<VendorMenuBloc>().add(LoadVendorMenuEvent(widget.vendorId));
  }

  void _addItemToCart(Map<String, dynamic> item) async {
    final itemId = item['id'] as int;
    final current = _itemQuantities[itemId] ?? 0;
    setState(() {
      _itemQuantities[itemId] = current + 1;
    });

    try {
      final cartRepo = sl<CustomerCartRepository>();
      await cartRepo.addItem(menuItemId: itemId, quantity: 1);
      if (mounted) {
        context.read<CustomerCartBloc>().add(LoadCartEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${item['name']} to cart'),
            duration: const Duration(milliseconds: 900),
            backgroundColor: FreskaCustomerColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  void _decrementItem(Map<String, dynamic> item) async {
    final itemId = item['id'] as int;
    final current = _itemQuantities[itemId] ?? 0;
    if (current <= 0) return;

    setState(() {
      _itemQuantities[itemId] = current - 1;
    });

    try {
      final cartRepo = sl<CustomerCartRepository>();
      await cartRepo.updateQuantity(itemId: itemId, quantity: current - 1);
      if (mounted) {
        context.read<CustomerCartBloc>().add(LoadCartEvent());
      }
    } catch (_) {}
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
        title: const Text('Store Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      bottomNavigationBar: _buildFloatingCartBar(),
      body: BlocBuilder<VendorMenuBloc, VendorMenuState>(
        builder: (context, state) {
          if (state is VendorMenuLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaCustomerColors.primary));
          }

          if (state is VendorMenuError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          }

          if (state is! VendorMenuLoaded) {
            return const SizedBox.shrink();
          }

          final vendor = state.vendor;
          final name = vendor['name'] as String? ?? 'Store';
          final category = vendor['category'] as String? ?? 'Fresh Food';
          final address = vendor['address'] as String? ?? '';
          final rating = vendor['rating']?.toString() ?? '4.9';
          final time = vendor['estimated_delivery_time'] as String? ?? '20-30 min';
          final menuItems = (vendor['menu_items'] as List<dynamic>?) ?? [];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Dimensional Store Header Card
              FreskaCard(
                hasGlow: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4),
                          ),
                        ),
                        FreskaBadge.rating(rating),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(address, style: const TextStyle(fontSize: 11, color: FreskaCustomerColors.textMuted)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: FreskaCustomerColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 16),
                        FreskaBadge.coldChain(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Fresh Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3),
                  ),
                  Text(
                    '${menuItems.length} items',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Menu items list
              ...menuItems.map((item) => _buildMenuItemCard(item as Map<String, dynamic>)),
              const SizedBox(height: 90),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    final itemId = item['id'] as int;
    final name = item['name'] as String? ?? 'Item';
    final desc = item['description'] as String? ?? '';
    final price = item['price'];
    final discountPrice = item['discount_price'];
    final isCold = item['is_cold_chain'] == true;
    final imageUrl = item['image_url'] as String?;
    final qty = _itemQuantities[itemId] ?? 0;

    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 1.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Center(
                        child: CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      ),
                    ),
                    if (isCold) ...[
                      const SizedBox(width: 8),
                      FreskaBadge.coldChain(),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${discountPrice ?? price}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: FreskaCustomerColors.primary),
                    ),
                    if (discountPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '₹$price',
                        style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textMuted, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Food Image with overlaid Stepper
          Column(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(FreskaRadius.md),
                  child: Image.network(
                    imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      width: 84,
                      height: 84,
                      color: FreskaCustomerColors.bgElevated,
                      child: const Icon(Icons.fastfood_rounded, color: FreskaCustomerColors.primary, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              FreskaQuantityStepper(
                quantity: qty,
                onIncrement: () => _addItemToCart(item),
                onDecrement: () => _decrementItem(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingCartBar() {
    final totalAdded = _itemQuantities.values.fold(0, (sum, q) => sum + q);
    if (totalAdded == 0) return null;

    return Container(
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
                Text(
                  '$totalAdded ITEMS IN CART',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: FreskaCustomerColors.primary, letterSpacing: 0.5),
                ),
                const Text(
                  'Tap View Cart to checkout',
                  style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Spacer(),
            FreskaButton(
              label: 'View Cart →',
              height: 44,
              onPressed: () => context.push('/cart'),
            ),
          ],
        ),
      ),
    );
  }
}
