import '../../../../core/network/api_client.dart';
import '../../domain/entities/cod_summary_entity.dart';
import '../../domain/repositories/cod_repository.dart';

class CodRepositoryImpl implements CodRepository {
  final ApiClient apiClient;

  CodRepositoryImpl({required this.apiClient});

  @override
  Future<CodSummaryEntity> getCodSummary() async {
    final response = await apiClient.get('/rider/cod/summary');
    final data = response.data['data'] as Map<String, dynamic>;

    return CodSummaryEntity(
      currentCashInHand:
          ((data['current_cash_in_hand'] ?? 0.0) as num).toDouble(),
      maxCashLimit: ((data['max_cash_limit'] ?? 5000.0) as num).toDouble(),
      pendingSettlementCount: (data['pending_settlement_count'] ?? 0) as int,
      isBlockedFromAssignments:
          (data['is_blocked_from_assignments'] ?? false) as bool,
      headroomAvailable:
          ((data['headroom_available'] ?? 0.0) as num).toDouble(),
    );
  }

  @override
  Future<List<dynamic>> getPendingCodOrders() async {
    final response = await apiClient.get('/rider/cod/orders');
    return response.data['data'] as List<dynamic>;
  }

  @override
  Future<void> submitHandover({
    required double amount,
    required String handoverMethod,
    String? reference,
  }) async {
    await apiClient.post('/rider/cod/handover', data: {
      'amount': amount,
      'handover_method': handoverMethod,
      'handover_reference': reference,
    });
  }
}
