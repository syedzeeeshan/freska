import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/inputs/stitch_text_field.dart';
import '../../../../shared/widgets/stepper/onboarding_step_indicator.dart';
import '../blocs/profile_cubit.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selfieFile;
  String _selectedVehicle = 'bike';
  String _selectedBloodGroup = 'O+';

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _selfieFile = File(picked.path));
      if (mounted) {
        context.read<ProfileCubit>().uploadPhoto(_selfieFile!);
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: StitchColors.primary,
              onPrimary: Colors.white,
              surface: StitchColors.surface,
              onSurface: StitchColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _onContinue() {
    if (_selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: StitchColors.danger,
          content: Text('Please capture a clear profile selfie to continue.'),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.push('/onboarding/kyc', extra: {
        'vehicle_type': _selectedVehicle,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: const Text('Rider Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingStepIndicator(currentStep: 1),
                const SizedBox(height: 28),

                // Selfie Avatar Picker with Camera Overlay
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickSelfie,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StitchColors.surface,
                            border: Border.all(
                              color: _selfieFile != null
                                  ? StitchColors.primaryLight
                                  : StitchColors.surfaceBorder,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _selfieFile != null
                              ? ClipOval(
                                  child: Image.file(_selfieFile!,
                                      fit: BoxFit.cover))
                              : const Icon(Icons.person_outline_rounded,
                                  size: 54, color: StitchColors.textMuted),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickSelfie,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: StitchColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _selfieFile != null
                        ? 'Tap to Retake Photo'
                        : 'Capture Live Profile Photo',
                    style: StitchTypography.caption.copyWith(
                      color: _selfieFile != null
                          ? StitchColors.primaryLight
                          : StitchColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name Input
                StitchTextField(
                  controller: _nameController,
                  label: 'Full Legal Name (as per Govt ID)',
                  hintText: 'e.g. Arjun Sharma',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Legal full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date of Birth Field
                GestureDetector(
                  onTap: _selectDateOfBirth,
                  child: AbsorbPointer(
                    child: StitchTextField(
                      controller: _dobController,
                      label: 'Date of Birth (Must be 18+)',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: const Icon(Icons.calendar_month_rounded,
                          color: StitchColors.textSecondary),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Date of birth is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Vehicle Type Dropdown
                const Text('Vehicle Type', style: StitchTypography.bodyEmphasis),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedVehicle,
                  dropdownColor: StitchColors.surface,
                  style: StitchTypography.bodyEmphasis.copyWith(fontSize: 15),
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(
                        value: 'bike', child: Text('Motorcycle (Petrol)')),
                    DropdownMenuItem(
                        value: 'scooter', child: Text('Scooter (Petrol)')),
                    DropdownMenuItem(
                        value: 'ev_two_wheeler',
                        child: Text('Electric Two-Wheeler (EV)')),
                    DropdownMenuItem(value: 'bicycle', child: Text('Bicycle')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVehicle = val);
                  },
                ),
                const SizedBox(height: 20),

                // Blood Group Dropdown (Crucial for SOS safety profile)
                const Text('Blood Group (for Emergency Services)',
                    style: StitchTypography.bodyEmphasis),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodGroup,
                  dropdownColor: StitchColors.surface,
                  style: StitchTypography.bodyEmphasis.copyWith(fontSize: 15),
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(
                        value: 'O+', child: Text('O Positive (O+)')),
                    DropdownMenuItem(
                        value: 'O-', child: Text('O Negative (O-)')),
                    DropdownMenuItem(
                        value: 'A+', child: Text('A Positive (A+)')),
                    DropdownMenuItem(
                        value: 'A-', child: Text('A Negative (A-)')),
                    DropdownMenuItem(
                        value: 'B+', child: Text('B Positive (B+)')),
                    DropdownMenuItem(
                        value: 'B-', child: Text('B Negative (B-)')),
                    DropdownMenuItem(
                        value: 'AB+', child: Text('AB Positive (AB+)')),
                    DropdownMenuItem(
                        value: 'AB-', child: Text('AB Negative (AB-)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBloodGroup = val);
                  },
                ),
                const SizedBox(height: 36),

                // Continue Button
                StitchPrimaryButton(
                  text: 'Continue to Documents',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _onContinue,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
