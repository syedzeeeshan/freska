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

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _nameController = TextEditingController(text: 'Sunita Sharma');
  final _phoneController = TextEditingController(text: '9811223344');
  final _formKey = GlobalKey<FormState>();

  String _selectedRelation = 'Mother';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSaveEmergencyContact() {
    if (_formKey.currentState?.validate() ?? false) {
      final phoneWithCode = '+91${_phoneController.text.trim()}';
      context.read<ProfileCubit>().updateEmergencyContact(
            name: _nameController.text.trim(),
            phone: phoneWithCode,
            relation: _selectedRelation,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is EmergencyContactUpdated) {
          CustomSnackbar.showSuccess(context, 'Emergency contact saved');
          context.go('/onboarding/status');
        } else if (state is ProfileError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: StitchColors.background,
          appBar: AppBar(
            title: const Text('Emergency Contact'),
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
                    const OnboardingStepIndicator(currentStep: 4),
                    const SizedBox(height: 24),

                    // Safety Badge Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: StitchColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: StitchColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: StitchColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined,
                                color: StitchColors.primaryLight, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'In case of road accidents or SOS triggers, Freska emergency dispatch will automatically contact this person.',
                              style: StitchTypography.caption.copyWith(
                                  color: StitchColors.textPrimary,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Contact Name
                    StitchTextField(
                      controller: _nameController,
                      label: 'Emergency Contact Full Name',
                      hintText: 'e.g. Sunita Sharma',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Contact name is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Relationship
                    const Text('Relationship', style: StitchTypography.bodyEmphasis),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRelation,
                      dropdownColor: StitchColors.surface,
                      style:
                          StitchTypography.bodyEmphasis.copyWith(fontSize: 15),
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(
                            value: 'Mother', child: Text('Mother')),
                        DropdownMenuItem(
                            value: 'Father', child: Text('Father')),
                        DropdownMenuItem(
                            value: 'Spouse', child: Text('Spouse / Partner')),
                        DropdownMenuItem(
                            value: 'Sibling', child: Text('Brother / Sister')),
                        DropdownMenuItem(
                            value: 'Guardian', child: Text('Legal Guardian')),
                        DropdownMenuItem(
                            value: 'Friend', child: Text('Friend / Flatmate')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRelation = val);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Contact Phone
                    StitchTextField(
                      controller: _phoneController,
                      label: 'Emergency Mobile Number',
                      hintText: '98112 23344',
                      prefixText: '+91',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Contact phone number is required';
                        }
                        if (val.trim().length != 10) {
                          return 'Phone number must be exactly 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Finish Onboarding Button
                    StitchPrimaryButton(
                      text: 'Complete Onboarding',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: isLoading,
                      onPressed: _onSaveEmergencyContact,
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
