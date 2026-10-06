import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/components/freska_vendor_states.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import '../bloc/vendor_menu_bloc.dart';

class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({super.key});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VendorMenuBloc>().add(LoadVendorMenuItemsEvent());
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
        title: const Text('Menu & Stock Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: FreskaVendorColors.primary, size: 26),
            onPressed: () => context.push('/menu/create'),
          ),
        ],
      ),
      body: BlocBuilder<VendorMenuBloc, VendorMenuState>(
        builder: (context, state) {
          if (state is VendorMenuLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary));
          }

          if (state is VendorMenuError) {
            return FreskaVendorErrorState(
              message: state.message,
              onRetry: () => context.read<VendorMenuBloc>().add(LoadVendorMenuItemsEvent()),
            );
          }

          if (state is! VendorMenuLoaded) {
            return const SizedBox.shrink();
          }

          final items = state.items;

          if (items.isEmpty) {
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
                    child: const Icon(Icons.restaurant_menu_rounded, size: 48, color: FreskaVendorColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('No items in menu catalog', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  FreskaVendorButton(
                    label: '+ Add First Menu Item',
                    onPressed: () => context.push('/menu/create'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: FreskaVendorColors.primary,
            backgroundColor: FreskaVendorColors.bgElevated,
            onRefresh: () async {
              context.read<VendorMenuBloc>().add(LoadVendorMenuItemsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildMenuItemTile(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItemTile(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final name = item['name'] as String? ?? 'Item';
    final desc = item['description'] as String? ?? '';
    final price = item['price'];
    final discountPrice = item['discount_price'];
    final isAvailable = item['is_available'] == true;
    final isCold = item['is_cold_chain'] == true;

    return FreskaVendorCard(
      padding: const EdgeInsets.all(16),
      border: BorderSide(
        color: isAvailable ? FreskaVendorColors.bgSubtle : FreskaVendorColors.statusError.withValues(alpha: 0.35),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCold
                  ? FreskaVendorColors.coldChain.withValues(alpha: 0.12)
                  : FreskaVendorColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(FreskaRadius.md),
              border: Border.all(
                color: isCold
                    ? FreskaVendorColors.coldChain.withValues(alpha: 0.3)
                    : FreskaVendorColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              isCold ? Icons.ac_unit_rounded : Icons.eco_rounded,
              color: isCold ? FreskaVendorColors.coldChain : FreskaVendorColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${discountPrice ?? price}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: FreskaVendorColors.primary),
                    ),
                    if (discountPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹$price',
                        style: const TextStyle(fontSize: 12, color: FreskaVendorColors.textMuted, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                    if (isCold) ...[
                      const SizedBox(width: 8),
                      const FreskaVendorBadge(
                        label: '4°C',
                        variant: FreskaVendorBadgeVariant.coldChain,
                        fontSize: 9,
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    ],
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: FreskaVendorColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Instant Availability Toggle
          Column(
            children: [
              Switch(
                value: isAvailable,
                activeThumbColor: FreskaVendorColors.secondary,
                inactiveTrackColor: FreskaVendorColors.bgElevated,
                onChanged: (val) {
                  context.read<VendorMenuBloc>().add(ToggleItemAvailabilityEvent(id));
                },
              ),
              Text(
                isAvailable ? 'IN STOCK' : 'OUT OF STOCK',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: isAvailable ? FreskaVendorColors.secondary : FreskaVendorColors.statusError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
