import 'package:equatable/equatable.dart';
import '../../domain/entities/kyc_entity.dart';

abstract class KycState extends Equatable {
  const KycState();

  @override
  List<Object?> get props => [];
}

class KycInitial extends KycState {}

class KycLoading extends KycState {}

class KycStatusLoaded extends KycState {
  final KycEntity kyc;

  const KycStatusLoaded({required this.kyc});

  @override
  List<Object?> get props => [kyc];
}

class KycSubmittedSuccess extends KycState {
  final KycEntity kyc;

  const KycSubmittedSuccess({required this.kyc});

  @override
  List<Object?> get props => [kyc];
}

class KycError extends KycState {
  final String message;
  final Map<String, List<String>> errors;

  const KycError({
    required this.message,
    this.errors = const {},
  });

  @override
  List<Object?> get props => [message, errors];
}
