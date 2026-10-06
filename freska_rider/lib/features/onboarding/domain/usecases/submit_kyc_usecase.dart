import 'dart:io';
import '../entities/kyc_entity.dart';
import '../repositories/onboarding_repository.dart';

class SubmitKycUseCase {
  final OnboardingRepository repository;

  SubmitKycUseCase({required this.repository});

  Future<KycEntity> call({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
    required String licenseExpiry,
    required File licenseFront,
    required File licenseBack,
    required File rcBook,
    required String idProofType,
    required String idProofNumber,
    required File idProofDocument,
  }) async {
    return await repository.submitKyc(
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      licenseFront: licenseFront,
      licenseBack: licenseBack,
      rcBook: rcBook,
      idProofType: idProofType,
      idProofNumber: idProofNumber,
      idProofDocument: idProofDocument,
    );
  }
}
