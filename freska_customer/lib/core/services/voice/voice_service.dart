import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _tts;
  bool _isInitialized = false;

  VoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[CustomerVoiceService] Init non-blocking error: $e');
    }
  }

  Future<bool> speak(String text) async {
    if (text.trim().isEmpty) return false;
    try {
      if (!_isInitialized) await initialize();
      final res = await _tts.speak(text);
      return res == 1;
    } catch (e) {
      debugPrint('[CustomerVoiceService] Speak error: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      if (_isInitialized) await _tts.stop();
    } catch (e) {
      debugPrint('[CustomerVoiceService] Stop error: $e');
    }
  }
}
