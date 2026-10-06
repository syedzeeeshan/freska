import 'package:flutter_test/flutter_test.dart';
import 'package:freska_vendor/core/config/environment_config.dart';
import 'package:freska_vendor/core/network/api_client.dart';
import 'package:freska_vendor/core/services/voice/vendor_voice_intent_engine.dart';
import 'package:freska_vendor/core/storage/secure_storage_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    EnvironmentConfig.initialize(flavor: Flavor.development);
  });

  group('VendorVoiceIntentEngine Tests', () {
    test('parses pending orders voice intent correctly', () async {
      final storage = SecureStorageService();
      final client = ApiClient(storage: storage);
      final engine = VendorVoiceIntentEngine(apiClient: client);

      final result = await engine.processCommand('Show my pending orders');
      expect(result.intent, 'VIEW_PENDING_ORDERS');
      expect(result.targetRoute, contains('/orders'));
    });

    test('parses sales and earnings intent correctly', () async {
      final storage = SecureStorageService();
      final client = ApiClient(storage: storage);
      final engine = VendorVoiceIntentEngine(apiClient: client);

      final result = await engine.processCommand('What are my sales today?');
      expect(result.intent, 'CHECK_EARNINGS');
      expect(result.targetRoute, '/earnings');
    });

    test('parses high-risk mark order ready with required confirmation', () async {
      final storage = SecureStorageService();
      final client = ApiClient(storage: storage);
      final engine = VendorVoiceIntentEngine(apiClient: client);

      final result = await engine.processCommand('Mark order 89421 ready');
      expect(result.intent, 'MARK_ORDER_READY');
      expect(result.requiresConfirmation, isTrue);
      expect(result.confirmationPrompt, isNotNull);
      expect(result.parameters?['order_id'], '89421');
    });

    test('parses store menu and catalog command', () async {
      final storage = SecureStorageService();
      final client = ApiClient(storage: storage);
      final engine = VendorVoiceIntentEngine(apiClient: client);

      final result = await engine.processCommand('Open kitchen menu');
      expect(result.intent, 'MANAGE_MENU');
      expect(result.targetRoute, '/menu');
    });

    test('parses store close action with confirmation', () async {
      final storage = SecureStorageService();
      final client = ApiClient(storage: storage);
      final engine = VendorVoiceIntentEngine(apiClient: client);

      final result = await engine.processCommand('Close store now');
      expect(result.intent, 'TOGGLE_STORE_STATUS');
      expect(result.requiresConfirmation, isTrue);
      expect(result.parameters?['action'], 'close');
    });

    test('parses store open action', () async {
      final storage = SecureStorageService();
      final client = ApiClient(storage: storage);
      final engine = VendorVoiceIntentEngine(apiClient: client);

      final result = await engine.processCommand('Open store for business');
      expect(result.intent, 'TOGGLE_STORE_STATUS');
      expect(result.parameters?['action'], 'open');
    });
  });
}
