import 'package:freska_customer/core/network/api_client.dart';

class CustomerCartRepository {
  final ApiClient _apiClient;

  CustomerCartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getCart() async {
    final response = await _apiClient.get('/customer/cart');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> addItem({required int menuItemId, int quantity = 1}) async {
    final response = await _apiClient.post(
      '/customer/cart/items',
      data: {
        'menu_item_id': menuItemId,
        'quantity': quantity,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message'] ?? 'Failed to add item to cart.');
  }

  Future<Map<String, dynamic>> updateQuantity({required int itemId, required int quantity}) async {
    final response = await _apiClient.put(
      '/customer/cart/items/$itemId',
      data: {'quantity': quantity},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update cart quantity.');
  }

  Future<void> clearCart() async {
    await _apiClient.delete('/customer/cart');
  }
}
