import 'package:equatable/equatable.dart';

class IncidentEntity extends Equatable {
  final int id;
  final String incidentNumber;
  final String type;
  final double latitude;
  final double longitude;
  final String? locationAddress;
  final String? description;
  final bool medicalAssistanceNeeded;
  final String status;
  final String createdAt;

  const IncidentEntity({
    required this.id,
    required this.incidentNumber,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.locationAddress,
    this.description,
    required this.medicalAssistanceNeeded,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        incidentNumber,
        type,
        latitude,
        longitude,
        locationAddress,
        description,
        medicalAssistanceNeeded,
        status,
        createdAt,
      ];
}
