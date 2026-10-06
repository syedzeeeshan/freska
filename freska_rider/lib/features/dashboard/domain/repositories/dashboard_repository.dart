import 'package:freska_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';

abstract class DashboardRepository {
  Future<DashboardSummaryEntity> getDashboardSummary();

  Future<bool> toggleDuty({
    required bool isOnline,
    double? latitude,
    double? longitude,
  });

  Future<void> sendLocationHeartbeat({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    int? batteryPercentage,
    required bool isMock,
  });
}
