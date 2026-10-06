import 'package:freska_customer/core/network/api_client.dart';
import 'package:freska_customer/core/storage/secure_storage_service.dart';

class CustomerAuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  CustomerAuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  Future<void> sendOtp(String phone) async {
    final response = await _apiClient.post(
      '/auth/otp/send',
      data: {'phone': phone},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to send OTP.');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      '/auth/otp/verify',
      data: {
        'phone': phone,
        'otp': otp,
        'device_id': 'freska-customer-device-001',
        'device_model': 'Android Client',
        'os_version': 'Android 16',
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final token = response.data['data']['token'] as String;
      final user = response.data['data']['user'] as Map<String, dynamic>;

      await _storage.saveToken(token);
      await _storage.saveUserData(
        phone: user['phone'] ?? phone,
        name: user['name'],
      );

      return user;
    } else {
      throw Exception(response.data['message'] ?? 'Invalid OTP code.');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {}
    await _storage.clearSession();
  }

  Future<bool> isAuthenticated() async {
    return await _storage.hasValidToken();
  }
}
