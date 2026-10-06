import 'package:freska_customer/core/network/api_client.dart';

class CustomerOrdersRepository {
  final ApiClient _apiClient;

  CustomerOrdersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> placeOrder({
    required int addressId,
    required String paymentMode,
    String? instructions,
  }) async {
    final response = await _apiClient.post(
      '/customer/orders',
      data: {
        'address_id': addressId,
        'payment_mode': paymentMode,
        'delivery_instructions': instructions,
      },
    );

    if (response.statusCode == 201 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message'] ?? 'Failed to place order.');
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _apiClient.get('/customer/orders');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getTrackingData(int orderId) async {
    final response = await _apiClient.get('/customer/orders/$orderId/track');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load tracking data.');
  }
}
