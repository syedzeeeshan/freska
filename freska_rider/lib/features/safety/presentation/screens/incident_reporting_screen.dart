import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/feedback/custom_snackbar.dart';
import '../../../../shared/widgets/inputs/stitch_text_field.dart';
import '../blocs/safety_bloc.dart';

class IncidentReportingScreen extends StatefulWidget {
  const IncidentReportingScreen({super.key});

  @override
  State<IncidentReportingScreen> createState() =>
      _IncidentReportingScreenState();
}

class _IncidentReportingScreenState extends State<IncidentReportingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _selectedType = 'road_accident';
  bool _medicalNeeded = false;
  final List<File> _photos = [];
  final _picker = ImagePicker();

  Future<void> _capturePhoto() async {
    if (_photos.length >= 5) {
      CustomSnackbar.showError(context, 'Maximum 5 photos allowed.');
      return;
    }

    final picked = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 1920, imageQuality: 80);
    if (picked != null) {
      setState(() => _photos.add(File(picked.path)));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<SafetyBloc>().add(ReportIncidentEvent(
          type: _selectedType,
          latitude: 12.9716,
          longitude: 77.5946,
          description: _descCtrl.text.trim(),
          locationAddress: _locationCtrl.text.trim(),
          medicalAssistanceNeeded: _medicalNeeded,
          photos: _photos,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident / Breakdown')),
      body: BlocConsumer<SafetyBloc, SafetyState>(
        listener: (context, state) {
          if (state is IncidentReportedSuccess) {
            CustomSnackbar.showSuccess(context,
                'Incident #${state.incident.incidentNumber} submitted.');
            Navigator.pop(context);
          } else if (state is SafetyError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is SafetyLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration:
                      const InputDecoration(labelText: 'Incident Category'),
                  items: const [
                    DropdownMenuItem(
                        value: 'road_accident',
                        child: Text('Road Accident / Collision')),
                    DropdownMenuItem(
                        value: 'vehicle_breakdown',
                        child: Text('Vehicle Breakdown / Puncture')),
                    DropdownMenuItem(
                        value: 'customer_harassment',
                        child: Text('Customer / Public Harassment')),
                    DropdownMenuItem(
                        value: 'dog_bite',
                        child: Text('Animal / Dog Bite Incident')),
                    DropdownMenuItem(
                        value: 'weather_hazard',
                        child: Text('Severe Weather / Flood Inaccessibility')),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedType = v ?? 'road_accident'),
                ),
                const SizedBox(height: 16),
                StitchTextField(
                  controller: _locationCtrl,
                  labelText: 'Location / Landmark Address',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                StitchTextField(
                  controller: _descCtrl,
                  labelText: 'Description of what happened',
                  maxLines: 4,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Immediate Medical Assistance Needed'),
                  subtitle: const Text(
                      'Ambulance dispatch & operations team escalation'),
                  value: _medicalNeeded,
                  activeThumbColor: StitchColors.dangerSOS,
                  onChanged: (val) => setState(() => _medicalNeeded = val),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Photos Evidence (Vehicle damage, scene)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._photos.map((f) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(f,
                                  width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () => setState(() => _photos.remove(f)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )),
                    if (_photos.length < 5)
                      InkWell(
                        onTap: _capturePhoto,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: StitchColors.darkSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: StitchColors.darkBorder),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  color: StitchColors.primaryFresh),
                              SizedBox(height: 4),
                              Text('Add Photo',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: StitchColors.textSecondaryDark)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                StitchPrimaryButton(
                  text: 'Submit Incident Report',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
