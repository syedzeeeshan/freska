import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/features/safety/domain/entities/incident_entity.dart';
import 'package:freska_rider/features/safety/domain/repositories/safety_repository.dart';
import 'package:freska_rider/features/safety/presentation/blocs/safety_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSafetyRepository extends Mock implements SafetyRepository {}

void main() {
  late MockSafetyRepository mockRepository;
  late SafetyBloc safetyBloc;

  setUp(() {
    mockRepository = MockSafetyRepository();
    safetyBloc = SafetyBloc(repository: mockRepository);
  });

  tearDown(() {
    safetyBloc.close();
  });

  const tIncident = IncidentEntity(
    id: 101,
    incidentNumber: 'INC-2026-A1B2C3',
    type: 'sos_panic',
    latitude: 12.9716,
    longitude: 77.5946,
    locationAddress: 'MG Road, Bangalore',
    description: null,
    medicalAssistanceNeeded: true,
    status: 'triggered',
    createdAt: '2026-09-22T13:50:00Z',
  );

  test('initial state should be SafetyInitial', () {
    expect(safetyBloc.state, equals(SafetyInitial()));
  });

  blocTest<SafetyBloc, SafetyState>(
    'emits [SafetyLoading, SosTriggeredSuccess] when TriggerSosEvent is successful',
    build: () {
      when(() => mockRepository.triggerSos(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            locationAddress: any(named: 'locationAddress'),
            medicalAssistanceNeeded: any(named: 'medicalAssistanceNeeded'),
            orderId: any(named: 'orderId'),
          )).thenAnswer((_) async => tIncident);
      return safetyBloc;
    },
    act: (bloc) => bloc.add(const TriggerSosEvent(
      latitude: 12.9716,
      longitude: 77.5946,
      locationAddress: 'MG Road, Bangalore',
      medicalAssistanceNeeded: true,
    )),
    expect: () => [
      SafetyLoading(),
      const SosTriggeredSuccess(incident: tIncident),
    ],
  );
}
