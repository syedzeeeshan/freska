import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/feedback/custom_snackbar.dart';
import '../../../../shared/widgets/inputs/stitch_text_field.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController(text: '9876543210');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      final raw = _phoneController.text.trim();
      final phoneWithCode = raw.startsWith('+')
          ? raw
          : raw.startsWith('91') && raw.length == 12
              ? '+$raw'
              : '+91$raw';
      context.read<AuthBloc>().add(SendOtpEvent(phone: phoneWithCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          context.push('/otp', extra: {
            'phone': state.phone,
            'resendInSeconds': state.resendInSeconds,
          });
        } else if (state is AuthErrorState) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: StitchColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header Brand Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: StitchColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: StitchColors.surfaceBorder),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: StitchColors.primaryLight,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Welcome to Freska',
                      style: StitchTypography.heading1,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your registered mobile number to receive a secure one-time verification code.',
                      style: StitchTypography.body,
                    ),
                    const SizedBox(height: 40),

                    // Phone Number Input
                    StitchTextField(
                      controller: _phoneController,
                      label: 'Mobile Phone Number',
                      hintText: '98765 43210',
                      prefixText: '+91',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your 10-digit mobile number';
                        }
                        if (val.trim().length != 10) {
                          return 'Mobile number must be exactly 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    StitchPrimaryButton(
                      text: 'Get Verification Code',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: isLoading,
                      onPressed: _onSendOtp,
                    ),
                    const SizedBox(height: 24),

                    // Terms Notice
                    const Center(
                      child: Text(
                        'By continuing, you agree to Freska Partner Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: StitchTypography.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
