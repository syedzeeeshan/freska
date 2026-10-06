import 'package:freska_rider/config/network_constants.dart';
import 'package:freska_rider/core/network/api_client.dart';
import 'package:freska_rider/features/dashboard/data/models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getDashboardSummary();

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

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response =
        await apiClient.get(NetworkConstants.endpointDashboardSummary);
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardSummaryModel.fromJson(data);
  }

  @override
  Future<bool> toggleDuty({
    required bool isOnline,
    double? latitude,
    double? longitude,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointDutyToggle,
      data: {
        'is_online': isOnline,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return data['is_online'] as bool? ?? isOnline;
  }

  @override
  Future<void> sendLocationHeartbeat({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    int? batteryPercentage,
    required bool isMock,
  }) async {
    await apiClient.post(
      NetworkConstants.endpointLocationHeartbeat,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        if (batteryPercentage != null) 'battery_percentage': batteryPercentage,
        'is_mock': isMock,
      },
    );
  }
}
