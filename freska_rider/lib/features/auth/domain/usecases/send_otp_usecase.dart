import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase({required this.repository});

  Future<int> call(String phone) async {
    return await repository.sendOtp(phone);
  }
}
