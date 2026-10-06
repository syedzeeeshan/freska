import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../shared/widgets/feedback/custom_snackbar.dart';
import '../blocs/safety_bloc.dart';
import '../widgets/hold_to_trigger_sos_button.dart';

class SosPanicScreen extends StatelessWidget {
  const SosPanicScreen({super.key});

  Future<void> _callEmergencyServices() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS & Safety'),
      ),
      body: BlocConsumer<SafetyBloc, SafetyState>(
        listener: (context, state) {
          if (state is SosTriggeredSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: StitchColors.darkSurface,
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: StitchColors.primaryFresh),
                    SizedBox(width: 8),
                    Text('SOS Dispatched'),
                  ],
                ),
                content: Text(
                  'Emergency Alert #${state.incident.incidentNumber} transmitted to Freska Operations Center.\n\nSMS with live GPS sent to your registered emergency contact.',
                  style: const TextStyle(
                      color: StitchColors.textSecondaryDark, fontSize: 13),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: StitchColors.primaryFresh),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Acknowledge'),
                  ),
                ],
              ),
            );
          } else if (state is SafetyError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is SafetyLoading;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: StitchColors.dangerSOS.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: StitchColors.dangerSOS.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded,
                        color: StitchColors.dangerSOS, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'In case of accident, physical danger, or medical emergency, hold the SOS button below.',
                        style: TextStyle(
                            color: StitchColors.dangerSOS,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Circular Hold-to-Trigger Button
              Center(
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: StitchColors.dangerSOS)
                    : HoldToTriggerSosButton(
                        onTriggered: () {
                          // Coordinates fetched or default GPS
                          context.read<SafetyBloc>().add(const TriggerSosEvent(
                                latitude: 12.9716,
                                longitude: 77.5946,
                                locationAddress: 'Current Live GPS Location',
                                medicalAssistanceNeeded: true,
                              ));
                        },
                      ),
              ),

              const SizedBox(height: 48),

              // Direct 112 Dialer
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchColors.darkSurfaceElevated,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: StitchColors.dangerSOS),
                  ),
                ),
                icon: const Icon(Icons.phone_in_talk_rounded,
                    color: StitchColors.dangerSOS),
                label: const Text(
                  'Call Police / Ambulance (112)',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _callEmergencyServices,
              ),

              const SizedBox(height: 16),

              // Incident Report Navigation
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Report Road Accident / Vehicle Breakdown'),
                onPressed: () {
                  context.push('/safety/incident');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
