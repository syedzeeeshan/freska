import '../../domain/entities/earnings_summary_entity.dart';

class EarningsSummaryModel extends EarningsSummaryEntity {
  const EarningsSummaryModel({
    required super.todayEarnings,
    required super.todayDeliveries,
    required super.thisWeekEarnings,
    required super.thisWeekDeliveries,
    required super.surgeBonus,
    required super.tipsTotal,
    required super.milestoneProgressPercentage,
    required super.weeklyDailyChart,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final chartList = json['weekly_daily_chart'] as List<dynamic>? ?? [];

    final chartBars = chartList.map((item) {
      final map = item as Map<String, dynamic>;
      return DailyChartBar(
        day: (map['day'] ?? '') as String,
        date: (map['date'] ?? '') as String,
        amount: ((map['amount'] ?? 0.0) as num).toDouble(),
        count: (map['count'] ?? 0) as int,
      );
    }).toList();

    return EarningsSummaryModel(
      todayEarnings: ((summary['today_earnings'] ?? 0.0) as num).toDouble(),
      todayDeliveries: (summary['today_deliveries'] ?? 0) as int,
      thisWeekEarnings:
          ((summary['this_week_earnings'] ?? 0.0) as num).toDouble(),
      thisWeekDeliveries: (summary['this_week_deliveries'] ?? 0) as int,
      surgeBonus: ((summary['surge_bonus'] ?? 0.0) as num).toDouble(),
      tipsTotal: ((summary['tips_total'] ?? 0.0) as num).toDouble(),
      milestoneProgressPercentage:
          ((summary['milestone_progress_percentage'] ?? 0.0) as num).toDouble(),
      weeklyDailyChart: chartBars,
    );
  }
}
