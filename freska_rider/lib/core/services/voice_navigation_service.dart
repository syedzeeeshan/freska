import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum VoiceStatus { idle, speaking, paused, stopped, error }

class VoiceNavigationService {
  final FlutterTts _tts;
  bool _isInitialized = false;
  VoiceStatus _status = VoiceStatus.idle;

  final _statusController = StreamController<VoiceStatus>.broadcast();
  Stream<VoiceStatus> get statusStream => _statusController.stream;
  VoiceStatus get status => _status;
  bool get isSpeaking => _status == VoiceStatus.speaking;

  VoiceNavigationService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  Future<void> initialize({
    String language = 'en-US',
    double speechRate = 0.5,
    double volume = 1.0,
    double pitch = 1.0,
  }) async {
    if (_isInitialized) return;

    try {
      _tts.setStartHandler(() {
        _status = VoiceStatus.speaking;
        _statusController.add(_status);
      });

      _tts.setCompletionHandler(() {
        _status = VoiceStatus.idle;
        _statusController.add(_status);
      });

      _tts.setCancelHandler(() {
        _status = VoiceStatus.stopped;
        _statusController.add(_status);
      });

      _tts.setPauseHandler(() {
        _status = VoiceStatus.paused;
        _statusController.add(_status);
      });

      _tts.setContinueHandler(() {
        _status = VoiceStatus.speaking;
        _statusController.add(_status);
      });

      _tts.setErrorHandler((msg) {
        debugPrint('[VoiceNavigationService] TTS Error: $msg');
        _status = VoiceStatus.error;
        _statusController.add(_status);
      });

      await _tts.setLanguage(language);
      await _tts.setSpeechRate(speechRate);
      await _tts.setVolume(volume);
      await _tts.setPitch(pitch);

      _isInitialized = true;
    } catch (e) {
      debugPrint(
          '[VoiceNavigationService] Initialization failed gracefully: $e');
      _status = VoiceStatus.error;
      _statusController.add(_status);
    }
  }

  Future<bool> speak(String text) async {
    if (text.trim().isEmpty) return false;

    try {
      if (!_isInitialized) {
        await initialize();
      }

      final result = await _tts.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('[VoiceNavigationService] Speak error (non-blocking): $e');
      _status = VoiceStatus.idle;
      _statusController.add(_status);
      return false;
    }
  }

  Future<void> stop() async {
    try {
      if (_isInitialized) {
        await _tts.stop();
      }
      _status = VoiceStatus.stopped;
      _statusController.add(_status);
    } catch (e) {
      debugPrint('[VoiceNavigationService] Stop error: $e');
    }
  }

  Future<void> pause() async {
    try {
      if (_isInitialized) {
        await _tts.pause();
      }
      _status = VoiceStatus.paused;
      _statusController.add(_status);
    } catch (e) {
      debugPrint('[VoiceNavigationService] Pause error: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      if (!_isInitialized) await initialize();
      await _tts.setLanguage(language);
    } catch (e) {
      debugPrint('[VoiceNavigationService] SetLanguage error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      if (!_isInitialized) await initialize();
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('[VoiceNavigationService] SetVolume error: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      if (!_isInitialized) await initialize();
      await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
    } catch (e) {
      debugPrint('[VoiceNavigationService] SetSpeechRate error: $e');
    }
  }

  void dispose() {
    try {
      stop();
      _statusController.close();
    } catch (_) {}
  }
}
