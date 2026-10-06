import 'package:flutter_test/flutter_test.dart';
import 'package:freska_customer/core/config/environment_config.dart';
import 'package:freska_customer/core/services/voice/voice_intent_engine.dart';
import 'package:freska_customer/core/network/api_client.dart';
import 'package:freska_customer/core/storage/secure_storage_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    EnvironmentConfig.initialize(flavor: Flavor.development);
  });
  test('CustomerVoiceIntentEngine parses local food search intent correctly', () async {
    final storage = SecureStorageService();
    final client = ApiClient(storage: storage);
    final engine = CustomerVoiceIntentEngine(apiClient: client);

    final result = await engine.processCommand('Find sweet strawberries');
    expect(result.intent, 'SEARCH_FOOD');
    expect(result.targetRoute, contains('/search?q='));
  });

  test('CustomerVoiceIntentEngine parses cart inspection intent correctly', () async {
    final storage = SecureStorageService();
    final client = ApiClient(storage: storage);
    final engine = CustomerVoiceIntentEngine(apiClient: client);

    final result = await engine.processCommand('Open my cart');
    expect(result.intent, 'OPEN_CART');
    expect(result.targetRoute, '/cart');
  });

  test('CustomerVoiceIntentEngine parses track order intent correctly', () async {
    final storage = SecureStorageService();
    final client = ApiClient(storage: storage);
    final engine = CustomerVoiceIntentEngine(apiClient: client);

    final result = await engine.processCommand('Where is my order');
    expect(result.intent, 'TRACK_ORDER');
    expect(result.targetRoute, '/orders');
  });
}
