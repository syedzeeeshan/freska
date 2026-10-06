import 'package:equatable/equatable.dart';

class ComplimentBadge extends Equatable {
  final String badge;
  final String label;
  final int count;

  const ComplimentBadge({
    required this.badge,
    required this.label,
    required this.count,
  });

  @override
  List<Object?> get props => [badge, label, count];
}

class PerformanceMetricsEntity extends Equatable {
  final double ratingAverage;
  final int ratingCount;
  final double acceptanceRate;
  final double onTimeRate;
  final int completedDeliveriesCount;
  final String tier;
  final double tierMultiplier;
  final String? nextTier;
  final int deliveriesToNextTier;
  final double tierProgressPercentage;
  final List<ComplimentBadge> topCompliments;

  const PerformanceMetricsEntity({
    required this.ratingAverage,
    required this.ratingCount,
    required this.acceptanceRate,
    required this.onTimeRate,
    required this.completedDeliveriesCount,
    required this.tier,
    required this.tierMultiplier,
    this.nextTier,
    required this.deliveriesToNextTier,
    required this.tierProgressPercentage,
    required this.topCompliments,
  });

  @override
  List<Object?> get props => [
        ratingAverage,
        ratingCount,
        acceptanceRate,
        onTimeRate,
        completedDeliveriesCount,
        tier,
        tierMultiplier,
        nextTier,
        deliveriesToNextTier,
        tierProgressPercentage,
        topCompliments,
      ];
}
