import 'package:freska_rider/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:freska_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:freska_rider/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardSummaryEntity> getDashboardSummary() {
    return remoteDataSource.getDashboardSummary();
  }

  @override
  Future<bool> toggleDuty({
    required bool isOnline,
    double? latitude,
    double? longitude,
  }) {
    return remoteDataSource.toggleDuty(
      isOnline: isOnline,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<void> sendLocationHeartbeat({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    int? batteryPercentage,
    required bool isMock,
  }) {
    return remoteDataSource.sendLocationHeartbeat(
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      speed: speed,
      batteryPercentage: batteryPercentage,
      isMock: isMock,
    );
  }
}
