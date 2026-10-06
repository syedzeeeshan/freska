import 'package:freska_rider/features/orders/data/datasources/order_lifecycle_remote_datasource.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_state.dart';

abstract class OrderLifecycleRepository {
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

class OrderLifecycleRepositoryImpl implements OrderLifecycleRepository {
  final OrderLifecycleRemoteDataSource remoteDataSource;

  OrderLifecycleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ArrivedAtVendorSuccess> arriveAtVendor({
    required int orderId,
    required double latitude,
    required double longitude,
  }) =>
      remoteDataSource.arriveAtVendor(
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  Future<OrderPickedUpSuccess> pickupOrder({
    required int orderId,
    required double latitude,
    required double longitude,
    required bool packageVerified,
  }) =>
      remoteDataSource.pickupOrder(
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
        packageVerified: packageVerified,
      );

  @override
  Future<ArrivedAtCustomerSuccess> arriveAtCustomer({
    required int orderId,
    required double latitude,
    required double longitude,
  }) =>
      remoteDataSource.arriveAtCustomer(
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  Future<DeliveryConfirmed> confirmDelivery({
    required int orderId,
    required String otp,
    required double latitude,
    required double longitude,
    String? proofPhotoPath,
    String? signaturePath,
  }) =>
      remoteDataSource.confirmDelivery(
        orderId: orderId,
        otp: otp,
        latitude: latitude,
        longitude: longitude,
        proofPhotoPath: proofPhotoPath,
        signaturePath: signaturePath,
      );
}
