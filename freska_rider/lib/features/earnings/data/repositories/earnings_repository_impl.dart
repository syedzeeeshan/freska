import '../../../../core/network/api_client.dart';
import '../../domain/entities/earnings_summary_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../models/earnings_summary_model.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final ApiClient apiClient;

  EarningsRepositoryImpl({required this.apiClient});

  @override
  Future<EarningsSummaryEntity> getEarningsSummary() async {
    final response = await apiClient.get('/rider/earnings/summary');
    final data = response.data['data'] as Map<String, dynamic>;
    return EarningsSummaryModel.fromJson(data);
  }

  @override
  Future<List<dynamic>> getEarningsHistory({int page = 1}) async {
    final response =
        await apiClient.get('/rider/earnings/history?page=$page');
    return response.data['data']['data'] as List<dynamic>;
  }

  @override
  Future<List<dynamic>> getPayoutStatements() async {
    final response = await apiClient.get('/rider/payouts');
    return response.data['data']['data'] as List<dynamic>;
  }
}
