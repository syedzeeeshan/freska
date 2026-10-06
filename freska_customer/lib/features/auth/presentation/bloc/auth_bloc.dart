import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_customer/features/auth/data/auth_repository.dart';

abstract class CustomerAuthEvent extends Equatable {
  const CustomerAuthEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends CustomerAuthEvent {
  final String phone;
  const SendOtpEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends CustomerAuthEvent {
  final String phone;
  final String otp;
  const VerifyOtpEvent({required this.phone, required this.otp});
  @override
  List<Object?> get props => [phone, otp];
}

class CheckAuthSessionEvent extends CustomerAuthEvent {}

class LogoutEvent extends CustomerAuthEvent {}

abstract class CustomerAuthState extends Equatable {
  const CustomerAuthState();
  @override
  List<Object?> get props => [];
}

class CustomerAuthInitial extends CustomerAuthState {}

class CustomerAuthLoading extends CustomerAuthState {}

class CustomerOtpSentState extends CustomerAuthState {
  final String phone;
  const CustomerOtpSentState(this.phone);
  @override
  List<Object?> get props => [phone];
}

class CustomerAuthenticatedState extends CustomerAuthState {
  final Map<String, dynamic> user;
  const CustomerAuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class CustomerUnauthenticatedState extends CustomerAuthState {}

class CustomerAuthFailureState extends CustomerAuthState {
  final String message;
  const CustomerAuthFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerAuthBloc extends Bloc<CustomerAuthEvent, CustomerAuthState> {
  final CustomerAuthRepository _repository;

  CustomerAuthBloc({required CustomerAuthRepository repository})
      : _repository = repository,
        super(CustomerAuthInitial()) {
    on<CheckAuthSessionEvent>((event, emit) async {
      emit(CustomerAuthLoading());
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        emit(const CustomerAuthenticatedState({'phone': '+919988776655', 'name': 'Priya V.'}));
      } else {
        emit(CustomerUnauthenticatedState());
      }
    });

    on<SendOtpEvent>((event, emit) async {
      emit(CustomerAuthLoading());
      try {
        await _repository.sendOtp(event.phone);
        emit(CustomerOtpSentState(event.phone));
      } catch (e) {
        emit(CustomerAuthFailureState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(CustomerAuthLoading());
      try {
        final user = await _repository.verifyOtp(phone: event.phone, otp: event.otp);
        emit(CustomerAuthenticatedState(user));
      } catch (e) {
        emit(CustomerAuthFailureState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await _repository.logout();
      emit(CustomerUnauthenticatedState());
    });
  }
}
