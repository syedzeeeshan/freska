import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/freska_button.dart';
import '../../../../core/theme/customer_theme.dart';
import '../bloc/auth_bloc.dart';

class CustomerPhoneLoginScreen extends StatefulWidget {
  const CustomerPhoneLoginScreen({super.key});

  @override
  State<CustomerPhoneLoginScreen> createState() => _CustomerPhoneLoginScreenState();
}

class _CustomerPhoneLoginScreenState extends State<CustomerPhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9988776655');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _phoneController.text.trim();
    if (raw.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number.')),
      );
      return;
    }
    final formatted = raw.startsWith('+91') ? raw : '+91$raw';
    context.read<CustomerAuthBloc>().add(SendOtpEvent(formatted));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is CustomerOtpSentState) {
            context.push('/otp', extra: state.phone);
          } else if (state is CustomerAuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: FreskaCustomerColors.statusError,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CustomerAuthLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  // Tactile App Icon with Soft Glow
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FreskaCustomerColors.primary.withValues(alpha: 0.25),
                          FreskaCustomerColors.bgSurface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(FreskaRadius.xl),
                      border: Border.all(
                        color: FreskaCustomerColors.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: FreskaShadows.primaryGlow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        color: FreskaCustomerColors.primary,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Fresh Farm Deliveries,\nRight to Your Door.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Experience cold-chain certified organic dairy, farm fresh fruits, and artisan bakers.',
                    style: TextStyle(
                      fontSize: 14,
                      color: FreskaCustomerColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Phone Input Container with Tactile Border
                  const Text(
                    'Mobile Number',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FreskaCustomerColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: FreskaCustomerColors.bgSurface,
                      borderRadius: BorderRadius.circular(FreskaRadius.md),
                      border: Border.all(color: FreskaCustomerColors.bgSubtle),
                      boxShadow: FreskaShadows.soft,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: FreskaCustomerColors.bgElevated,
                            borderRadius: BorderRadius.circular(FreskaRadius.xs),
                          ),
                          child: const Text(
                            '🇮🇳 +91',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 24, color: FreskaCustomerColors.bgSubtle),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter 10-digit number',
                              hintStyle: TextStyle(color: FreskaCustomerColors.textMuted, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tactile Submit CTA
                  FreskaButton(
                    label: 'Continue with OTP →',
                    onPressed: _submit,
                    isLoading: isLoading,
                    width: double.infinity,
                    height: 52,
                  ),
                  const Spacer(flex: 2),

                  // Footer Security info
                  Center(
                    child: Text(
                      '🔒 Verified 256-Bit Encrypted Customer Gateway • Freska v1.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: FreskaCustomerColors.textMuted.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
