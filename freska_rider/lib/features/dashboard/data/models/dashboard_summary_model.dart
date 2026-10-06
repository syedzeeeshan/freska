import 'package:freska_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:freska_rider/features/orders/data/models/active_order_model.dart';
import 'package:freska_rider/features/orders/data/models/order_offer_model.dart';

class DashboardMetricsModel extends DashboardMetrics {
  const DashboardMetricsModel({
    required super.todayEarnings,
    required super.todayDeliveriesCount,
    required super.todayOnlineHours,
    required super.acceptanceRate,
    required super.ratingAverage,
    required super.currentCashInHand,
    required super.maxCashLimit,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 0.0,
      todayDeliveriesCount:
          (json['today_deliveries_count'] as num?)?.toInt() ?? 0,
      todayOnlineHours: (json['today_online_hours'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 100.0,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 5.0,
      currentCashInHand:
          (json['current_cash_in_hand'] as num?)?.toDouble() ?? 0.0,
      maxCashLimit: (json['max_cash_limit'] as num?)?.toDouble() ?? 5000.0,
    );
  }
}

class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required super.isOnline,
    super.lastLocationUpdatedAt,
    super.currentLatitude,
    super.currentLongitude,
    required super.metrics,
    required super.hasActiveOrder,
    super.activeOrder,
    required super.hasPendingOffer,
    super.pendingOffer,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    final metricsJson = json['metrics'] as Map<String, dynamic>? ?? {};
    final activeOrderJson = json['active_order'] as Map<String, dynamic>?;
    final pendingOfferJson = json['pending_offer'] as Map<String, dynamic>?;

    return DashboardSummaryModel(
      isOnline: json['is_online'] as bool? ?? false,
      lastLocationUpdatedAt: parseDate(json['last_location_updated_at']),
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      metrics: DashboardMetricsModel.fromJson(metricsJson),
      hasActiveOrder: json['has_active_order'] as bool? ?? false,
      activeOrder: activeOrderJson != null
          ? ActiveOrderModel.fromJson(activeOrderJson)
          : null,
      hasPendingOffer: json['has_pending_offer'] as bool? ?? false,
      pendingOffer: pendingOfferJson != null
          ? OrderOfferModel.fromJson(pendingOfferJson)
          : null,
    );
  }
}
