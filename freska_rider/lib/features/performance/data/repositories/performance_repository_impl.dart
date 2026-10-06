import '../../../../core/network/api_client.dart';
import '../../domain/entities/performance_metrics_entity.dart';
import '../../domain/repositories/performance_repository.dart';
import '../models/performance_metrics_model.dart';

class PerformanceRepositoryImpl implements PerformanceRepository {
  final ApiClient apiClient;

  PerformanceRepositoryImpl({required this.apiClient});

  @override
  Future<PerformanceMetricsEntity> getMetrics() async {
    final response = await apiClient.get('/rider/performance');
    final data = response.data['data'] as Map<String, dynamic>;
    return PerformanceMetricsModel.fromJson(data);
  }

  @override
  Future<List<dynamic>> getReviews({int page = 1}) async {
    final response =
        await apiClient.get('/rider/performance/reviews?page=$page');
    return response.data['data']['data'] as List<dynamic>;
  }
}
