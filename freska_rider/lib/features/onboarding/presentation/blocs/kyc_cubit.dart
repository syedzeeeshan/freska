import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  final OnboardingRepository onboardingRepository;

  KycCubit({required this.onboardingRepository}) : super(KycInitial());

  Future<void> checkKycStatus() async {
    emit(KycLoading());
    try {
      final status = await onboardingRepository.getKycStatus();
      emit(KycStatusLoaded(kyc: status));
    } on Failure catch (e) {
      emit(KycError(message: e.message));
    } catch (e) {
      emit(const KycError(message: 'Failed to retrieve KYC status.'));
    }
  }

  Future<void> submitKyc({
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
    emit(KycLoading());
    try {
      final kyc = await onboardingRepository.submitKyc(
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
      emit(KycSubmittedSuccess(kyc: kyc));
    } on ValidationFailure catch (e) {
      emit(KycError(message: e.message, errors: e.errors));
    } on Failure catch (e) {
      emit(KycError(message: e.message));
    } catch (e) {
      emit(const KycError(
          message:
              'KYC submission failed. Please verify documents and retry.'));
    }
  }
}
