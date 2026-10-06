import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../domain/entities/earnings_summary_entity.dart';

class EarningsChartWidget extends StatelessWidget {
  final List<DailyChartBar> weeklyData;

  const EarningsChartWidget({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = weeklyData
            .map((e) => e.amount)
            .fold<double>(100.0, (prev, curr) => curr > prev ? curr : prev) *
        1.2;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StitchColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Earnings Breakdown',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: StitchColors.textSecondaryDark),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => StitchColors.darkSurfaceElevated,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₹${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                            color: StitchColors.accentGold,
                            fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= weeklyData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            weeklyData[idx].day,
                            style: const TextStyle(
                                color: StitchColors.textSecondaryDark,
                                fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(weeklyData.length, (idx) {
                  final bar = weeklyData[idx];
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: bar.amount,
                        color: bar.amount > 0
                            ? StitchColors.primaryFresh
                            : StitchColors.darkBorder,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
