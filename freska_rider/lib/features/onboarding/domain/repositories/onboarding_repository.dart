import 'dart:io';
import '../entities/bank_details_entity.dart';
import '../entities/kyc_entity.dart';

abstract class OnboardingRepository {
  Future<String> uploadProfilePhoto(File photoFile);

  Future<KycEntity> submitKyc({
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
  });

  Future<KycEntity> getKycStatus();

  Future<BankDetailsEntity> updateBankDetails({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  });

  Future<void> updateEmergencyContact({
    required String name,
    required String phone,
    required String relation,
  });
}
