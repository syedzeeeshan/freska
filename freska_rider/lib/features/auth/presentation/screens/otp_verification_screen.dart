import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/feedback/custom_snackbar.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final int initialResendSeconds;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.initialResendSeconds = 60,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialResendSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    final otp = _otpController.text.trim();
    if (otp.length == 6) {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(phone: widget.phone, otp: otp),
          );
    }
  }

  void _onResend() {
    if (_remainingSeconds == 0) {
      context.read<AuthBloc>().add(SendOtpEvent(phone: widget.phone));
      setState(() => _remainingSeconds = 60);
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          if (state.user.isKycVerified) {
            context.go('/dashboard');
          } else {
            context.go('/onboarding/kyc');
          }
        } else if (state is AuthErrorState) {
          _otpController.clear();
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: StitchColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify Phone Number',
                    style: StitchTypography.heading1,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: StitchTypography.body,
                      children: [
                        const TextSpan(text: 'Enter the 6-digit code sent to '),
                        TextSpan(
                          text: widget.phone,
                          style: StitchTypography.bodyEmphasis.copyWith(
                            color: StitchColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 6-Digit Pin Input
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(14),
                      fieldHeight: 56,
                      fieldWidth: 46,
                      activeFillColor: StitchColors.surface,
                      inactiveFillColor: StitchColors.surface,
                      selectedFillColor: StitchColors.surfaceElevated,
                      activeColor: StitchColors.primary,
                      selectedColor: StitchColors.primaryLight,
                      inactiveColor: StitchColors.surfaceBorder,
                    ),
                    textStyle: StitchTypography.tabular(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    enableActiveFill: true,
                    onCompleted: (value) => _onVerify(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 24),

                  // Resend Timer Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _remainingSeconds > 0
                            ? 'Resend code in ${_remainingSeconds}s'
                            : "Didn't receive the code?",
                        style: StitchTypography.caption.copyWith(fontSize: 13),
                      ),
                      if (_remainingSeconds == 0) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _onResend,
                          child: Text(
                            'Resend',
                            style: StitchTypography.bodyEmphasis.copyWith(
                              color: StitchColors.primaryLight,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Verify Button
                  StitchPrimaryButton(
                    text: 'Verify & Continue',
                    isLoading: isLoading,
                    onPressed: _onVerify,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
