import 'dart:io';
import '../repositories/onboarding_repository.dart';

class UploadProfilePhotoUseCase {
  final OnboardingRepository repository;

  UploadProfilePhotoUseCase({required this.repository});

  Future<String> call(File photoFile) async {
    return await repository.uploadProfilePhoto(photoFile);
  }
}
