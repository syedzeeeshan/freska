import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_customer/core/components/freska_button.dart';
import 'package:freska_customer/core/components/freska_card.dart';
import 'package:freska_customer/core/di/injection.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';
import 'package:freska_customer/features/home/data/discovery_repository.dart';

class CustomerSearchScreen extends StatefulWidget {
  final String? initialQuery;
  const CustomerSearchScreen({super.key, this.initialQuery});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  late final TextEditingController _searchController;
  bool _isLoading = false;
  List<dynamic> _vendors = [];
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _vendors = [];
        _items = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = sl<DiscoveryRepository>();
      final results = await repo.search(q);
      setState(() {
        _vendors = results['vendors'] as List<dynamic>? ?? [];
        _items = results['items'] as List<dynamic>? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: FreskaCustomerColors.bgSurface,
              borderRadius: BorderRadius.circular(FreskaRadius.md),
              border: Border.all(color: FreskaCustomerColors.bgSubtle),
              boxShadow: FreskaShadows.soft,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: widget.initialQuery == null,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search food, fruits, milk, groceries...',
                hintStyle: const TextStyle(fontSize: 13, color: FreskaCustomerColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: FreskaCustomerColors.primary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: FreskaCustomerColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) {
                _performSearch(val);
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FreskaCustomerColors.primary))
          : _searchController.text.trim().isEmpty
              ? _buildRecentSearches()
              : _buildSearchResults(),
    );
  }

  Widget _buildRecentSearches() {
    final suggestions = [
      'Organic A2 Farm Milk',
      'Sweet Strawberries',
      'Greek Yogurt',
      'Country Sourdough',
      'Cold Brew Coffee',
      'Hass Avocado',
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Farm Fresh Searches',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((item) {
              return InkWell(
                borderRadius: BorderRadius.circular(FreskaRadius.pill),
                onTap: () {
                  _searchController.text = item;
                  _performSearch(item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: FreskaCustomerColors.bgSurface,
                    borderRadius: BorderRadius.circular(FreskaRadius.pill),
                    border: Border.all(color: FreskaCustomerColors.bgSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 14, color: FreskaCustomerColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        item,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_vendors.isEmpty && _items.isEmpty) {
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
              child: Icon(Icons.search_off_rounded, color: FreskaCustomerColors.textMuted.withValues(alpha: 0.6), size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'No items found matching "${_searchController.text}"',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching for strawberries, milk, sourdough, or yogurt',
              style: TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        if (_items.isNotEmpty) ...[
          Text(
            'Fresh Items (${_items.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 10),
          ..._items.map((item) => _buildItemResultTile(item)),
          const SizedBox(height: 20),
        ],
        if (_vendors.isNotEmpty) ...[
          Text(
            'Freska Stores & Hubs (${_vendors.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 10),
          ..._vendors.map((v) => _buildVendorResultTile(v)),
        ],
      ],
    );
  }

  Widget _buildItemResultTile(dynamic item) {
    final name = item['name'] as String? ?? 'Item';
    final price = item['discount_price'] ?? item['price'];
    final desc = item['description'] as String? ?? '';
    final isCold = item['is_cold_chain'] == true;
    final vendor = item['vendor'] as Map<String, dynamic>?;

    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [FreskaCustomerColors.bgElevated, FreskaCustomerColors.bgSurface],
              ),
              borderRadius: BorderRadius.circular(FreskaRadius.sm),
              border: Border.all(color: FreskaCustomerColors.bgSubtle),
            ),
            child: Icon(
              isCold ? Icons.ac_unit_rounded : Icons.eco_rounded,
              color: isCold ? FreskaCustomerColors.coldChain : FreskaCustomerColors.primary,
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                if (vendor != null)
                  Text(
                    'Sold by ${vendor['name']}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary),
                  ),
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 11, color: FreskaCustomerColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  '₹$price',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: FreskaCustomerColors.primary),
                ),
              ],
            ),
          ),
          FreskaButton(
            label: 'View Store',
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            onPressed: () {
              if (item['vendor_id'] != null) {
                context.push('/vendor/${item['vendor_id']}');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVendorResultTile(dynamic v) {
    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/vendor/${v['id']}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FreskaCustomerColors.bgElevated,
              borderRadius: BorderRadius.circular(FreskaRadius.sm),
            ),
            child: const Icon(Icons.storefront_rounded, color: FreskaCustomerColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(v['category'] as String? ?? '', style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: FreskaCustomerColors.textMuted, size: 14),
        ],
      ),
    );
  }
}
