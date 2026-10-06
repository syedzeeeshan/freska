import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/inputs/stitch_text_field.dart';
import '../../../../shared/widgets/stepper/onboarding_step_indicator.dart';
import '../blocs/profile_cubit.dart';
import '../blocs/profile_state.dart';

import '../../../../shared/widgets/feedback/custom_snackbar.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _holderController = TextEditingController(text: 'Arjun Sharma');
  final _bankNameController = TextEditingController(text: 'HDFC Bank');
  final _accountNumberController =
      TextEditingController(text: '50100234918231');
  final _ifscController = TextEditingController(text: 'HDFC0001234');
  final _upiController = TextEditingController(text: 'arjun@okhdfcbank');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _holderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _onSaveBankDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileCubit>().updateBankDetails(
            accountHolder: _holderController.text.trim(),
            bankName: _bankNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            ifscCode: _ifscController.text.trim().toUpperCase(),
            upiId: _upiController.text.trim().isNotEmpty
                ? _upiController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is BankDetailsUpdated) {
          CustomSnackbar.showSuccess(context, 'Bank details updated successfully');
          context.push('/onboarding/emergency');
        } else if (state is ProfileError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: StitchColors.background,
          appBar: AppBar(
            title: const Text('Bank & Payout Setup'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnboardingStepIndicator(currentStep: 3),
                    const SizedBox(height: 24),

                    const Text('Weekly Direct Deposit Account',
                        style: StitchTypography.heading2),
                    const SizedBox(height: 6),
                    const Text(
                      'Your delivery fees, distance bonuses, customer tips, and surge incentives will be disbursed to this bank account.',
                      style: StitchTypography.body,
                    ),
                    const SizedBox(height: 28),

                    // Account Holder
                    StitchTextField(
                      controller: _holderController,
                      label: 'Account Holder Legal Name',
                      hintText: 'As per bank passbook / statement',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Account holder name is required'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Bank Name
                    StitchTextField(
                      controller: _bankNameController,
                      label: 'Bank Name',
                      hintText: 'e.g. HDFC Bank, State Bank of India',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Bank name is required'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Account Number
                    StitchTextField(
                      controller: _accountNumberController,
                      label: 'Bank Account Number',
                      hintText: 'Enter full account number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Account number is required';
                        }
                        if (val.trim().length < 9) {
                          return 'Account number must be at least 9 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // IFSC Code
                    StitchTextField(
                      controller: _ifscController,
                      label: 'Bank IFSC Code',
                      hintText: 'e.g. HDFC0001234',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'IFSC code is required';
                        }
                        final reg = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$',
                            caseSensitive: false);
                        if (!reg.hasMatch(val.trim())) {
                          return 'Please enter a valid 11-character IFSC code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // UPI ID
                    StitchTextField(
                      controller: _upiController,
                      label: 'UPI ID / VPA (Optional for Instant Payouts)',
                      hintText: 'e.g. yourname@okhdfcbank',
                    ),
                    const SizedBox(height: 36),

                    // Submit & Continue
                    StitchPrimaryButton(
                      text: 'Save & Continue',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: isLoading,
                      onPressed: _onSaveBankDetails,
                    ),
                    const SizedBox(height: 16),
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
