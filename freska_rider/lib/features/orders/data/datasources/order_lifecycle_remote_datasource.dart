import 'package:dio/dio.dart';
import 'package:freska_rider/config/network_constants.dart';
import 'package:freska_rider/core/network/api_client.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_state.dart';

abstract class OrderLifecycleRemoteDataSource {
  Future<ArrivedAtVendorSuccess> arriveAtVendor({
    required int orderId,
    required double latitude,
    required double longitude,
  });

  Future<OrderPickedUpSuccess> pickupOrder({
    required int orderId,
    required double latitude,
    required double longitude,
    required bool packageVerified,
  });

  Future<ArrivedAtCustomerSuccess> arriveAtCustomer({
    required int orderId,
    required double latitude,
    required double longitude,
  });

  Future<DeliveryConfirmed> confirmDelivery({
    required int orderId,
    required String otp,
    required double latitude,
    required double longitude,
    String? proofPhotoPath,
    String? signaturePath,
  });
}

class OrderLifecycleRemoteDataSourceImpl
    implements OrderLifecycleRemoteDataSource {
  final ApiClient apiClient;

  OrderLifecycleRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ArrivedAtVendorSuccess> arriveAtVendor({
    required int orderId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointArriveVendor(orderId),
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ArrivedAtVendorSuccess(
      status: data['status'] as String,
      arrivedVendorAt: data['arrived_vendor_at'] as String? ?? '',
    );
  }

  @override
  Future<OrderPickedUpSuccess> pickupOrder({
    required int orderId,
    required double latitude,
    required double longitude,
    required bool packageVerified,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointPickupOrder(orderId),
      data: {
        'package_verified': packageVerified,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return OrderPickedUpSuccess(
      status: data['status'] as String,
      customerFullAddress: data['customer_full_address'] as String? ?? '',
      customerPhone: data['customer_phone'] as String? ?? '',
    );
  }

  @override
  Future<ArrivedAtCustomerSuccess> arriveAtCustomer({
    required int orderId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiClient.post(
      NetworkConstants.endpointArriveCustomer(orderId),
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ArrivedAtCustomerSuccess(
      status: data['status'] as String,
    );
  }

  @override
  Future<DeliveryConfirmed> confirmDelivery({
    required int orderId,
    required String otp,
    required double latitude,
    required double longitude,
    String? proofPhotoPath,
    String? signaturePath,
  }) async {
    final formData = FormData.fromMap({
      'otp': otp,
      'latitude': latitude,
      'longitude': longitude,
      if (proofPhotoPath != null)
        'proof_photo': await MultipartFile.fromFile(
          proofPhotoPath,
          filename:
              'proof_${orderId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      if (signaturePath != null)
        'signature': await MultipartFile.fromFile(
          signaturePath,
          filename:
              'sig_${orderId}_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
    });

    final response = await apiClient.post(
      NetworkConstants.endpointConfirmDelivery(orderId),
      data: formData,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return DeliveryConfirmed(
      orderId: data['order_id'] as int,
      status: data['status'] as String,
      deliveredAt: data['delivered_at'] as String? ?? '',
      earningsCredited: (data['earnings_credited'] as num).toDouble(),
      codCollected: (data['cod_collected'] as num? ?? 0).toDouble(),
    );
  }
}
