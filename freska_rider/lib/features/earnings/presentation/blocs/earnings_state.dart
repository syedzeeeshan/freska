import 'package:equatable/equatable.dart';
import '../../domain/entities/earnings_summary_entity.dart';

abstract class EarningsState extends Equatable {
  const EarningsState();
  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final EarningsSummaryEntity summary;

  const EarningsLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class EarningsError extends EarningsState {
  final String message;

  const EarningsError({required this.message});

  @override
  List<Object?> get props => [message];
}
