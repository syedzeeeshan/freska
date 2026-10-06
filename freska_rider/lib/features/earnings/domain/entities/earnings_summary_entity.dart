import 'package:equatable/equatable.dart';

class DailyChartBar extends Equatable {
  final String day;
  final String date;
  final double amount;
  final int count;

  const DailyChartBar({
    required this.day,
    required this.date,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [day, date, amount, count];
}

class EarningsSummaryEntity extends Equatable {
  final double todayEarnings;
  final int todayDeliveries;
  final double thisWeekEarnings;
  final int thisWeekDeliveries;
  final double surgeBonus;
  final double tipsTotal;
  final double milestoneProgressPercentage;
  final List<DailyChartBar> weeklyDailyChart;

  const EarningsSummaryEntity({
    required this.todayEarnings,
    required this.todayDeliveries,
    required this.thisWeekEarnings,
    required this.thisWeekDeliveries,
    required this.surgeBonus,
    required this.tipsTotal,
    required this.milestoneProgressPercentage,
    required this.weeklyDailyChart,
  });

  @override
  List<Object?> get props => [
        todayEarnings,
        todayDeliveries,
        thisWeekEarnings,
        thisWeekDeliveries,
        surgeBonus,
        tipsTotal,
        milestoneProgressPercentage,
        weeklyDailyChart,
      ];
}
