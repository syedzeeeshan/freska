import 'package:freska_rider/features/orders/domain/entities/active_order_entity.dart';

abstract class OrderDispatchRepository {
  Future<ActiveOrderEntity?> getActiveOrder();

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
