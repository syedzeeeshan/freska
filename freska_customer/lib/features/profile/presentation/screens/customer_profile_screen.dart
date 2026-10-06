import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_customer/core/components/freska_button.dart';
import 'package:freska_customer/core/components/freska_card.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';
import 'package:freska_customer/features/auth/presentation/bloc/auth_bloc.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User Card with Glowing Gradient Avatar
          FreskaCard(
            hasGlow: true,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FreskaCustomerColors.primary.withValues(alpha: 0.3),
                        FreskaCustomerColors.bgElevated,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: FreskaCustomerColors.primary, width: 1.5),
                    boxShadow: FreskaShadows.primaryGlow,
                  ),
                  child: const Center(
                    child: Text('PV', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: FreskaCustomerColors.primary)),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priya V.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('+91 99887 76655', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textSecondary)),
                      Text('priya.customer@freska.app', style: TextStyle(fontSize: 12, color: FreskaCustomerColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Preferences & Orders'),
          _buildSettingsTile(
            icon: Icons.receipt_long_rounded,
            title: 'My Past Orders',
            onTap: () => context.push('/orders'),
          ),
          _buildSettingsTile(
            icon: Icons.location_on_rounded,
            title: 'Saved Delivery Addresses',
            onTap: () => context.push('/addresses'),
          ),
          _buildSettingsTile(
            icon: Icons.shopping_bag_rounded,
            title: 'Shopping Cart',
            onTap: () => context.push('/cart'),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Help & Settings'),
          _buildSettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Freska 24/7 Support Hub',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support line: +91 8000 999 112')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notification Center',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications are up to date.')),
              );
            },
          ),
          const SizedBox(height: 24),

          // Logout Button
          FreskaButton(
            label: 'Log Out of Account',
            variant: FreskaButtonVariant.danger,
            onPressed: () {
              context.read<CustomerAuthBloc>().add(LogoutEvent());
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: FreskaCustomerColors.textSecondary, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: FreskaCustomerColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: FreskaCustomerColors.textMuted, size: 14),
        ],
      ),
    );
  }
}
