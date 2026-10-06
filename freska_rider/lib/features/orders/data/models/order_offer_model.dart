import 'package:freska_rider/features/orders/domain/entities/order_offer_entity.dart';

class OrderOfferModel extends OrderOfferEntity {
  const OrderOfferModel({
    required super.id,
    required super.orderId,
    required super.orderNumber,
    required super.vendorName,
    required super.vendorAddress,
    required super.vendorLatitude,
    required super.vendorLongitude,
    required super.deliveryArea,
    required super.estimatedDistanceKm,
    required super.estimatedDurationMins,
    required super.totalRiderPayout,
    required super.isColdChain,
    required super.isFragile,
    required super.itemCount,
    required super.paymentMode,
    required super.codAmount,
    required super.offeredAt,
    required super.expiresAt,
    required super.remainingSeconds,
  });

  factory OrderOfferModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return OrderOfferModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      orderId: json['order_id'] is int
          ? json['order_id'] as int
          : int.parse(json['order_id'].toString()),
      orderNumber: json['order_number'] as String? ?? '',
      vendorName: json['vendor_name'] as String? ?? '',
      vendorAddress: json['vendor_address'] as String? ?? '',
      vendorLatitude: (json['vendor_latitude'] as num?)?.toDouble() ?? 0.0,
      vendorLongitude: (json['vendor_longitude'] as num?)?.toDouble() ?? 0.0,
      deliveryArea: json['delivery_area'] as String? ?? '',
      estimatedDistanceKm:
          (json['estimated_distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMins:
          (json['estimated_duration_mins'] as num?)?.toInt() ?? 0,
      totalRiderPayout: (json['total_rider_payout'] as num?)?.toDouble() ?? 0.0,
      isColdChain: json['is_cold_chain'] as bool? ?? false,
      isFragile: json['is_fragile'] as bool? ?? false,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 1,
      paymentMode: json['payment_mode'] as String? ?? 'prepaid',
      codAmount: (json['cod_amount'] as num?)?.toDouble() ?? 0.0,
      offeredAt: parseDate(json['offered_at']),
      expiresAt: parseDate(json['expires_at']),
      remainingSeconds: (json['remaining_seconds'] as num?)?.toInt() ?? 30,
    );
  }
}
