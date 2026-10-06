import 'package:equatable/equatable.dart';
import '../../domain/entities/bank_details_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfilePhotoUploaded extends ProfileState {
  final String avatarUrl;

  const ProfilePhotoUploaded({required this.avatarUrl});

  @override
  List<Object?> get props => [avatarUrl];
}

class BankDetailsUpdated extends ProfileState {
  final BankDetailsEntity bankDetails;

  const BankDetailsUpdated({required this.bankDetails});

  @override
  List<Object?> get props => [bankDetails];
}

class EmergencyContactUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  final Map<String, List<String>> errors;

  const ProfileError({
    required this.message,
    this.errors = const {},
  });

  @override
  List<Object?> get props => [message, errors];
}
