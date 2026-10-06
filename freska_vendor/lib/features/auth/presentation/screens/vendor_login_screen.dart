import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_badge.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import '../bloc/vendor_auth_bloc.dart';

class VendorLoginScreen extends StatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9876500001');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty || raw.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit registered vendor mobile number.')),
      );
      return;
    }

    final phone = raw.startsWith('+') ? raw : '+91$raw';
    context.read<VendorAuthBloc>().add(SendVendorOtpEvent(phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreskaVendorColors.bgDarkest,
      body: BlocConsumer<VendorAuthBloc, VendorAuthState>(
        listener: (context, state) {
          if (state is VendorOtpSentState) {
            context.push('/otp', extra: state.phone);
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Brand Hero Header
                  FreskaVendorCard(
                    hasGlow: true,
                    glowColor: FreskaVendorColors.primary,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB74D), Color(0xFFFF9100)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(FreskaRadius.md),
                            boxShadow: FreskaShadows.amberGlow,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FRESKA',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              FreskaVendorBadge(
                                label: 'MERCHANT TERMINAL',
                                variant: FreskaVendorBadgeVariant.primary,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Title Section
                  const Text(
                    'Manager Sign In',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your registered merchant mobile number to access real-time dispatch, kitchen KDS, and stock.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: FreskaVendorColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Phone Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: FreskaVendorColors.bgSurface,
                      borderRadius: BorderRadius.circular(FreskaRadius.md),
                      border: Border.all(color: FreskaVendorColors.bgSubtle, width: 1.5),
                      boxShadow: FreskaShadows.soft,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: FreskaVendorColors.bgElevated,
                            borderRadius: BorderRadius.circular(FreskaRadius.sm),
                            border: Border.all(color: FreskaVendorColors.bgSubtle),
                          ),
                          child: const Text(
                            '🇮🇳 +91',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: '98765 00001',
                              hintStyle: TextStyle(color: FreskaVendorColors.textMuted, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Send OTP Button
                  FreskaVendorButton(
                    label: 'Send Merchant OTP →',
                    isLoading: isLoading,
                    onPressed: _sendOtp,
                    width: double.infinity,
                    height: 52,
                  ),
                  const SizedBox(height: 36),

                  // Ambient Features Info Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: FreskaVendorColors.bgElevated,
                      borderRadius: BorderRadius.circular(FreskaRadius.md),
                      border: Border.all(color: FreskaVendorColors.bgSubtle),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: FreskaVendorColors.primary, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant Dispatch Radar',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(
                                'Auto rider assignment with cold-chain sensor tags',
                                style: TextStyle(fontSize: 11, color: FreskaVendorColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'Store ID: FSK-HUB-01 • Production Terminal v1.0',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FreskaVendorColors.textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
