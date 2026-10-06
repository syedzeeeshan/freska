import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final OnboardingRepository onboardingRepository;

  ProfileCubit({required this.onboardingRepository}) : super(ProfileInitial());

  Future<void> uploadPhoto(File file) async {
    emit(ProfileLoading());
    try {
      final url = await onboardingRepository.uploadProfilePhoto(file);
      emit(ProfilePhotoUploaded(avatarUrl: url));
    } on Failure catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(const ProfileError(
          message: 'Failed to upload photo. Please try again.'));
    }
  }

  Future<void> updateBankDetails({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    emit(ProfileLoading());
    try {
      final details = await onboardingRepository.updateBankDetails(
        accountHolder: accountHolder,
        bankName: bankName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        upiId: upiId,
      );
      emit(BankDetailsUpdated(bankDetails: details));
    } on ValidationFailure catch (e) {
      emit(ProfileError(message: e.message, errors: e.errors));
    } on Failure catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(const ProfileError(message: 'Failed to update bank details.'));
    }
  }

  Future<void> updateEmergencyContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    emit(ProfileLoading());
    try {
      await onboardingRepository.updateEmergencyContact(
        name: name,
        phone: phone,
        relation: relation,
      );
      emit(EmergencyContactUpdated());
    } on ValidationFailure catch (e) {
      emit(ProfileError(message: e.message, errors: e.errors));
    } on Failure catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(const ProfileError(message: 'Failed to update emergency contact.'));
    }
  }
}
