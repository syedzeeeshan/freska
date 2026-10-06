import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/performance_repository.dart';
import 'performance_state.dart';

class PerformanceCubit extends Cubit<PerformanceState> {
  final PerformanceRepository repository;

  PerformanceCubit({required this.repository}) : super(PerformanceInitial());

  Future<void> loadPerformance() async {
    emit(PerformanceLoading());
    try {
      final metrics = await repository.getMetrics();
      final reviews = await repository.getReviews();
      emit(PerformanceLoaded(metrics: metrics, reviews: reviews));
    } catch (e) {
      emit(PerformanceError(
          message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
