import 'package:equatable/equatable.dart';
import 'package:freska_rider/features/orders/domain/entities/active_order_entity.dart';
import 'package:freska_rider/features/orders/domain/entities/order_offer_entity.dart';

class DashboardMetrics extends Equatable {
  final double todayEarnings;
  final int todayDeliveriesCount;
  final double todayOnlineHours;
  final double acceptanceRate;
  final double ratingAverage;
  final double currentCashInHand;
  final double maxCashLimit;

  const DashboardMetrics({
    required this.todayEarnings,
    required this.todayDeliveriesCount,
    required this.todayOnlineHours,
    required this.acceptanceRate,
    required this.ratingAverage,
    required this.currentCashInHand,
    required this.maxCashLimit,
  });

  @override
  List<Object?> get props => [
        todayEarnings,
        todayDeliveriesCount,
        todayOnlineHours,
        acceptanceRate,
        ratingAverage,
        currentCashInHand,
        maxCashLimit,
      ];
}

class DashboardSummaryEntity extends Equatable {
  final bool isOnline;
  final DateTime? lastLocationUpdatedAt;
  final double? currentLatitude;
  final double? currentLongitude;
  final DashboardMetrics metrics;
  final bool hasActiveOrder;
  final ActiveOrderEntity? activeOrder;
  final bool hasPendingOffer;
  final OrderOfferEntity? pendingOffer;

  const DashboardSummaryEntity({
    required this.isOnline,
    this.lastLocationUpdatedAt,
    this.currentLatitude,
    this.currentLongitude,
    required this.metrics,
    required this.hasActiveOrder,
    this.activeOrder,
    required this.hasPendingOffer,
    this.pendingOffer,
  });

  @override
  List<Object?> get props => [
        isOnline,
        lastLocationUpdatedAt,
        currentLatitude,
        currentLongitude,
        metrics,
        hasActiveOrder,
        activeOrder,
        hasPendingOffer,
        pendingOffer,
      ];
}
