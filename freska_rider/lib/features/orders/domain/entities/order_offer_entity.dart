import 'package:equatable/equatable.dart';

class OrderOfferEntity extends Equatable {
  final int id;
  final int orderId;
  final String orderNumber;
  final String vendorName;
  final String vendorAddress;
  final double vendorLatitude;
  final double vendorLongitude;
  final String deliveryArea;
  final double estimatedDistanceKm;
  final int estimatedDurationMins;
  final double totalRiderPayout;
  final bool isColdChain;
  final bool isFragile;
  final int itemCount;
  final String paymentMode;
  final double codAmount;
  final DateTime offeredAt;
  final DateTime expiresAt;
  final int remainingSeconds;

  const OrderOfferEntity({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.vendorName,
    required this.vendorAddress,
    required this.vendorLatitude,
    required this.vendorLongitude,
    required this.deliveryArea,
    required this.estimatedDistanceKm,
    required this.estimatedDurationMins,
    required this.totalRiderPayout,
    required this.isColdChain,
    required this.isFragile,
    required this.itemCount,
    required this.paymentMode,
    required this.codAmount,
    required this.offeredAt,
    required this.expiresAt,
    required this.remainingSeconds,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        orderNumber,
        vendorName,
        vendorAddress,
        vendorLatitude,
        vendorLongitude,
        deliveryArea,
        estimatedDistanceKm,
        estimatedDurationMins,
        totalRiderPayout,
        isColdChain,
        isFragile,
        itemCount,
        paymentMode,
        codAmount,
        offeredAt,
        expiresAt,
        remainingSeconds,
      ];
}
