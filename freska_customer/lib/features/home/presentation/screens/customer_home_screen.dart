import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/freska_badge.dart';
import '../../../../core/components/freska_card.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/voice/customer_voice_modal.dart';
import '../../../../core/services/voice/voice_intent_engine.dart';
import '../../../../core/services/voice/voice_service.dart';
import '../../../../core/theme/customer_theme.dart';
import '../bloc/home_bloc.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 1) {
      context.push('/search');
    } else if (index == 2) {
      context.push('/orders');
    } else if (index == 3) {
      context.push('/cart');
    } else if (index == 4) {
      context.push('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FreskaRadius.pill),
          boxShadow: FreskaShadows.primaryGlow,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: FreskaCustomerColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          icon: const Icon(Icons.mic_rounded, size: 22),
          label: const Text(
            'Voice AI',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.3),
          ),
          onPressed: () {
            CustomerVoiceModal.show(
              context,
              intentEngine: sl<CustomerVoiceIntentEngine>(),
              voiceService: sl<VoiceService>(),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: FreskaCustomerColors.bgSurface,
          border: Border(top: BorderSide(color: FreskaCustomerColors.bgSubtle, width: 1.0)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: FreskaCustomerColors.primary.withValues(alpha: 0.18),
          onDestinationSelected: _onBottomNavTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: FreskaCustomerColors.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: FreskaCustomerColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded, color: FreskaCustomerColors.textSecondary),
              selectedIcon: Icon(Icons.search_rounded, color: FreskaCustomerColors.primary),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: FreskaCustomerColors.textSecondary),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: FreskaCustomerColors.primary),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined, color: FreskaCustomerColors.textSecondary),
              selectedIcon: Icon(Icons.shopping_bag_rounded, color: FreskaCustomerColors.primary),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: FreskaCustomerColors.textSecondary),
              selectedIcon: Icon(Icons.person_rounded, color: FreskaCustomerColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: FreskaCustomerColors.primary,
          onRefresh: () async {
            context.read<HomeBloc>().add(const LoadHomeDataEvent());
          },
          child: CustomScrollView(
            slivers: [
              // Header & Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Delivery Capsule
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FreskaCustomerColors.primary.withValues(alpha: 0.25),
                                  FreskaCustomerColors.bgElevated,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(FreskaRadius.sm),
                              border: Border.all(color: FreskaCustomerColors.primary.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.location_on_rounded, color: FreskaCustomerColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => context.push('/addresses'),
                              borderRadius: BorderRadius.circular(FreskaRadius.sm),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Delivering to Home',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: FreskaCustomerColors.primary, size: 18),
                                    ],
                                  ),
                                  Text(
                                    '#412, 14th Main, HSR Layout Sector 1, Bengaluru',
                                    style: TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                            onPressed: () => context.push('/profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tactile Search Bar
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: FreskaCustomerColors.bgSurface,
                            borderRadius: BorderRadius.circular(FreskaRadius.md),
                            border: Border.all(color: FreskaCustomerColors.bgSubtle),
                            boxShadow: FreskaShadows.soft,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: FreskaCustomerColors.textMuted, size: 22),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Search "A2 farm milk", "strawberries", "sourdough"...',
                                  style: TextStyle(fontSize: 13, color: FreskaCustomerColors.textMuted),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: FreskaCustomerColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(FreskaRadius.xs),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.mic_rounded, color: FreskaCustomerColors.primary, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'VOICE',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: FreskaCustomerColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Cold Chain Trust Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FreskaCustomerColors.coldChain.withValues(alpha: 0.15),
                              FreskaCustomerColors.bgSurface,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(FreskaRadius.md),
                          border: Border.all(color: FreskaCustomerColors.coldChain.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.ac_unit_rounded, color: FreskaCustomerColors.coldChain, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '100% Cold-Chain Inspected • Farm Milk & Berries Delivered at 4°C',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: FreskaCustomerColors.coldChain,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Header & Horizontal Slider
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading || state is HomeInitial) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: FreskaCustomerColors.primary),
                        ),
                      ),
                    );
                  }

                  if (state is HomeError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: FreskaCustomerColors.bgSurface,
                            borderRadius: BorderRadius.circular(FreskaRadius.lg),
                            border: Border.all(color: FreskaCustomerColors.bgSubtle),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: FreskaCustomerColors.statusWarning.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.cloud_off_rounded, color: FreskaCustomerColors.statusWarning, size: 36),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Unable to Load Fresh Markets',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FreskaCustomerColors.primary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FreskaRadius.pill)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {
                                  context.read<HomeBloc>().add(const LoadHomeDataEvent());
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is! HomeLoaded) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  final categories = state.categories;
                  final vendors = state.vendors;

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Category Section Title
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Explore Fresh Categories',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            if (i == 0) {
                              final isAll = state.selectedCategory == null;
                              return _buildCategoryChip(
                                label: 'All Fresh',
                                icon: Icons.all_inclusive_rounded,
                                isSelected: isAll,
                                onTap: () {
                                  context.read<HomeBloc>().add(const LoadHomeDataEvent(selectedCategory: null));
                                },
                              );
                            }
                            final cat = categories[i - 1];
                            final isSelected = state.selectedCategory == cat['name'];
                            return _buildCategoryChip(
                              label: cat['name'] as String,
                              icon: Icons.eco_rounded,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<HomeBloc>().add(LoadHomeDataEvent(selectedCategory: cat['name']));
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hubs Section Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nearby Freska Hubs & Markets',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              '${vendors.length} Hubs Available',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Vendor Cards
                      ...vendors.map((v) => _buildVendorCard(context, v)),
                      const SizedBox(height: 80),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FreskaRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FreskaCustomerColors.primary : FreskaCustomerColors.bgSurface,
          borderRadius: BorderRadius.circular(FreskaRadius.pill),
          border: Border.all(
            color: isSelected ? FreskaCustomerColors.primary : FreskaCustomerColors.bgSubtle,
            width: 1.2,
          ),
          boxShadow: isSelected ? FreskaShadows.primaryGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black : FreskaCustomerColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, Map<String, dynamic> vendor) {
    final name = vendor['name'] as String? ?? 'Freska Store';
    final category = vendor['category'] as String? ?? 'Dairy & Fresh Produce';
    final rating = vendor['rating']?.toString() ?? '4.9';
    final time = vendor['estimated_delivery_time'] as String? ?? '20-30 min';
    final distance = vendor['distance_km'] != null ? '${vendor['distance_km']} km' : '2.4 km';
    final address = vendor['address'] as String? ?? 'Koramangala, Bengaluru';
    final imageUrl = (vendor['image_url'] as String?) ?? (vendor['banner_url'] as String?);
    final menuItems = (vendor['menu_items'] as List<dynamic>?) ?? [];

    return FreskaCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () => context.push('/vendor/${vendor['id']}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store banner image if available
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(FreskaRadius.md)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      height: 130,
                      color: FreskaCustomerColors.bgElevated,
                      child: const Center(
                        child: Icon(Icons.storefront_rounded, color: FreskaCustomerColors.primary, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FreskaBadge.rating(rating),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(FreskaRadius.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_rounded, color: FreskaCustomerColors.primary, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            distance,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            category,
                            style: const TextStyle(fontSize: 12, color: FreskaCustomerColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: const TextStyle(fontSize: 11, color: FreskaCustomerColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (imageUrl == null || imageUrl.isEmpty)
                      FreskaBadge.rating(rating),
                  ],
                ),

                if (menuItems.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: FreskaCustomerColors.bgSubtle, height: 1),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: menuItems.take(3).map((item) {
                      final itemMap = item is Map<String, dynamic> ? item : <String, dynamic>{};
                      final itemName = itemMap['name'] ?? 'Item';
                      final itemPrice = itemMap['price'] ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: FreskaCustomerColors.bgElevated,
                          borderRadius: BorderRadius.circular(FreskaRadius.xs),
                          border: Border.all(color: FreskaCustomerColors.bgSubtle),
                        ),
                        child: Text(
                          '$itemName • ₹$itemPrice',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
