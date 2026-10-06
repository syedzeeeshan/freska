import '../repositories/onboarding_repository.dart';

class UpdateEmergencyContactUseCase {
  final OnboardingRepository repository;

  UpdateEmergencyContactUseCase({required this.repository});

  Future<void> call({
    required String name,
    required String phone,
    required String relation,
  }) async {
    await repository.updateEmergencyContact(
      name: name,
      phone: phone,
      relation: relation,
    );
  }
}
