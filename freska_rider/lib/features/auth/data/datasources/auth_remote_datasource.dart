import '../../../../core/network/api_client.dart';
import '../../../../config/network_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<int> sendOtp(String phone);

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
  });

  Future<UserModel> getMe();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<int> sendOtp(String phone) async {
    final response = await apiClient.post(
      NetworkConstants.endpointSendOtp,
      data: {'phone': phone},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return (data['resend_in_seconds'] as num?)?.toInt() ?? 60;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointVerifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
        'device_id': deviceId,
        'device_model': deviceModel,
        'os_version': osVersion,
        'app_version': appVersion,
        'fcm_token': fcmToken,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    return {
      'token': token,
      'user': user,
    };
  }

  @override
  Future<UserModel> getMe() async {
    final response = await apiClient.get(NetworkConstants.endpointMe);
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(NetworkConstants.endpointLogout);
  }
}
