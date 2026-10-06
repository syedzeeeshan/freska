import 'package:equatable/equatable.dart';

class OrderVendorEntity extends Equatable {
  final int id;
  final String name;
  final String storeCode;
  final String phone;
  final String address;
  final String? landmark;
  final double latitude;
  final double longitude;
  final String? pickupInstructions;

  const OrderVendorEntity({
    required this.id,
    required this.name,
    required this.storeCode,
    required this.phone,
    required this.address,
    this.landmark,
    required this.latitude,
    required this.longitude,
    this.pickupInstructions,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        storeCode,
        phone,
        address,
        landmark,
        latitude,
        longitude,
        pickupInstructions,
      ];
}

class OrderCustomerEntity extends Equatable {
  final String name;
  final String phone;
  final String deliveryArea;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String? deliveryInstructions;

  const OrderCustomerEntity({
    required this.name,
    required this.phone,
    required this.deliveryArea,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.deliveryInstructions,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        deliveryArea,
        deliveryAddress,
        deliveryLatitude,
        deliveryLongitude,
        deliveryInstructions,
      ];
}

class OrderPackageDetailsEntity extends Equatable {
  final int itemCount;
  final bool isFragile;
  final bool isColdChain;
  final List<dynamic> items;

  const OrderPackageDetailsEntity({
    required this.itemCount,
    required this.isFragile,
    required this.isColdChain,
    this.items = const [],
  });

  @override
  List<Object?> get props => [itemCount, isFragile, isColdChain, items];
}

class ActiveOrderEntity extends Equatable {
  final int id;
  final String orderNumber;
  final String status;
  final String orderType;
  final OrderVendorEntity vendor;
  final OrderCustomerEntity customer;
  final OrderPackageDetailsEntity packageDetails;
  final String paymentMode;
  final double codAmount;
  final bool isCodCollected;
  final double estimatedDistanceKm;
  final int estimatedDurationMins;
  final double totalRiderPayout;

  const ActiveOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.orderType,
    required this.vendor,
    required this.customer,
    required this.packageDetails,
    required this.paymentMode,
    required this.codAmount,
    required this.isCodCollected,
    required this.estimatedDistanceKm,
    required this.estimatedDurationMins,
    required this.totalRiderPayout,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        orderType,
        vendor,
        customer,
        packageDetails,
        paymentMode,
        codAmount,
        isCodCollected,
        estimatedDistanceKm,
        estimatedDurationMins,
        totalRiderPayout,
      ];
}
