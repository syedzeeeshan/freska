import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String keyToken = 'freska_sanctum_token';
  static const String keyDeviceId = 'freska_hardware_device_id';
  static const String keyUserPhone = 'freska_user_phone';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: keyToken);
  }

  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: keyDeviceId, value: deviceId);
  }

  Future<String> getOrCreateDeviceId() async {
    var deviceId = await _storage.read(key: keyDeviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId =
          'device_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9000 * (DateTime.now().microsecond / 1000000)).floor())}';
      await _storage.write(key: keyDeviceId, value: deviceId);
    }
    return deviceId;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
