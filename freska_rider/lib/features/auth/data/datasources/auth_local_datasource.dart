import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearAuth();
  Future<void> saveCachedUser(UserModel user);
  Future<UserModel?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  static const String _keyCachedUser = 'freska_cached_user';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.getToken();
  }

  @override
  Future<void> clearAuth() async {
    await secureStorage.deleteToken();
    const storage = FlutterSecureStorage();
    await storage.delete(key: _keyCachedUser);
  }

  @override
  Future<void> saveCachedUser(UserModel user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _keyCachedUser, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    const storage = FlutterSecureStorage();
    final jsonStr = await storage.read(key: _keyCachedUser);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }
}
