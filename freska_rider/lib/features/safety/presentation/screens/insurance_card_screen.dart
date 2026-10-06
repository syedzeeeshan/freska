import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../blocs/safety_bloc.dart';

class InsuranceCardScreen extends StatefulWidget {
  const InsuranceCardScreen({super.key});

  @override
  State<InsuranceCardScreen> createState() => _InsuranceCardScreenState();
}

class _InsuranceCardScreenState extends State<InsuranceCardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SafetyBloc>().add(const LoadInsuranceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Insurance Policy')),
      body: BlocBuilder<SafetyBloc, SafetyState>(
        builder: (context, state) {
          if (state is SafetyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InsuranceLoaded) {
            final ins = state.insurance;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Insurance Digital Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'FRESKA PARTNER CARE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVE COVER',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        ins['policy_number'] ?? 'FSK-GRP-2026',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coverage: ${ins['coverage_amount'] ?? '₹5,00,000'}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Underwriter: ${ins['provider'] ?? 'ICICI Lombard'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valid Until: ${ins['valid_until'] ?? '2027-03-31'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Policy Benefits',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildBenefitItem(
                    Icons.local_hospital,
                    '₹5,00,000 Accidental Medical Cover',
                    'Inpatient hospital expenses during active duty delivery trips.'),
                _buildBenefitItem(
                    Icons.family_restroom,
                    '₹10,00,000 Term Life Cover',
                    'Direct financial protection disbursed to registered next of kin.'),
                _buildBenefitItem(
                    Icons.headset_mic,
                    '24/7 Dedicated Claims Assistance',
                    'Helpline: ${ins['emergency_helpline'] ?? '1800-2666'}'),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StitchColors.darkBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: StitchColors.primaryFresh, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: StitchColors.textSecondaryDark, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
