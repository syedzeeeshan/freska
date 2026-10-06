import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../blocs/support_bloc.dart';

class SupportHubScreen extends StatefulWidget {
  const SupportHubScreen({super.key});

  @override
  State<SupportHubScreen> createState() => _SupportHubScreenState();
}

class _SupportHubScreenState extends State<SupportHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(const LoadTicketsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Support Center')),
      body: BlocBuilder<SupportBloc, SupportState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Support Categories
              const Text(
                'How can we help you?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      'Payment & Payout',
                      Icons.account_balance_wallet,
                      'payment_payout_issue',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      'Store Pickup',
                      Icons.storefront,
                      'vendor_pickup_issue',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      'Customer Issue',
                      Icons.person_pin_circle,
                      'customer_issue',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      'Technical / App',
                      Icons.phone_android,
                      'app_technical_issue',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Support Tickets',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        context.read<SupportBloc>().add(const LoadTicketsEvent()),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (state is SupportLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator()))
              else if (state is TicketsLoaded)
                if (state.tickets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No support tickets logged. Everything looks good!',
                        style: TextStyle(color: StitchColors.textSecondaryDark),
                      ),
                    ),
                  )
                else
                  ...state.tickets.map((t) {
                    final isOpen =
                        t.status == 'open' || t.status == 'in_progress';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(t.subject,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '#${t.ticketNumber} • ${t.createdAt.substring(0, 10)}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOpen
                                ? StitchColors.accentGold.withValues(alpha: 0.15)
                                : StitchColors.primaryFresh.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t.status.toUpperCase(),
                            style: TextStyle(
                              color: isOpen
                                  ? StitchColors.accentGold
                                  : StitchColors.primaryFreshLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              else if (state is SupportError)
                Center(
                  child: Text(state.message,
                      style: const TextStyle(color: StitchColors.dangerSOS)),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: StitchPrimaryButton(
          text: 'Raise New Support Ticket',
          onPressed: () => context.push('/support/create'),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, String categoryKey) {
    return InkWell(
      onTap: () {
        context.push('/support/create',
            extra: {'category': categoryKey});
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StitchColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StitchColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: StitchColors.primaryFresh, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
