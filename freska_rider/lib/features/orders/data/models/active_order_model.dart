import 'package:freska_rider/features/orders/domain/entities/active_order_entity.dart';

class OrderVendorModel extends OrderVendorEntity {
  const OrderVendorModel({
    required super.id,
    required super.name,
    required super.storeCode,
    required super.phone,
    required super.address,
    super.landmark,
    required super.latitude,
    required super.longitude,
    super.pickupInstructions,
  });

  factory OrderVendorModel.fromJson(Map<String, dynamic> json) {
    return OrderVendorModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      storeCode: json['store_code'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      pickupInstructions: json['pickup_instructions'] as String?,
    );
  }
}

class OrderCustomerModel extends OrderCustomerEntity {
  const OrderCustomerModel({
    required super.name,
    required super.phone,
    required super.deliveryArea,
    required super.deliveryAddress,
    required super.deliveryLatitude,
    required super.deliveryLongitude,
    super.deliveryInstructions,
  });

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      deliveryArea: json['delivery_area'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryLatitude: (json['delivery_latitude'] as num?)?.toDouble() ?? 0.0,
      deliveryLongitude:
          (json['delivery_longitude'] as num?)?.toDouble() ?? 0.0,
      deliveryInstructions: json['delivery_instructions'] as String?,
    );
  }
}

class OrderPackageDetailsModel extends OrderPackageDetailsEntity {
  const OrderPackageDetailsModel({
    required super.itemCount,
    required super.isFragile,
    required super.isColdChain,
    super.items,
  });

  factory OrderPackageDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderPackageDetailsModel(
      itemCount: (json['item_count'] as num?)?.toInt() ?? 1,
      isFragile: json['is_fragile'] as bool? ?? false,
      isColdChain: json['is_cold_chain'] as bool? ?? false,
      items: json['items'] is List ? json['items'] as List<dynamic> : const [],
    );
  }
}

class ActiveOrderModel extends ActiveOrderEntity {
  const ActiveOrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.orderType,
    required super.vendor,
    required super.customer,
    required super.packageDetails,
    required super.paymentMode,
    required super.codAmount,
    required super.isCodCollected,
    required super.estimatedDistanceKm,
    required super.estimatedDurationMins,
    required super.totalRiderPayout,
  });

  factory ActiveOrderModel.fromJson(Map<String, dynamic> json) {
    return ActiveOrderModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      orderNumber: json['order_number'] as String? ?? '',
      status: json['status'] as String? ?? 'accepted',
      orderType: json['order_type'] as String? ?? 'grocery',
      vendor: OrderVendorModel.fromJson(
          json['vendor'] as Map<String, dynamic>? ?? {}),
      customer: OrderCustomerModel.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {}),
      packageDetails: OrderPackageDetailsModel.fromJson(
          json['package_details'] as Map<String, dynamic>? ?? {}),
      paymentMode: json['payment_mode'] as String? ?? 'prepaid',
      codAmount: (json['cod_amount'] as num?)?.toDouble() ?? 0.0,
      isCodCollected: json['is_cod_collected'] as bool? ?? false,
      estimatedDistanceKm:
          (json['estimated_distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMins:
          (json['estimated_duration_mins'] as num?)?.toInt() ?? 0,
      totalRiderPayout: (json['total_rider_payout'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
