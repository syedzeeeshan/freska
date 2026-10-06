import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/components/freska_vendor_states.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import '../bloc/vendor_earnings_bloc.dart';

class VendorEarningsScreen extends StatefulWidget {
  const VendorEarningsScreen({super.key});

  @override
  State<VendorEarningsScreen> createState() => _VendorEarningsScreenState();
}

class _VendorEarningsScreenState extends State<VendorEarningsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VendorEarningsBloc>().add(LoadVendorEarningsEvent());
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
        title: const Text('Revenue & Financials'),
      ),
      body: BlocBuilder<VendorEarningsBloc, VendorEarningsState>(
        builder: (context, state) {
          if (state is VendorEarningsLoading) {
            return const Center(child: CircularProgressIndicator(color: FreskaVendorColors.primary));
          }

          if (state is VendorEarningsError) {
            return FreskaVendorErrorState(
              message: state.message,
              onRetry: () => context.read<VendorEarningsBloc>().add(LoadVendorEarningsEvent()),
            );
          }

          final data = state is VendorEarningsLoaded ? state.data : <String, dynamic>{};
          final today = data['today_revenue'] ?? '18,450.00';
          final weekly = data['weekly_revenue'] ?? '1,12,600.00';
          final monthly = data['monthly_revenue'] ?? '4,85,200.00';
          final pending = data['pending_payout'] ?? '42,100.00';
          final payouts = (data['recent_payouts'] as List<dynamic>?) ?? [];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Hero Balance Card with Amber Glow
              FreskaVendorCard(
                hasGlow: true,
                glowColor: FreskaVendorColors.primary,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL GROSS SALES TODAY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: FreskaVendorColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        FreskaVendorBadge(
                          label: 'LIVE SETTLEMENT',
                          variant: FreskaVendorBadgeVariant.secondary,
                          fontSize: 9,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹$today',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FreskaVendorColors.bgDarkest,
                        borderRadius: BorderRadius.circular(FreskaRadius.md),
                        border: Border.all(color: FreskaVendorColors.bgSubtle),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Next Direct Bank Payout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: FreskaVendorColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('₹$pending', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: FreskaVendorColors.coldChain)),
                              ],
                            ),
                          ),
                          const FreskaVendorBadge(
                            label: 'ACH ACTIVE',
                            variant: FreskaVendorBadgeVariant.coldChain,
                            icon: Icons.verified_rounded,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Aggregates Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile('This Week', '₹$weekly', Icons.calendar_view_week_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile('This Month', '₹$monthly', Icons.calendar_month_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Recent Payout Transfers
              const Text(
                'Recent Bank Direct Transfers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 12),
              if (payouts.isEmpty) ...[
                _buildPayoutTile('HDFC Bank •••• 4921', '₹38,500.00', 'Direct Settlement • 30 Sep 2026', true),
                _buildPayoutTile('HDFC Bank •••• 4921', '₹41,200.00', 'Direct Settlement • 23 Sep 2026', true),
                _buildPayoutTile('HDFC Bank •••• 4921', '₹39,800.00', 'Direct Settlement • 16 Sep 2026', true),
              ] else ...[
                ...payouts.map((p) => _buildPayoutTile(
                      p['account'] ?? 'HDFC Bank •••• 4921',
                      '₹${p['amount'] ?? '0.00'}',
                      '${p['status'] ?? 'Completed'} • ${p['date'] ?? ''}',
                      p['status'] == 'completed',
                    )),
              ],
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(String title, String amount, IconData icon) {
    return FreskaVendorCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FreskaVendorColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(FreskaRadius.sm),
            ),
            child: Icon(icon, color: FreskaVendorColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FreskaVendorColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutTile(String account, String amount, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FreskaVendorCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FreskaVendorColors.bgElevated,
                borderRadius: BorderRadius.circular(FreskaRadius.md),
                border: Border.all(color: FreskaVendorColors.bgSubtle),
              ),
              child: const Icon(Icons.account_balance_rounded, color: FreskaVendorColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: FreskaVendorColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: FreskaVendorColors.secondary)),
                const SizedBox(height: 2),
                const FreskaVendorBadge(
                  label: 'SUCCESS',
                  variant: FreskaVendorBadgeVariant.secondary,
                  fontSize: 9,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
