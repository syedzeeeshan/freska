import 'package:freska_customer/core/network/api_client.dart';

class DiscoveryRepository {
  final ApiClient _apiClient;

  DiscoveryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiClient.get('/customer/categories');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getVendors({String? category}) async {
    final response = await _apiClient.get(
      '/customer/vendors',
      queryParameters: category != null ? {'category': category} : null,
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> search(String query) async {
    final response = await _apiClient.get(
      '/customer/search',
      queryParameters: {'q': query},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data'] as Map);
    }
    return {'vendors': [], 'items': []};
  }
}
