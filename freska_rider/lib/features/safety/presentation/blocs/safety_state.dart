import 'package:equatable/equatable.dart';
import '../../domain/entities/incident_entity.dart';

abstract class SafetyState extends Equatable {
  const SafetyState();
  @override
  List<Object?> get props => [];
}

class SafetyInitial extends SafetyState {}

class SafetyLoading extends SafetyState {}

class SosTriggeredSuccess extends SafetyState {
  final IncidentEntity incident;
  const SosTriggeredSuccess({required this.incident});
  @override
  List<Object?> get props => [incident];
}

class IncidentReportedSuccess extends SafetyState {
  final IncidentEntity incident;
  const IncidentReportedSuccess({required this.incident});
  @override
  List<Object?> get props => [incident];
}

class InsuranceLoaded extends SafetyState {
  final Map<String, dynamic> insurance;
  const InsuranceLoaded({required this.insurance});
  @override
  List<Object?> get props => [insurance];
}

class SafetyError extends SafetyState {
  final String message;
  const SafetyError({required this.message});
  @override
  List<Object?> get props => [message];
}
