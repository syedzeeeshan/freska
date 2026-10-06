import 'dart:io';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadProfilePhoto(File photoFile) async {
    try {
      return await remoteDataSource.uploadProfilePhoto(photoFile);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
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
  }) async {
    try {
      return await remoteDataSource.submitKyc(
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
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<KycEntity> getKycStatus() async {
    try {
      return await remoteDataSource.getKycStatus();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<BankDetailsEntity> updateBankDetails({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    try {
      return await remoteDataSource.updateBankDetails(
        accountHolder: accountHolder,
        bankName: bankName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        upiId: upiId,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> updateEmergencyContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    try {
      await remoteDataSource.updateEmergencyContact(
        name: name,
        phone: phone,
        relation: relation,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
