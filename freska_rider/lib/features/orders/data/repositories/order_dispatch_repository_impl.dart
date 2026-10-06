import 'package:freska_rider/features/orders/data/datasources/order_dispatch_remote_datasource.dart';
import 'package:freska_rider/features/orders/domain/entities/active_order_entity.dart';
import 'package:freska_rider/features/orders/domain/repositories/order_dispatch_repository.dart';

class OrderDispatchRepositoryImpl implements OrderDispatchRepository {
  final OrderDispatchRemoteDataSource remoteDataSource;

  OrderDispatchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ActiveOrderEntity?> getActiveOrder() {
    return remoteDataSource.getActiveOrder();
  }

  @override
  Future<bool> acceptOrder({
    required int orderId,
    required double latitude,
    required double longitude,
  }) {
    return remoteDataSource.acceptOrder(
      orderId: orderId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<bool> rejectOrder({
    required int orderId,
    required String reason,
  }) {
    return remoteDataSource.rejectOrder(
      orderId: orderId,
      reason: reason,
    );
  }
}
