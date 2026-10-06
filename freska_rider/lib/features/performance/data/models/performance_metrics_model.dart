import '../../domain/entities/performance_metrics_entity.dart';

class PerformanceMetricsModel extends PerformanceMetricsEntity {
  const PerformanceMetricsModel({
    required super.ratingAverage,
    required super.ratingCount,
    required super.acceptanceRate,
    required super.onTimeRate,
    required super.completedDeliveriesCount,
    required super.tier,
    required super.tierMultiplier,
    super.nextTier,
    required super.deliveriesToNextTier,
    required super.tierProgressPercentage,
    required super.topCompliments,
  });

  factory PerformanceMetricsModel.fromJson(Map<String, dynamic> json) {
    final list = json['top_compliments'] as List<dynamic>? ?? [];
    final compliments = list.map((item) {
      final map = item as Map<String, dynamic>;
      return ComplimentBadge(
        badge: (map['badge'] ?? '') as String,
        label: (map['label'] ?? '') as String,
        count: (map['count'] ?? 0) as int,
      );
    }).toList();

    return PerformanceMetricsModel(
      ratingAverage: ((json['rating_average'] ?? 5.0) as num).toDouble(),
      ratingCount: (json['rating_count'] ?? 0) as int,
      acceptanceRate: ((json['acceptance_rate'] ?? 100.0) as num).toDouble(),
      onTimeRate: ((json['on_time_rate'] ?? 100.0) as num).toDouble(),
      completedDeliveriesCount:
          (json['completed_deliveries_count'] ?? 0) as int,
      tier: (json['tier'] ?? 'bronze') as String,
      tierMultiplier: ((json['tier_multiplier'] ?? 1.0) as num).toDouble(),
      nextTier: json['next_tier'] as String?,
      deliveriesToNextTier: (json['deliveries_to_next_tier'] ?? 0) as int,
      tierProgressPercentage:
          ((json['tier_progress_percentage'] ?? 0.0) as num).toDouble(),
      topCompliments: compliments,
    );
  }
}
