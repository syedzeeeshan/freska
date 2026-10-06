import 'package:equatable/equatable.dart';
import '../../domain/entities/performance_metrics_entity.dart';

abstract class PerformanceState extends Equatable {
  const PerformanceState();
  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}

class PerformanceLoading extends PerformanceState {}

class PerformanceLoaded extends PerformanceState {
  final PerformanceMetricsEntity metrics;
  final List<dynamic> reviews;

  const PerformanceLoaded({required this.metrics, required this.reviews});

  @override
  List<Object?> get props => [metrics, reviews];
}

class PerformanceError extends PerformanceState {
  final String message;
  const PerformanceError({required this.message});
  @override
  List<Object?> get props => [message];
}
