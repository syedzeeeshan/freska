import 'package:freska_vendor/core/network/api_client.dart';

class VendorOrdersRepository {
  final ApiClient _apiClient;

  VendorOrdersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Map<String, dynamic>>> getOrders({String? status}) async {
    final response = await _apiClient.get(
      '/vendor/orders',
      queryParameters: status != null ? {'status': status} : null,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    final response = await _apiClient.get('/vendor/orders/$orderId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load order details.');
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await _apiClient.put(
      '/vendor/orders/$orderId/status',
      data: {'status': status},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message'] ?? 'Failed to update order status.');
  }

  Future<void> cancelOrder({required int orderId, required String reason}) async {
    final response = await _apiClient.post(
      '/vendor/orders/$orderId/cancel',
      data: {'reason': reason},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to cancel order.');
    }
  }
}
