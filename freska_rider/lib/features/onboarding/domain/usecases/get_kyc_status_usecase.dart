import '../entities/kyc_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetKycStatusUseCase {
  final OnboardingRepository repository;

  GetKycStatusUseCase({required this.repository});

  Future<KycEntity> call() async {
    return await repository.getKycStatus();
  }
}
