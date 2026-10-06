import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/di/injection.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import 'package:freska_vendor/features/auth/presentation/bloc/vendor_auth_bloc.dart';
import 'package:freska_vendor/features/profile/data/vendor_profile_repository.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final repo = sl<VendorProfileRepository>();
      final data = await repo.getProfile();
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FreskaVendorColors.bgDarkest,
        appBar: AppBar(title: const Text('Store Profile')),
        body: const Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary)),
      );
    }

    final storeName = _profile['name'] as String? ?? 'Koramangala Fresh Hub';
    final category = _profile['category'] as String? ?? 'Fresh Produce & Dairy';
    final address = _profile['address'] as String? ?? '80 Feet Rd, 4th Block, Koramangala, Bengaluru';
    final phone = _profile['phone'] as String? ?? '+91 98765 00001';
    final hours = _profile['opening_hours'] as String? ?? '06:00 AM - 11:00 PM';
    final rating = _profile['rating']?.toString() ?? '4.95';

    return Scaffold(
      backgroundColor: FreskaVendorColors.bgDarkest,
      appBar: AppBar(
        backgroundColor: FreskaVendorColors.bgDarkest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Store Profile & Terminal'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Store Info Card with Amber Glow
          FreskaVendorCard(
            hasGlow: true,
            glowColor: FreskaVendorColors.primary,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB74D), Color(0xFFFF9100)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(FreskaRadius.md),
                    boxShadow: FreskaShadows.amberGlow,
                  ),
                  child: const Center(
                    child: Icon(Icons.storefront_rounded, color: Colors.black, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storeName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaVendorColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: FreskaVendorColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(FreskaRadius.pill),
                              border: Border.all(color: FreskaVendorColors.primary.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: FreskaVendorColors.primary, size: 14),
                                const SizedBox(width: 4),
                                Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: FreskaVendorColors.primary)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const FreskaVendorBadge(
                            label: 'VERIFIED',
                            variant: FreskaVendorBadgeVariant.secondary,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Operational Details'),
          _buildInfoTile(icon: Icons.location_on_rounded, title: 'Store Location', subtitle: address),
          _buildInfoTile(icon: Icons.access_time_rounded, title: 'Operating Hours', subtitle: hours),
          _buildInfoTile(icon: Icons.phone_rounded, title: 'Store Dispatch Contact', subtitle: phone),
          _buildInfoTile(icon: Icons.ac_unit_rounded, title: 'Cold-Chain Inspection', subtitle: 'Certified 4°C Refrigeration Hub'),
          const SizedBox(height: 24),

          _buildSectionHeader('Partner Support & Account'),
          _buildActionTile(
            icon: Icons.support_agent_rounded,
            title: 'Freska Merchant Priority Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Priority Partner Hotline: +91 8000 888 222')),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.policy_rounded,
            title: 'Merchant Terms & Cold-Chain SLA',
            onTap: () {},
          ),
          const SizedBox(height: 28),

          // Log out button
          FreskaVendorButton(
            label: 'Log Out of Merchant Account',
            variant: FreskaVendorButtonVariant.danger,
            onPressed: () {
              context.read<VendorAuthBloc>().add(LogoutVendorEvent());
              context.go('/login');
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: FreskaVendorColors.textSecondary),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FreskaVendorCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FreskaVendorColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(FreskaRadius.sm),
              ),
              child: Icon(icon, color: FreskaVendorColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: FreskaVendorColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FreskaVendorCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FreskaVendorColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(FreskaRadius.sm),
              ),
              child: Icon(icon, color: FreskaVendorColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: FreskaVendorColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
