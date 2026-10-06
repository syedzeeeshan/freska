import 'package:equatable/equatable.dart';

/// States for the order fulfillment lifecycle — Module 4.
abstract class OrderLifecycleState extends Equatable {
  const OrderLifecycleState();
  @override
  List<Object?> get props => [];
}

/// Default idle state — no active lifecycle transition occurring.
class OrderLifecycleIdle extends OrderLifecycleState {
  const OrderLifecycleIdle();
}

/// A lifecycle API call is in progress.
class OrderLifecycleLoading extends OrderLifecycleState {
  final String actionLabel;
  const OrderLifecycleLoading({required this.actionLabel});
  @override
  List<Object?> get props => [actionLabel];
}

/// Rider has successfully arrived at vendor store.
class ArrivedAtVendorSuccess extends OrderLifecycleState {
  final String status;
  final String arrivedVendorAt;
  const ArrivedAtVendorSuccess({
    required this.status,
    required this.arrivedVendorAt,
  });
  @override
  List<Object?> get props => [status, arrivedVendorAt];
}

/// Order has been picked up. Customer PII is now unmasked.
class OrderPickedUpSuccess extends OrderLifecycleState {
  final String status;
  final String customerFullAddress;
  final String customerPhone;
  const OrderPickedUpSuccess({
    required this.status,
    required this.customerFullAddress,
    required this.customerPhone,
  });
  @override
  List<Object?> get props => [status, customerFullAddress, customerPhone];
}

/// Rider has arrived at the customer's location.
class ArrivedAtCustomerSuccess extends OrderLifecycleState {
  final String status;
  const ArrivedAtCustomerSuccess({required this.status});
  @override
  List<Object?> get props => [status];
}

/// Delivery has been confirmed — shows confetti celebration.
class DeliveryConfirmed extends OrderLifecycleState {
  final int orderId;
  final String status;
  final String deliveredAt;
  final double earningsCredited;
  final double codCollected;
  const DeliveryConfirmed({
    required this.orderId,
    required this.status,
    required this.deliveredAt,
    required this.earningsCredited,
    required this.codCollected,
  });
  @override
  List<Object?> get props =>
      [orderId, status, deliveredAt, earningsCredited, codCollected];
}

/// An error occurred during a lifecycle transition.
class OrderLifecycleError extends OrderLifecycleState {
  final String message;
  final String errorCode;
  const OrderLifecycleError({required this.message, required this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}
