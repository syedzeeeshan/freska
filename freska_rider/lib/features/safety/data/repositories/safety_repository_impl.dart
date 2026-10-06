import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/safety_repository.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  final ApiClient apiClient;

  SafetyRepositoryImpl({required this.apiClient});

  @override
  Future<IncidentEntity> triggerSos({
    required double latitude,
    required double longitude,
    String? locationAddress,
    bool medicalAssistanceNeeded = false,
    int? orderId,
  }) async {
    final response = await apiClient.post('/rider/safety/sos', data: {
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'medical_assistance_needed': medicalAssistanceNeeded,
      'order_id': orderId,
    });

    final data = response.data['data'] as Map<String, dynamic>;
    return IncidentEntity(
      id: data['id'] as int,
      incidentNumber: data['incident_number'] as String,
      type: data['type'] as String,
      latitude: ((data['latitude'] ?? 0.0) as num).toDouble(),
      longitude: ((data['longitude'] ?? 0.0) as num).toDouble(),
      locationAddress: data['location_address'] as String?,
      description: data['description'] as String?,
      medicalAssistanceNeeded:
          data['medical_assistance_needed'] as bool? ?? false,
      status: data['status'] as String,
      createdAt: data['created_at'] as String,
    );
  }

  @override
  Future<IncidentEntity> reportIncident({
    required String type,
    required double latitude,
    required double longitude,
    String? description,
    String? locationAddress,
    bool medicalAssistanceNeeded = false,
    List<File> photos = const [],
  }) async {
    final formData = FormData.fromMap({
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'location_address': locationAddress,
      'medical_assistance_needed': medicalAssistanceNeeded,
    });

    for (int i = 0; i < photos.length; i++) {
      formData.files.add(MapEntry(
        'photos[]',
        await MultipartFile.fromFile(photos[i].path,
            filename: 'incident_photo_$i.jpg'),
      ));
    }

    final response =
        await apiClient.post('/rider/safety/incident', data: formData);
    final data = response.data['data'] as Map<String, dynamic>;

    return IncidentEntity(
      id: data['id'] as int,
      incidentNumber: data['incident_number'] as String,
      type: data['type'] as String,
      latitude: ((data['latitude'] ?? 0.0) as num).toDouble(),
      longitude: ((data['longitude'] ?? 0.0) as num).toDouble(),
      locationAddress: data['location_address'] as String?,
      description: data['description'] as String?,
      medicalAssistanceNeeded:
          data['medical_assistance_needed'] as bool? ?? false,
      status: data['status'] as String,
      createdAt: data['created_at'] as String,
    );
  }

  @override
  Future<Map<String, dynamic>> getInsuranceDetails() async {
    final response = await apiClient.get('/rider/safety/insurance');
    return response.data['data'] as Map<String, dynamic>;
  }
}
