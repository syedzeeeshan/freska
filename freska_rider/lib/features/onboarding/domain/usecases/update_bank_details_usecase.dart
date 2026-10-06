import '../entities/bank_details_entity.dart';
import '../repositories/onboarding_repository.dart';

class UpdateBankDetailsUseCase {
  final OnboardingRepository repository;

  UpdateBankDetailsUseCase({required this.repository});

  Future<BankDetailsEntity> call({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    return await repository.updateBankDetails(
      accountHolder: accountHolder,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      upiId: upiId,
    );
  }
}
