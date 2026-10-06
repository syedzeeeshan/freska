import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_rider/features/orders/domain/repositories/order_lifecycle_repository.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_event.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_lifecycle_state.dart';

/// BLoC for the Order Fulfillment Lifecycle (Module 4).
///
/// Manages state for all order status transitions:
///  accepted → arrived_vendor → in_transit → arrived_customer → delivered
class OrderLifecycleBloc
    extends Bloc<OrderLifecycleEvent, OrderLifecycleState> {
  final OrderLifecycleRepository repository;

  OrderLifecycleBloc({required this.repository})
      : super(const OrderLifecycleIdle()) {
    on<MarkArrivedAtVendorEvent>(_onMarkArrivedAtVendor);
    on<PickupOrderEvent>(_onPickupOrder);
    on<MarkArrivedAtCustomerEvent>(_onMarkArrivedAtCustomer);
    on<ConfirmDeliveryEvent>(_onConfirmDelivery);
  }

  Future<void> _onMarkArrivedAtVendor(
    MarkArrivedAtVendorEvent event,
    Emitter<OrderLifecycleState> emit,
  ) async {
    emit(
        const OrderLifecycleLoading(actionLabel: 'Marking arrival at vendor…'));
    try {
      final result = await repository.arriveAtVendor(
        orderId: event.orderId,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(result);
    } catch (e) {
      emit(OrderLifecycleError(
        message: _extractMessage(e),
        errorCode: 'ERR_ARRIVE_VENDOR',
      ));
    }
  }

  Future<void> _onPickupOrder(
    PickupOrderEvent event,
    Emitter<OrderLifecycleState> emit,
  ) async {
    emit(const OrderLifecycleLoading(actionLabel: 'Confirming pickup…'));
    try {
      final result = await repository.pickupOrder(
        orderId: event.orderId,
        latitude: event.latitude,
        longitude: event.longitude,
        packageVerified: event.packageVerified,
      );
      emit(result);
    } catch (e) {
      emit(OrderLifecycleError(
        message: _extractMessage(e),
        errorCode: 'ERR_PICKUP',
      ));
    }
  }

  Future<void> _onMarkArrivedAtCustomer(
    MarkArrivedAtCustomerEvent event,
    Emitter<OrderLifecycleState> emit,
  ) async {
    emit(const OrderLifecycleLoading(
        actionLabel: 'Marking arrival at customer…'));
    try {
      final result = await repository.arriveAtCustomer(
        orderId: event.orderId,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(result);
    } catch (e) {
      emit(OrderLifecycleError(
        message: _extractMessage(e),
        errorCode: 'ERR_ARRIVE_CUSTOMER',
      ));
    }
  }

  Future<void> _onConfirmDelivery(
    ConfirmDeliveryEvent event,
    Emitter<OrderLifecycleState> emit,
  ) async {
    emit(const OrderLifecycleLoading(actionLabel: 'Confirming delivery…'));
    try {
      final result = await repository.confirmDelivery(
        orderId: event.orderId,
        otp: event.otp,
        latitude: event.latitude,
        longitude: event.longitude,
        proofPhotoPath: event.proofPhotoPath,
        signaturePath: event.signaturePath,
      );
      emit(result);
    } catch (e) {
      emit(OrderLifecycleError(
        message: _extractMessage(e),
        errorCode: 'ERR_CONFIRM_DELIVERY',
      ));
    }
  }

  String _extractMessage(Object e) {
    // Attempt to extract backend validation message from DioException
    if (e is Exception) {
      final str = e.toString();
      if (str.contains('DioException')) {
        return 'Server error. Please try again.';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
