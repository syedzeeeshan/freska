import 'package:equatable/equatable.dart';

abstract class CodEvent extends Equatable {
  const CodEvent();
  @override
  List<Object?> get props => [];
}

class LoadCodSummaryEvent extends CodEvent {
  const LoadCodSummaryEvent();
}

class SubmitRemittanceEvent extends CodEvent {
  final double amount;
  final String method;
  final String? reference;

  const SubmitRemittanceEvent({
    required this.amount,
    required this.method,
    this.reference,
  });

  @override
  List<Object?> get props => [amount, method, reference];
}
