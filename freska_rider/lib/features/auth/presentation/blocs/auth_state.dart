import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phone;
  final int resendInSeconds;

  const OtpSentState({
    required this.phone,
    required this.resendInSeconds,
  });

  @override
  List<Object?> get props => [phone, resendInSeconds];
}

class AuthenticatedState extends AuthState {
  final UserEntity user;

  const AuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  final String? code;
  final Map<String, List<String>> errors;

  const AuthErrorState({
    required this.message,
    this.code,
    this.errors = const {},
  });

  @override
  List<Object?> get props => [message, code, errors];
}
