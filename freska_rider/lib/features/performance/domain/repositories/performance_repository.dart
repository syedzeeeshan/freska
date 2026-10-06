import '../entities/performance_metrics_entity.dart';

abstract class PerformanceRepository {
  Future<PerformanceMetricsEntity> getMetrics();
  Future<List<dynamic>> getReviews({int page = 1});
}
