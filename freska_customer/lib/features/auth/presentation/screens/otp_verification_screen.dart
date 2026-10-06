import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/freska_button.dart';
import '../../../../core/theme/customer_theme.dart';
import '../bloc/auth_bloc.dart';

class CustomerOtpScreen extends StatefulWidget {
  final String phone;
  const CustomerOtpScreen({super.key, required this.phone});

  @override
  State<CustomerOtpScreen> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends State<CustomerOtpScreen> {
  final TextEditingController _otpController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit verification code.')),
      );
      return;
    }
    context.read<CustomerAuthBloc>().add(
          VerifyOtpEvent(phone: widget.phone, otp: code),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaCustomerColors.bgDarkest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is CustomerAuthenticatedState) {
            context.go('/home');
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify Mobile OTP',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to ${widget.phone}',
                    style: const TextStyle(fontSize: 14, color: FreskaCustomerColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Tactile OTP Input Container
                  Container(
                    decoration: BoxDecoration(
                      color: FreskaCustomerColors.bgSurface,
                      borderRadius: BorderRadius.circular(FreskaRadius.md),
                      border: Border.all(
                        color: FreskaCustomerColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: FreskaShadows.soft,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: FreskaCustomerColors.primary,
                        letterSpacing: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: '••••••',
                        hintStyle: TextStyle(
                          color: FreskaCustomerColors.textMuted,
                          letterSpacing: 12,
                          fontSize: 24,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Verify CTA
                  FreskaButton(
                    label: 'Verify & Enter Freska →',
                    onPressed: _verify,
                    isLoading: isLoading,
                    width: double.infinity,
                    height: 52,
                  ),
                  const SizedBox(height: 20),

                  // Resend Action
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: FreskaCustomerColors.primary),
                      onPressed: () {
                        context.read<CustomerAuthBloc>().add(SendOtpEvent(widget.phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New OTP sent to your phone.')),
                        );
                      },
                      label: const Text(
                        'Didn\'t receive code? Resend OTP',
                        style: TextStyle(
                          color: FreskaCustomerColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
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
