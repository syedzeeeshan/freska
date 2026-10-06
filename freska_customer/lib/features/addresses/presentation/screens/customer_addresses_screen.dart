import 'package:flutter/material.dart';
import '../../../../core/components/freska_badge.dart';
import '../../../../core/components/freska_card.dart';
import '../../../../core/theme/customer_theme.dart';

class CustomerAddressesScreen extends StatelessWidget {
  const CustomerAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Saved Addresses'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildAddressCard(
            label: 'Home',
            isDefault: true,
            address: '#412, 14th Main, HSR Layout Sector 1, Bengaluru 560102',
            recipient: 'Priya V. • +919988776655',
          ),
          _buildAddressCard(
            label: 'Work',
            isDefault: false,
            address: '4th Floor, WeWork Galaxy, 43 Residency Rd, Bengaluru 560025',
            recipient: 'Priya V. • +919988776655',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: FreskaCustomerColors.primary,
              side: const BorderSide(color: FreskaCustomerColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FreskaRadius.md),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: const Text('+ Add New Delivery Address', style: TextStyle(fontWeight: FontWeight.w800)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address selector ready')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required String label,
    required bool isDefault,
    required String address,
    required String recipient,
  }) {
    return FreskaCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                label == 'Home' ? Icons.home_rounded : Icons.work_rounded,
                color: FreskaCustomerColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              if (isDefault) ...[
                const SizedBox(width: 8),
                FreskaBadge.status('DEFAULT', color: FreskaCustomerColors.primary),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: FreskaCustomerColors.textMuted, size: 18),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(address, style: const TextStyle(fontSize: 13, color: FreskaCustomerColors.textSecondary, height: 1.3)),
          const SizedBox(height: 4),
          Text(recipient, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaCustomerColors.textMuted)),
        ],
      ),
    );
  }
}
