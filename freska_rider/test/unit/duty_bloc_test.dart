import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/core/services/background_geolocation_service.dart';
import 'package:freska_rider/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_bloc.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_event.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_state.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockBackgroundGeolocationService extends Mock
    implements BackgroundGeolocationService {}

void main() {
  late MockDashboardRepository mockRepo;
  late MockBackgroundGeolocationService mockGeoService;
  late DutyBloc dutyBloc;

  final tPosition = Position(
    latitude: 12.971598,
    longitude: 77.594562,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 900.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 1.0,
    speed: 0.0,
    speedAccuracy: 1.0,
    isMocked: false,
  );

  setUp(() {
    mockRepo = MockDashboardRepository();
    mockGeoService = MockBackgroundGeolocationService();
    dutyBloc = DutyBloc(
      dashboardRepository: mockRepo,
      backgroundGeolocationService: mockGeoService,
    );
  });

  tearDown(() => dutyBloc.close());

  test('initial state is offline', () {
    expect(dutyBloc.state, equals(const DutyState()));
  });

  group('ToggleDutyEvent', () {
    blocTest<DutyBloc, DutyState>(
      'emits [toggling, success(isOnline: true)] when going online succeeds',
      build: () {
        when(() => mockGeoService.getCurrentPosition())
            .thenAnswer((_) async => tPosition);
        when(() => mockRepo.toggleDuty(
              isOnline: true,
              latitude: tPosition.latitude,
              longitude: tPosition.longitude,
            )).thenAnswer((_) async => true);
        when(() => mockGeoService.startTracking()).thenReturn(null);
        return dutyBloc;
      },
      act: (bloc) => bloc.add(const ToggleDutyEvent(isOnline: true)),
      expect: () => [
        const DutyState(status: DutyStatus.toggling),
        const DutyState(isOnline: true, status: DutyStatus.success),
      ],
      verify: (_) {
        verify(() => mockGeoService.startTracking()).called(1);
      },
    );

    blocTest<DutyBloc, DutyState>(
      'emits [toggling, failure] when GPS location is null',
      build: () {
        when(() => mockGeoService.getCurrentPosition())
            .thenAnswer((_) async => null);
        return dutyBloc;
      },
      act: (bloc) => bloc.add(const ToggleDutyEvent(isOnline: true)),
      expect: () => [
        const DutyState(status: DutyStatus.toggling),
        const DutyState(
          status: DutyStatus.failure,
          errorMessage:
              'Location services and GPS permissions are required to go Online.',
        ),
      ],
    );

    blocTest<DutyBloc, DutyState>(
      'emits [toggling, success(isOnline: false)] when going offline',
      build: () {
        when(() => mockRepo.toggleDuty(isOnline: false))
            .thenAnswer((_) async => false);
        when(() => mockGeoService.stopTracking()).thenReturn(null);
        return dutyBloc;
      },
      act: (bloc) => bloc.add(const ToggleDutyEvent(isOnline: false)),
      expect: () => [
        const DutyState(status: DutyStatus.toggling),
        const DutyState(isOnline: false, status: DutyStatus.success),
      ],
      verify: (_) {
        verify(() => mockGeoService.stopTracking())
            .called(greaterThanOrEqualTo(1));
      },
    );
  });
}
