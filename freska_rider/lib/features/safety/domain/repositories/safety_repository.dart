import 'dart:io';
import '../entities/incident_entity.dart';

abstract class SafetyRepository {
  Future<IncidentEntity> triggerSos({
    required double latitude,
    required double longitude,
    String? locationAddress,
    bool medicalAssistanceNeeded = false,
    int? orderId,
  });

  Future<IncidentEntity> reportIncident({
    required String type,
    required double latitude,
    required double longitude,
    String? description,
    String? locationAddress,
    bool medicalAssistanceNeeded = false,
    List<File> photos = const [],
  });

  Future<Map<String, dynamic>> getInsuranceDetails();
}
