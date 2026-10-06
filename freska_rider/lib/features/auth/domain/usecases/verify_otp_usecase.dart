import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<UserEntity> call({
    required String phone,
    required String otp,
    required String deviceId,
    required String deviceModel,
    required String osVersion,
    String? fcmToken,
  }) async {
    return await repository.verifyOtp(
      phone: phone,
      otp: otp,
      deviceId: deviceId,
      deviceModel: deviceModel,
      osVersion: osVersion,
      fcmToken: fcmToken,
    );
  }
}
