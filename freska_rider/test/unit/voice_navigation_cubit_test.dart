import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/core/services/voice_navigation_service.dart';
import 'package:freska_rider/features/orders/domain/entities/navigation_instruction.dart';
import 'package:freska_rider/features/orders/presentation/cubit/voice_navigation_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockVoiceNavigationService extends Mock
    implements VoiceNavigationService {}

void main() {
  late MockVoiceNavigationService mockVoiceService;
  late VoiceNavigationCubit voiceCubit;

  setUp(() {
    mockVoiceService = MockVoiceNavigationService();
    when(() => mockVoiceService.statusStream)
        .thenAnswer((_) => const Stream<VoiceStatus>.empty());
    when(() => mockVoiceService.speak(any())).thenAnswer((_) async => true);
    when(() => mockVoiceService.stop()).thenAnswer((_) async {});
    when(() => mockVoiceService.setVolume(any())).thenAnswer((_) async {});
    when(() => mockVoiceService.setSpeechRate(any())).thenAnswer((_) async {});

    voiceCubit = VoiceNavigationCubit(voiceService: mockVoiceService);
  });

  tearDown(() {
    voiceCubit.close();
  });

  test('initial state has voice enabled and idle navigation', () {
    expect(voiceCubit.state.isVoiceEnabled, isTrue);
    expect(voiceCubit.state.isSpeaking, isFalse);
    expect(voiceCubit.state.isNavigating, isFalse);
  });

  blocTest<VoiceNavigationCubit, VoiceNavigationState>(
    'toggleVoice disables voice and calls stop on service',
    build: () => voiceCubit,
    act: (cubit) => cubit.toggleVoice(),
    expect: () => [
      const VoiceNavigationState(isVoiceEnabled: false),
    ],
    verify: (_) {
      verify(() => mockVoiceService.stop()).called(greaterThanOrEqualTo(1));
    },
  );

  blocTest<VoiceNavigationCubit, VoiceNavigationState>(
    'toggleVoice re-enables voice and speaks confirmation',
    build: () {
      voiceCubit.disableVoice();
      return voiceCubit;
    },
    act: (cubit) => cubit.toggleVoice(),
    expect: () => [
      const VoiceNavigationState(isVoiceEnabled: true),
    ],
    verify: (_) {
      verify(() => mockVoiceService.speak('Voice navigation enabled.'))
          .called(1);
    },
  );

  blocTest<VoiceNavigationCubit, VoiceNavigationState>(
    'startNavigation initiates navigation and announces start',
    build: () => voiceCubit,
    act: (cubit) => cubit.startNavigation(
      destinationName: 'Freska Dark Store',
      targetLat: 12.9716,
      targetLng: 77.5946,
    ),
    expect: () => [
      const VoiceNavigationState(
        isNavigating: true,
        destinationName: 'Freska Dark Store',
        isArrived: false,
        statusMessage: 'Navigating to Freska Dark Store',
      ),
    ],
    verify: (_) {
      verify(() => mockVoiceService
          .speak('Starting navigation to Freska Dark Store.')).called(1);
    },
  );

  blocTest<VoiceNavigationCubit, VoiceNavigationState>(
    'announceArrival sets arrived state and speaks arrival phrase',
    build: () => voiceCubit,
    act: (cubit) => cubit.announceArrival(),
    expect: () => [
      const VoiceNavigationState(
        isArrived: true,
        lastSpokenThreshold: 0,
        lastSpokenText: 'You have arrived at your destination.',
      ),
    ],
    verify: (_) {
      verify(() =>
              mockVoiceService.speak('You have arrived at your destination.'))
          .called(1);
    },
  );

  blocTest<VoiceNavigationCubit, VoiceNavigationState>(
    'stopNavigation resets navigation state and calls stop',
    build: () {
      voiceCubit.startNavigation(
        destinationName: 'Freska Dark Store',
        targetLat: 12.9716,
        targetLng: 77.5946,
      );
      return voiceCubit;
    },
    act: (cubit) => cubit.stopNavigation(),
    expect: () => [
      const VoiceNavigationState(
        isNavigating: false,
        isSpeaking: false,
        destinationName: null,
        statusMessage: null,
      ),
    ],
    verify: (_) {
      verify(() => mockVoiceService.stop()).called(greaterThanOrEqualTo(1));
    },
  );

  test('NavigationInstruction formatting formats spoken instructions correctly',
      () {
    const arrivalInst = NavigationInstruction(
      instructionText: 'Arrival',
      distanceMeters: 0,
      isArrival: true,
    );
    expect(arrivalInst.toSpokenPhrase(),
        equals('You have arrived at your destination.'));

    const turnLeftNear = NavigationInstruction(
      instructionText: 'Turn left',
      distanceMeters: 40,
      maneuverType: ManeuverType.turnLeft,
      roadName: '100ft Road',
    );
    expect(turnLeftNear.toSpokenPhrase(),
        equals('Turn left now onto 100ft Road.'));

    const turnRight200 = NavigationInstruction(
      instructionText: 'Turn right',
      distanceMeters: 200,
      maneuverType: ManeuverType.turnRight,
    );
    expect(turnRight200.toSpokenPhrase(), equals('In 200 meters, turn right.'));
  });
}
