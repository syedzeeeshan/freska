import 'package:freska_vendor/core/network/api_client.dart';

class VendorMenuRepository {
  final ApiClient _apiClient;

  VendorMenuRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final response = await _apiClient.get('/vendor/menu');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<bool> toggleAvailability(int itemId) async {
    final response = await _apiClient.patch('/vendor/menu/$itemId/toggle-availability');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data']['is_available'] as bool;
    }
    throw Exception('Failed to update item availability.');
  }

  Future<Map<String, dynamic>> saveMenuItem({
    int? id,
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required int categoryId,
    required bool isAvailable,
    required bool isColdChain,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'category_id': categoryId,
      'is_available': isAvailable,
      'is_cold_chain': isColdChain,
    };

    if (id == null) {
      final response = await _apiClient.post('/vendor/menu', data: data);
      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
    } else {
      final response = await _apiClient.put('/vendor/menu/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
    }

    throw Exception('Failed to save menu item.');
  }

  Future<void> deleteMenuItem(int id) async {
    final response = await _apiClient.delete('/vendor/menu/$id');
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception('Failed to delete menu item.');
    }
  }
}
