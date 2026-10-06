import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_rider/core/services/background_geolocation_service.dart';
import 'package:freska_rider/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'duty_event.dart';
import 'duty_state.dart';

class DutyBloc extends Bloc<DutyEvent, DutyState> {
  final DashboardRepository dashboardRepository;
  final BackgroundGeolocationService backgroundGeolocationService;

  DutyBloc({
    required this.dashboardRepository,
    required this.backgroundGeolocationService,
  }) : super(const DutyState()) {
    on<ToggleDutyEvent>(_onToggleDuty);
    on<SetInitialDutyEvent>(_onSetInitialDuty);
  }

  void _onSetInitialDuty(
    SetInitialDutyEvent event,
    Emitter<DutyState> emit,
  ) {
    emit(state.copyWith(isOnline: event.isOnline));
    if (event.isOnline) {
      backgroundGeolocationService.startTracking();
    } else {
      backgroundGeolocationService.stopTracking();
    }
  }

  Future<void> _onToggleDuty(
    ToggleDutyEvent event,
    Emitter<DutyState> emit,
  ) async {
    emit(state.copyWith(status: DutyStatus.toggling, errorMessage: null));

    try {
      if (event.isOnline) {
        final position =
            await backgroundGeolocationService.getCurrentPosition();
        if (position == null) {
          emit(state.copyWith(
            status: DutyStatus.failure,
            errorMessage:
                'Location services and GPS permissions are required to go Online.',
          ));
          return;
        }

        final isOnline = await dashboardRepository.toggleDuty(
          isOnline: true,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        backgroundGeolocationService.startTracking();
        emit(state.copyWith(
          isOnline: isOnline,
          status: DutyStatus.success,
        ));
      } else {
        final isOnline = await dashboardRepository.toggleDuty(
          isOnline: false,
        );

        backgroundGeolocationService.stopTracking();
        emit(state.copyWith(
          isOnline: isOnline,
          status: DutyStatus.success,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DutyStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  @override
  Future<void> close() {
    backgroundGeolocationService.stopTracking();
    return super.close();
  }
}
