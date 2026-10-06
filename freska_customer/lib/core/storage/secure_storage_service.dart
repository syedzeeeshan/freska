import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'freska_customer_token';
  static const String _keyPhone = 'freska_customer_phone';
  static const String _keyName = 'freska_customer_name';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUserData({required String phone, String? name}) async {
    await _storage.write(key: _keyPhone, value: phone);
    if (name != null) {
      await _storage.write(key: _keyName, value: name);
    }
  }

  Future<String?> getPhone() async {
    return await _storage.read(key: _keyPhone);
  }

  Future<String?> getName() async {
    return await _storage.read(key: _keyName);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyPhone);
    await _storage.delete(key: _keyName);
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
