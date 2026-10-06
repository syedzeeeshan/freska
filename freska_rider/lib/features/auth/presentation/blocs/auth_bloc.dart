import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorageService secureStorage;

  AuthBloc({
    required this.authRepository,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthenticatedState(user: user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final seconds = await authRepository.sendOtp(event.phone);
      emit(OtpSentState(phone: event.phone, resendInSeconds: seconds));
    } on ValidationFailure catch (e) {
      emit(AuthErrorState(message: e.message, errors: e.errors, code: e.code));
    } on Failure catch (e) {
      emit(AuthErrorState(message: e.message, code: e.code));
    } catch (e) {
      emit(const AuthErrorState(
          message: 'Failed to send OTP. Please try again.'));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final deviceId = await secureStorage.getOrCreateDeviceId();
      final user = await authRepository.verifyOtp(
        phone: event.phone,
        otp: event.otp,
        deviceId: deviceId,
        deviceModel: 'Android/iOS Device',
        osVersion: 'Mobile OS',
        appVersion: '1.0.0',
      );
      emit(AuthenticatedState(user: user));
    } on ValidationFailure catch (e) {
      emit(AuthErrorState(message: e.message, errors: e.errors, code: e.code));
    } on Failure catch (e) {
      emit(AuthErrorState(message: e.message, code: e.code));
    } catch (e) {
      emit(const AuthErrorState(
          message: 'Verification failed. Please verify your code.'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
    } catch (_) {
      // Always emit unauthenticated even if network call failed during logout
    }
    emit(UnauthenticatedState());
  }
}
