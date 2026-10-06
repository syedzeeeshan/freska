import 'package:freska_customer/core/network/api_client.dart';

class VendorMenuRepository {
  final ApiClient _apiClient;

  VendorMenuRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getVendorDetails(int vendorId) async {
    final response = await _apiClient.get('/customer/vendors/$vendorId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load vendor menu.');
  }
}
