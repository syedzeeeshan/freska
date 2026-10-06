import 'package:freska_vendor/core/network/api_client.dart';

class VendorDashboardRepository {
  final ApiClient _apiClient;

  VendorDashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _apiClient.get('/vendor/dashboard');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message'] ?? 'Failed to load dashboard.');
  }

  Future<bool> toggleStoreStatus() async {
    final response = await _apiClient.post('/vendor/status/toggle');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data']['is_open'] as bool;
    }
    throw Exception('Failed to update store status.');
  }
}
