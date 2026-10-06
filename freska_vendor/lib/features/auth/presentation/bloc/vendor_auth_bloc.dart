import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_vendor/features/auth/data/vendor_auth_repository.dart';

abstract class VendorAuthEvent extends Equatable {
  const VendorAuthEvent();
  @override
  List<Object?> get props => [];
}

class SendVendorOtpEvent extends VendorAuthEvent {
  final String phone;
  const SendVendorOtpEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VerifyVendorOtpEvent extends VendorAuthEvent {
  final String phone;
  final String otp;
  const VerifyVendorOtpEvent({required this.phone, required this.otp});
  @override
  List<Object?> get props => [phone, otp];
}

class CheckVendorAuthSessionEvent extends VendorAuthEvent {}

class LogoutVendorEvent extends VendorAuthEvent {}

abstract class VendorAuthState extends Equatable {
  const VendorAuthState();
  @override
  List<Object?> get props => [];
}

class VendorAuthInitial extends VendorAuthState {}

class VendorAuthLoading extends VendorAuthState {}

class VendorOtpSentState extends VendorAuthState {
  final String phone;
  const VendorOtpSentState(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VendorAuthenticatedState extends VendorAuthState {
  final Map<String, dynamic> user;
  const VendorAuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class VendorUnauthenticatedState extends VendorAuthState {}

class VendorAuthFailureState extends VendorAuthState {
  final String message;
  const VendorAuthFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorAuthBloc extends Bloc<VendorAuthEvent, VendorAuthState> {
  final VendorAuthRepository _repository;

  VendorAuthBloc({required VendorAuthRepository repository})
      : _repository = repository,
        super(VendorAuthInitial()) {
    on<CheckVendorAuthSessionEvent>((event, emit) async {
      emit(VendorAuthLoading());
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        emit(const VendorAuthenticatedState({
          'phone': '+919876500001',
          'name': 'Store Manager (Koramangala Hub)',
        }));
      } else {
        emit(VendorUnauthenticatedState());
      }
    });

    on<SendVendorOtpEvent>((event, emit) async {
      emit(VendorAuthLoading());
      try {
        await _repository.sendOtp(event.phone);
        emit(VendorOtpSentState(event.phone));
      } catch (e) {
        final err = e.toString().replaceAll('Exception: ', '');
        final cleanMsg = err.contains('DioException')
            ? (err.contains('422')
                ? 'Invalid mobile number. Please enter a valid 10-digit registered number.'
                : 'Unable to connect to merchant authentication server.')
            : err;
        emit(VendorAuthFailureState(cleanMsg));
      }
    });

    on<VerifyVendorOtpEvent>((event, emit) async {
      emit(VendorAuthLoading());
      try {
        final user = await _repository.verifyOtp(phone: event.phone, otp: event.otp);
        emit(VendorAuthenticatedState(user));
      } catch (e) {
        final err = e.toString().replaceAll('Exception: ', '');
        final cleanMsg = err.contains('DioException')
            ? (err.contains('422') || err.contains('401')
                ? 'Invalid verification code. Please check your SMS OTP.'
                : 'Verification server timed out. Please try again.')
            : err;
        emit(VendorAuthFailureState(cleanMsg));
      }
    });

    on<LogoutVendorEvent>((event, emit) async {
      await _repository.logout();
      emit(VendorUnauthenticatedState());
    });
  }
}
