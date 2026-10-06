import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'freska_vendor_token';
  static const String _userKey = 'freska_vendor_user_phone';
  static const String _nameKey = 'freska_vendor_user_name';
  static const String _vendorIdKey = 'freska_vendor_id';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserData({required String phone, String? name, int? vendorId}) async {
    await _storage.write(key: _userKey, value: phone);
    if (name != null) await _storage.write(key: _nameKey, value: name);
    if (vendorId != null) await _storage.write(key: _vendorIdKey, value: vendorId.toString());
  }

  Future<String?> getPhone() async {
    return await _storage.read(key: _userKey);
  }

  Future<int?> getVendorId() async {
    final val = await _storage.read(key: _vendorIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _vendorIdKey);
  }
}
