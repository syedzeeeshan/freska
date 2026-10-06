import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/feedback/custom_snackbar.dart';
import '../blocs/cod_bloc.dart';
import '../widgets/cash_in_hand_meter.dart';

class CodManagementScreen extends StatefulWidget {
  const CodManagementScreen({super.key});

  @override
  State<CodManagementScreen> createState() => _CodManagementScreenState();
}

class _CodManagementScreenState extends State<CodManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CodBloc>().add(const LoadCodSummaryEvent());
  }

  void _showDepositModal(double currentCash) {
    final amountCtrl = TextEditingController(
        text: currentCash > 0 ? currentCash.toStringAsFixed(0) : '');
    final refCtrl = TextEditingController();
    String method = 'bank_cdm';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Remit Cash Collection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount to Remit (₹)',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Handover Method'),
                items: const [
                  DropdownMenuItem(
                      value: 'bank_cdm',
                      child: Text('Bank CDM (Cash Deposit Machine)')),
                  DropdownMenuItem(
                      value: 'hub_deposit', child: Text('Hub Cashier Deposit')),
                  DropdownMenuItem(
                      value: 'upi_clawback',
                      child: Text('UPI Instant Settlement')),
                ],
                onChanged: (v) => method = v ?? 'bank_cdm',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Transaction UTR / CDM Slip No.',
                ),
              ),
              const SizedBox(height: 24),
              StitchPrimaryButton(
                text: 'Submit Remittance',
                onPressed: () {
                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (amt <= 0) {
                    CustomSnackbar.showError(context, 'Enter a valid amount.');
                    return;
                  }
                  Navigator.pop(ctx);
                  context.read<CodBloc>().add(SubmitRemittanceEvent(
                        amount: amt,
                        method: method,
                        reference: refCtrl.text.trim().isNotEmpty
                            ? refCtrl.text.trim()
                            : null,
                      ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash on Delivery Ledger')),
      body: BlocConsumer<CodBloc, CodState>(
        listener: (context, state) {
          if (state is CodRemittanceSuccess) {
            CustomSnackbar.showSuccess(
                context, 'Cash remittance submitted for verification.');
          } else if (state is CodError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CodLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CodLoaded) {
            final s = state.summary;
            final orders = state.pendingOrders;

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<CodBloc>().add(const LoadCodSummaryEvent()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CashInHandMeter(
                    currentAmount: s.currentCashInHand,
                    maxLimit: s.maxCashLimit,
                  ),
                  const SizedBox(height: 20),
                  if (s.isBlockedFromAssignments)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: StitchColors.dangerSOS.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StitchColors.dangerSOS),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: StitchColors.dangerSOS),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cash in hand limit reached! Remit cash immediately to receive new order assignments.',
                              style: TextStyle(
                                  color: StitchColors.dangerSOS, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  StitchPrimaryButton(
                    text: 'Remit / Handover Cash',
                    onPressed: s.currentCashInHand > 0
                        ? () => _showDepositModal(s.currentCashInHand)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pending Cash Orders',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No pending COD collections. All cash settled!',
                          style:
                              TextStyle(color: StitchColors.textSecondaryDark),
                        ),
                      ),
                    )
                  else
                    ...orders.map((o) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(o['order_number'] ?? 'Order'),
                          subtitle: Text(
                              'Vendor: ${o['vendor_name'] ?? 'Freska Hub'}'),
                          trailing: Text(
                            '₹${(o['amount'] as num).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: StitchColors.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          }

          if (state is CodError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: StitchColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: StitchColors.textPrimary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: StitchColors.primary),
                      onPressed: () => context.read<CodBloc>().add(const LoadCodSummaryEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
