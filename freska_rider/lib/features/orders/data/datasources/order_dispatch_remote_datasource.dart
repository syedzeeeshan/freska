import 'package:freska_rider/config/network_constants.dart';
import 'package:freska_rider/core/network/api_client.dart';
import 'package:freska_rider/features/orders/data/models/active_order_model.dart';

abstract class OrderDispatchRemoteDataSource {
  Future<ActiveOrderModel?> getActiveOrder();

  Future<bool> acceptOrder({
    required int orderId,
    required double latitude,
    required double longitude,
  });

  Future<bool> rejectOrder({
    required int orderId,
    required String reason,
  });
}

class OrderDispatchRemoteDataSourceImpl
    implements OrderDispatchRemoteDataSource {
  final ApiClient apiClient;

  OrderDispatchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ActiveOrderModel?> getActiveOrder() async {
    final response = await apiClient.get(NetworkConstants.endpointActiveOrder);
    final data = response.data['data'] as Map<String, dynamic>;

    final hasActiveOrder = data['has_active_order'] as bool? ?? false;
    if (!hasActiveOrder || data['order'] == null) {
      return null;
    }

    return ActiveOrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }

  @override
  Future<bool> acceptOrder({
    required int orderId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointAcceptOrder(orderId),
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return response.data['success'] as bool? ?? true;
  }

  @override
  Future<bool> rejectOrder({
    required int orderId,
    required String reason,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointRejectOrder(orderId),
      data: {
        'reason': reason,
      },
    );

    return response.data['success'] as bool? ?? true;
  }
}
