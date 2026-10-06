import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/voice_navigation_service.dart';
import '../../domain/entities/navigation_instruction.dart';
import 'voice_navigation_state.dart';

export 'voice_navigation_state.dart';

class VoiceNavigationCubit extends Cubit<VoiceNavigationState> {
  final VoiceNavigationService voiceService;
  StreamSubscription<VoiceStatus>? _statusSubscription;

  double? _targetLat;
  double? _targetLng;
  List<NavigationInstruction> _routeInstructions = [];

  List<NavigationInstruction> get routeInstructions => _routeInstructions;

  VoiceNavigationCubit({required this.voiceService})
      : super(const VoiceNavigationState()) {
    _statusSubscription = voiceService.statusStream.listen((status) {
      if (isClosed) return;
      emit(state.copyWith(isSpeaking: status == VoiceStatus.speaking));
    });
  }

  void toggleVoice() {
    final next = !state.isVoiceEnabled;
    emit(state.copyWith(isVoiceEnabled: next));

    if (!next) {
      voiceService.stop();
    } else {
      voiceService.speak('Voice navigation enabled.');
    }
  }

  void enableVoice() {
    if (!state.isVoiceEnabled) {
      emit(state.copyWith(isVoiceEnabled: true));
      voiceService.speak('Voice navigation enabled.');
    }
  }

  void disableVoice() {
    if (state.isVoiceEnabled) {
      emit(state.copyWith(isVoiceEnabled: false));
      voiceService.stop();
    }
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    emit(state.copyWith(volume: clamped));
    await voiceService.setVolume(clamped);
  }

  Future<void> setSpeechRate(double rate) async {
    final clamped = rate.clamp(0.1, 1.0);
    emit(state.copyWith(speechRate: clamped));
    await voiceService.setSpeechRate(clamped);
  }

  void startNavigation({
    required String destinationName,
    required double targetLat,
    required double targetLng,
    List<NavigationInstruction>? routeInstructions,
  }) {
    _targetLat = targetLat;
    _targetLng = targetLng;
    _routeInstructions = routeInstructions ?? [];

    emit(state.copyWith(
      isNavigating: true,
      destinationName: destinationName,
      isArrived: false,
      lastSpokenThreshold: null,
      lastSpokenText: null,
      statusMessage: 'Navigating to $destinationName',
    ));

    if (state.isVoiceEnabled) {
      voiceService.speak('Starting navigation to $destinationName.');
    }
  }

  void updateLocation({
    required double currentLat,
    required double currentLng,
  }) {
    if (!state.isNavigating ||
        _targetLat == null ||
        _targetLng == null ||
        state.isArrived) {
      return;
    }

    final distance = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      _targetLat!,
      _targetLng!,
    );

    emit(state.copyWith(distanceMeters: distance));

    _evaluateAnnouncement(distance);
  }

  void _evaluateAnnouncement(double distance) {
    if (!state.isVoiceEnabled) return;

    final dest = state.destinationName ?? 'destination';

    // Arrival threshold: <= 30m
    if (distance <= 30) {
      if (!state.isArrived) {
        emit(state.copyWith(
          isArrived: true,
          lastSpokenThreshold: 0,
          lastSpokenText: 'You have arrived at your destination.',
          statusMessage: 'Arrived at $dest',
        ));
        voiceService.speak('You have arrived at your destination.');
      }
      return;
    }

    // 50m threshold
    if (distance <= 60 &&
        (state.lastSpokenThreshold == null ||
            state.lastSpokenThreshold! > 50)) {
      final phrase = 'In 50 meters, $dest will be on your right.';
      emit(state.copyWith(
        lastSpokenThreshold: 50,
        lastSpokenText: phrase,
      ));
      voiceService.speak(phrase);
      return;
    }

    // 200m threshold
    if (distance <= 220 &&
        (state.lastSpokenThreshold == null ||
            state.lastSpokenThreshold! > 200)) {
      final phrase = 'In 200 meters, continue towards $dest.';
      emit(state.copyWith(
        lastSpokenThreshold: 200,
        lastSpokenText: phrase,
      ));
      voiceService.speak(phrase);
      return;
    }

    // 500m threshold
    if (distance <= 550 &&
        (state.lastSpokenThreshold == null ||
            state.lastSpokenThreshold! > 500)) {
      final phrase = 'In 500 meters, continue straight towards $dest.';
      emit(state.copyWith(
        lastSpokenThreshold: 500,
        lastSpokenText: phrase,
      ));
      voiceService.speak(phrase);
      return;
    }

    // 1km threshold
    if (distance <= 1100 &&
        (state.lastSpokenThreshold == null ||
            state.lastSpokenThreshold! > 1000)) {
      final phrase = 'In 1 kilometer, continue towards $dest.';
      emit(state.copyWith(
        lastSpokenThreshold: 1000,
        lastSpokenText: phrase,
      ));
      voiceService.speak(phrase);
      return;
    }
  }

  void announceInstruction(NavigationInstruction instruction) {
    emit(state.copyWith(currentInstruction: instruction));

    if (state.isVoiceEnabled) {
      final spoken = instruction.toSpokenPhrase();
      if (spoken != state.lastSpokenText) {
        emit(state.copyWith(lastSpokenText: spoken));
        voiceService.speak(spoken);
      }
    }
  }

  void announceArrival() {
    emit(state.copyWith(
      isArrived: true,
      lastSpokenThreshold: 0,
      lastSpokenText: 'You have arrived at your destination.',
    ));

    if (state.isVoiceEnabled) {
      voiceService.speak('You have arrived at your destination.');
    }
  }

  void stopNavigation() {
    voiceService.stop();
    emit(VoiceNavigationState(
      isVoiceEnabled: state.isVoiceEnabled,
      volume: state.volume,
      speechRate: state.speechRate,
    ));
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    voiceService.stop();
    return super.close();
  }
}
