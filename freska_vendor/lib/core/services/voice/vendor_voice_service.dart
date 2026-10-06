import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VendorVoiceService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[VendorVoiceService] TTS Init warning: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      await init();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[VendorVoiceService] TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[VendorVoiceService] TTS Stop error: $e');
    }
  }
}
