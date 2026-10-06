import 'package:equatable/equatable.dart';

/// Events for the order fulfillment lifecycle — Module 4.
abstract class OrderLifecycleEvent extends Equatable {
  const OrderLifecycleEvent();
  @override
  List<Object?> get props => [];
}

/// Rider pressed "Mark Arrived at Vendor"
class MarkArrivedAtVendorEvent extends OrderLifecycleEvent {
  final int orderId;
  final double latitude;
  final double longitude;

  const MarkArrivedAtVendorEvent({
    required this.orderId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [orderId, latitude, longitude];
}

/// Rider swiped "Swipe to Pick Up" after verifying checklist
class PickupOrderEvent extends OrderLifecycleEvent {
  final int orderId;
  final double latitude;
  final double longitude;
  final bool packageVerified;

  const PickupOrderEvent({
    required this.orderId,
    required this.latitude,
    required this.longitude,
    required this.packageVerified,
  });

  @override
  List<Object?> get props => [orderId, latitude, longitude, packageVerified];
}

/// Rider pressed "Arrived at Customer"
class MarkArrivedAtCustomerEvent extends OrderLifecycleEvent {
  final int orderId;
  final double latitude;
  final double longitude;

  const MarkArrivedAtCustomerEvent({
    required this.orderId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [orderId, latitude, longitude];
}

/// Rider swiped "Swipe to Complete Delivery" with OTP + proof
class ConfirmDeliveryEvent extends OrderLifecycleEvent {
  final int orderId;
  final String otp;
  final double latitude;
  final double longitude;
  final String? proofPhotoPath;
  final String? signaturePath;

  const ConfirmDeliveryEvent({
    required this.orderId,
    required this.otp,
    required this.latitude,
    required this.longitude,
    this.proofPhotoPath,
    this.signaturePath,
  });

  @override
  List<Object?> get props =>
      [orderId, otp, latitude, longitude, proofPhotoPath, signaturePath];
}
