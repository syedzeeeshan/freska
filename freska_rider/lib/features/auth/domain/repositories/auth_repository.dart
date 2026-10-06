import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<int> sendOtp(String phone);

  Future<UserEntity> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
  });

  Future<UserEntity?> getCurrentUser();

  Future<void> logout();

  Future<bool> isAuthenticated();
}
