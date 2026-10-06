import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/core/services/voice/voice_intent_engine.dart';

void main() {
  late VoiceIntentEngine engine;

  setUp(() {
    engine = VoiceIntentEngine(apiClient: null); // Test deterministic local NLP engine
  });

  group('VoiceIntentEngine — Rider Voice Tests', () {
    test('recognizes Go Online command and returns target action', () async {
      final result = await engine.processCommand(
        query: 'Please go online now',
        role: FreskaVoiceRole.rider,
      );

      expect(result.intent, 'TOGGLE_DUTY_ONLINE');
      expect(result.targetAction, 'GO_ONLINE');
      expect(result.requiresConfirmation, false);
    });

    test('recognizes Go Offline command and returns target action', () async {
      final result = await engine.processCommand(
        query: 'Stop duty and go offline',
        role: FreskaVoiceRole.rider,
      );

      expect(result.intent, 'TOGGLE_DUTY_OFFLINE');
      expect(result.targetAction, 'GO_OFFLINE');
      expect(result.requiresConfirmation, false);
    });

    test('recognizes Show Order command and routes to delivery screen', () async {
      final result = await engine.processCommand(
        query: 'Show current active order',
        role: FreskaVoiceRole.rider,
      );

      expect(result.intent, 'SHOW_CURRENT_ORDER');
      expect(result.targetRoute, '/orders/delivery');
    });

    test('recognizes Repeat Navigation instruction command', () async {
      final result = await engine.processCommand(
        query: 'Repeat instruction again',
        role: FreskaVoiceRole.rider,
      );

      expect(result.intent, 'REPEAT_NAVIGATION');
      expect(result.targetAction, 'REPEAT_TTS');
    });
  });

  group('VoiceIntentEngine — Customer Voice Tests', () {
    test('recognizes search food queries', () async {
      final result = await engine.processCommand(
        query: 'Find sweet strawberries',
        role: FreskaVoiceRole.customer,
      );

      expect(result.intent, 'SEARCH_FOOD');
      expect(result.targetRoute, contains('/search?q='));
    });

    test('recognizes cart inspection command', () async {
      final result = await engine.processCommand(
        query: 'Open my cart',
        role: FreskaVoiceRole.customer,
      );

      expect(result.intent, 'OPEN_CART');
      expect(result.targetRoute, '/cart');
    });

    test('recognizes order tracking command', () async {
      final result = await engine.processCommand(
        query: 'Where is my order and track it',
        role: FreskaVoiceRole.customer,
      );

      expect(result.intent, 'TRACK_ORDER');
      expect(result.targetRoute, '/orders');
    });
  });

  group('VoiceIntentEngine — Vendor Voice Tests', () {
    test('recognizes show pending orders in kitchen', () async {
      final result = await engine.processCommand(
        query: 'Show pending new orders',
        role: FreskaVoiceRole.vendor,
      );

      expect(result.intent, 'SHOW_ORDERS');
      expect(result.targetRoute, '/vendor/orders');
    });

    test('recognizes store earnings query', () async {
      final result = await engine.processCommand(
        query: 'What are today sales and revenue',
        role: FreskaVoiceRole.vendor,
      );

      expect(result.intent, 'SHOW_EARNINGS');
      expect(result.targetRoute, '/vendor/earnings');
    });

    test('requires confirmation for high-risk order ready action', () async {
      final result = await engine.processCommand(
        query: 'Mark order 10842 as ready',
        role: FreskaVoiceRole.vendor,
      );

      expect(result.intent, 'MARK_ORDER_READY');
      expect(result.requiresConfirmation, true);
      expect(result.confirmationPrompt, isNotNull);
    });
  });
}
