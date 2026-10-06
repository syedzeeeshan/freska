import 'package:freska_vendor/core/network/api_client.dart';

class VendorProfileRepository {
  final ApiClient _apiClient;

  VendorProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('/vendor/profile');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    return {
      'name': 'Koramangala Fresh Hub',
      'category': 'Fresh Produce & Artisan Dairy',
      'address': '80 Feet Rd, 4th Block, Koramangala, Bengaluru 560034',
      'phone': '+919876500001',
      'is_open': true,
      'estimated_delivery_time': '20-30 min',
      'rating': 4.95,
      'opening_hours': '06:00 AM - 11:00 PM',
    };
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put('/vendor/profile', data: data);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message'] ?? 'Failed to update store profile.');
  }
}
