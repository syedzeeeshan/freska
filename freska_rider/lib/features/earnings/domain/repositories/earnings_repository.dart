import '../entities/earnings_summary_entity.dart';

abstract class EarningsRepository {
  Future<EarningsSummaryEntity> getEarningsSummary();
  Future<List<dynamic>> getEarningsHistory({int page = 1});
  Future<List<dynamic>> getPayoutStatements();
}
