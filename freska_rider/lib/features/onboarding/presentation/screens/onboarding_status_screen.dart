import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../blocs/kyc_cubit.dart';
import '../blocs/kyc_state.dart';

class OnboardingStatusScreen extends StatefulWidget {
  const OnboardingStatusScreen({super.key});

  @override
  State<OnboardingStatusScreen> createState() => _OnboardingStatusScreenState();
}

class _OnboardingStatusScreenState extends State<OnboardingStatusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KycCubit>().checkKycStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      body: SafeArea(
        child: BlocConsumer<KycCubit, KycState>(
          listener: (context, state) {
            if (state is KycStatusLoaded && state.kyc.isVerified) {
              context.go('/dashboard');
            }
          },
          builder: (context, state) {
            final isLoading = state is KycLoading;
            final isVerified = state is KycStatusLoaded && state.kyc.isVerified;
            final isRejected = state is KycStatusLoaded && state.kyc.isRejected;
            final rejectionReason =
                (state is KycStatusLoaded) ? state.kyc.rejectionReason : null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Central Animated Status Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isVerified
                          ? StitchColors.primary.withValues(alpha: 0.2)
                          : isRejected
                              ? StitchColors.danger.withValues(alpha: 0.2)
                              : StitchColors.accentGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isVerified
                            ? StitchColors.primaryLight
                            : isRejected
                                ? StitchColors.danger
                                : StitchColors.accentGold,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      isVerified
                          ? Icons.check_circle_rounded
                          : isRejected
                              ? Icons.error_outline_rounded
                              : Icons.hourglass_top_rounded,
                      size: 48,
                      color: isVerified
                          ? StitchColors.primaryLight
                          : isRejected
                              ? StitchColors.danger
                              : StitchColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    isVerified
                        ? 'Verification Approved!'
                        : isRejected
                            ? 'Verification Rejected'
                            : 'Documents Under Review',
                    style: StitchTypography.heading1.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    isVerified
                        ? 'Congratulations! Your KYC credentials and vehicle profile have been verified. You are now authorized to accept delivery orders.'
                        : isRejected
                            ? (rejectionReason ??
                                'Document rejection. Please re-upload clear photos of your license and RC book.')
                            : 'Our operations compliance team is reviewing your vehicle registration and license credentials. Verification typically completes within 2–4 business hours.',
                    style: StitchTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),

                  if (isVerified)
                    StitchPrimaryButton(
                      text: 'Go to Rider Dashboard',
                      icon: Icons.electric_moped_rounded,
                      onPressed: () => context.go('/dashboard'),
                    )
                  else if (isRejected)
                    StitchPrimaryButton(
                      text: 'Re-upload Documents',
                      icon: Icons.refresh_rounded,
                      backgroundColor: StitchColors.danger,
                      onPressed: () => context.push('/onboarding/kyc'),
                    )
                  else
                    Column(
                      children: [
                        StitchPrimaryButton(
                          text: 'Check Verification Status',
                          icon: Icons.refresh_rounded,
                          isLoading: isLoading,
                          onPressed: () =>
                              context.read<KycCubit>().checkKycStatus(),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            'Switch Account / Log Out',
                            style: TextStyle(color: StitchColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
