import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SafetyEvent extends Equatable {
  const SafetyEvent();

  @override
  List<Object?> get props => [];
}

class TriggerSosEvent extends SafetyEvent {
  final double latitude;
  final double longitude;
  final String? locationAddress;
  final bool medicalAssistanceNeeded;
  final int? orderId;

  const TriggerSosEvent({
    required this.latitude,
    required this.longitude,
    this.locationAddress,
    this.medicalAssistanceNeeded = false,
    this.orderId,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, locationAddress, medicalAssistanceNeeded, orderId];
}

class ReportIncidentEvent extends SafetyEvent {
  final String type;
  final double latitude;
  final double longitude;
  final String description;
  final String? locationAddress;
  final bool medicalAssistanceNeeded;
  final List<File>? photos;

  const ReportIncidentEvent({
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.locationAddress,
    this.medicalAssistanceNeeded = false,
    this.photos,
  });

  @override
  List<Object?> get props => [
        type,
        latitude,
        longitude,
        description,
        locationAddress,
        medicalAssistanceNeeded,
        photos
      ];
}

class LoadInsuranceEvent extends SafetyEvent {
  const LoadInsuranceEvent();
}
