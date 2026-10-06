import 'package:equatable/equatable.dart';
import '../../domain/entities/cod_summary_entity.dart';

abstract class CodState extends Equatable {
  const CodState();
  @override
  List<Object?> get props => [];
}

class CodInitial extends CodState {}

class CodLoading extends CodState {}

class CodLoaded extends CodState {
  final CodSummaryEntity summary;
  final List<dynamic> pendingOrders;

  const CodLoaded({required this.summary, required this.pendingOrders});

  @override
  List<Object?> get props => [summary, pendingOrders];
}

class CodRemittanceSuccess extends CodState {}

class CodError extends CodState {
  final String message;
  const CodError({required this.message});
  @override
  List<Object?> get props => [message];
}
