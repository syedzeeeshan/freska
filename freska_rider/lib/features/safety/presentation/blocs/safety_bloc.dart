import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/safety_repository.dart';
import 'safety_event.dart';
import 'safety_state.dart';

export 'safety_event.dart';
export 'safety_state.dart';

class SafetyBloc extends Bloc<SafetyEvent, SafetyState> {
  final SafetyRepository repository;

  SafetyBloc({required this.repository}) : super(SafetyInitial()) {
    on<TriggerSosEvent>(_onTriggerSos);
    on<ReportIncidentEvent>(_onReportIncident);
    on<LoadInsuranceEvent>(_onLoadInsurance);
  }

  Future<void> _onTriggerSos(
    TriggerSosEvent event,
    Emitter<SafetyState> emit,
  ) async {
    emit(SafetyLoading());
    try {
      final incident = await repository.triggerSos(
        latitude: event.latitude,
        longitude: event.longitude,
        locationAddress: event.locationAddress,
        medicalAssistanceNeeded: event.medicalAssistanceNeeded,
        orderId: event.orderId,
      );
      emit(SosTriggeredSuccess(incident: incident));
    } catch (e) {
      emit(SafetyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onReportIncident(
    ReportIncidentEvent event,
    Emitter<SafetyState> emit,
  ) async {
    emit(SafetyLoading());
    try {
      final incident = await repository.reportIncident(
        type: event.type,
        latitude: event.latitude,
        longitude: event.longitude,
        description: event.description,
        locationAddress: event.locationAddress,
        medicalAssistanceNeeded: event.medicalAssistanceNeeded,
        photos: event.photos ?? const [],
      );
      emit(IncidentReportedSuccess(incident: incident));
    } catch (e) {
      emit(SafetyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadInsurance(
    LoadInsuranceEvent event,
    Emitter<SafetyState> emit,
  ) async {
    emit(SafetyLoading());
    try {
      final details = await repository.getInsuranceDetails();
      emit(InsuranceLoaded(insurance: details));
    } catch (e) {
      emit(SafetyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
