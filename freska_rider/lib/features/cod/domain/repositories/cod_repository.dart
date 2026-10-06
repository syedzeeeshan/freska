import '../entities/cod_summary_entity.dart';

abstract class CodRepository {
  Future<CodSummaryEntity> getCodSummary();
  Future<List<dynamic>> getPendingCodOrders();
  Future<void> submitHandover({
    required double amount,
    required String handoverMethod,
    String? reference,
  });
}
