import 'package:equatable/equatable.dart';
import '../../domain/entities/navigation_instruction.dart';

class VoiceNavigationState extends Equatable {
  final bool isVoiceEnabled;
  final bool isSpeaking;
  final bool isNavigating;
  final NavigationInstruction? currentInstruction;
  final double? distanceMeters;
  final String? destinationName;
  final bool isArrived;
  final int? lastSpokenThreshold;
  final String? lastSpokenText;
  final double volume;
  final double speechRate;
  final String? statusMessage;

  const VoiceNavigationState({
    this.isVoiceEnabled = true,
    this.isSpeaking = false,
    this.isNavigating = false,
    this.currentInstruction,
    this.distanceMeters,
    this.destinationName,
    this.isArrived = false,
    this.lastSpokenThreshold,
    this.lastSpokenText,
    this.volume = 1.0,
    this.speechRate = 0.5,
    this.statusMessage,
  });

  VoiceNavigationState copyWith({
    bool? isVoiceEnabled,
    bool? isSpeaking,
    bool? isNavigating,
    NavigationInstruction? currentInstruction,
    double? distanceMeters,
    String? destinationName,
    bool? isArrived,
    int? lastSpokenThreshold,
    String? lastSpokenText,
    double? volume,
    double? speechRate,
    String? statusMessage,
  }) {
    return VoiceNavigationState(
      isVoiceEnabled: isVoiceEnabled ?? this.isVoiceEnabled,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isNavigating: isNavigating ?? this.isNavigating,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      destinationName: destinationName ?? this.destinationName,
      isArrived: isArrived ?? this.isArrived,
      lastSpokenThreshold: lastSpokenThreshold ?? this.lastSpokenThreshold,
      lastSpokenText: lastSpokenText ?? this.lastSpokenText,
      volume: volume ?? this.volume,
      speechRate: speechRate ?? this.speechRate,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        isVoiceEnabled,
        isSpeaking,
        isNavigating,
        currentInstruction,
        distanceMeters,
        destinationName,
        isArrived,
        lastSpokenThreshold,
        lastSpokenText,
        volume,
        speechRate,
        statusMessage,
      ];
}
