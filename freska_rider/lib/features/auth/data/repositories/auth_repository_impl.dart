import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<int> sendOtp(String phone) async {
    try {
      return await remoteDataSource.sendOtp(phone);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
  }) async {
    try {
      final result = await remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        deviceModel: deviceModel,
        osVersion: osVersion,
        appVersion: appVersion,
        fcmToken: fcmToken,
      );

      final token = result['token'] as String;
      final user = result['user'] as UserEntity;

      await localDataSource.saveToken(token);
      return user;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) return null;

      final user = await remoteDataSource.getMe();
      await localDataSource.saveCachedUser(user);
      return user;
    } catch (e) {
      // Fallback to cached user if offline
      return await localDataSource.getCachedUser();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      await localDataSource.clearAuth();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }
}
