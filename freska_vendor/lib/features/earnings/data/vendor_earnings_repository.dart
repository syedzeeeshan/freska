import 'package:freska_vendor/core/network/api_client.dart';

class VendorEarningsRepository {
  final ApiClient _apiClient;

  VendorEarningsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getEarnings() async {
    final response = await _apiClient.get('/vendor/earnings');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message'] ?? 'Failed to load store earnings.');
  }
}
