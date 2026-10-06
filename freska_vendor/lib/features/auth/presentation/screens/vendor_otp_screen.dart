import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import '../bloc/vendor_auth_bloc.dart';

class VendorOtpScreen extends StatefulWidget {
  final String phone;
  const VendorOtpScreen({super.key, required this.phone});

  @override
  State<VendorOtpScreen> createState() => _VendorOtpScreenState();
}

class _VendorOtpScreenState extends State<VendorOtpScreen> {
  final TextEditingController _otpController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit verification OTP.')),
      );
      return;
    }

    context.read<VendorAuthBloc>().add(
          VerifyVendorOtpEvent(phone: widget.phone, otp: otp),
        );
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
        title: const Text('Verify Account'),
      ),
      body: BlocConsumer<VendorAuthBloc, VendorAuthState>(
        listener: (context, state) {
          if (state is VendorAuthenticatedState) {
            context.go('/dashboard');
          } else if (state is VendorAuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: FreskaVendorColors.statusError,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is VendorAuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FreskaVendorBadge(
                    label: 'SECURITY VERIFICATION',
                    variant: FreskaVendorBadgeVariant.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter 6-Digit Passcode',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: 'We sent a verification code to registered terminal mobile ',
                      style: const TextStyle(fontSize: 14, color: FreskaVendorColors.textSecondary, height: 1.4),
                      children: [
                        TextSpan(
                          text: widget.phone,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Card
                  FreskaVendorCard(
                    hasGlow: true,
                    glowColor: FreskaVendorColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      children: [
                        const Text(
                          'SECURITY TOKEN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: FreskaVendorColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: FreskaVendorColors.primary,
                            letterSpacing: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: '••••••',
                            hintStyle: TextStyle(
                              color: FreskaVendorColors.textMuted,
                              letterSpacing: 12,
                              fontSize: 28,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Verify Button
                  FreskaVendorButton(
                    label: 'Verify & Access Terminal →',
                    isLoading: isLoading,
                    onPressed: _verify,
                    width: double.infinity,
                    height: 52,
                  ),
                  const SizedBox(height: 24),

                  // Resend Action
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: FreskaVendorColors.primary),
                      onPressed: () {
                        context.read<VendorAuthBloc>().add(SendVendorOtpEvent(widget.phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verification code re-sent to phone.')),
                        );
                      },
                      label: const Text(
                        'Didn\'t receive code? Resend SMS',
                        style: TextStyle(
                          color: FreskaVendorColors.primary,
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
