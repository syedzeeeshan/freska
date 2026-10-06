import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../blocs/earnings_bloc.dart';
import '../widgets/earnings_chart_widget.dart';

class EarningsOverviewScreen extends StatefulWidget {
  const EarningsOverviewScreen({super.key});

  @override
  State<EarningsOverviewScreen> createState() => _EarningsOverviewScreenState();
}

class _EarningsOverviewScreenState extends State<EarningsOverviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsBloc>().add(const LoadEarningsSummaryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Payouts'),
      ),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EarningsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: StitchColors.dangerSOS)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<EarningsBloc>()
                        .add(const LoadEarningsSummaryEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EarningsLoaded) {
            final s = state.summary;

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<EarningsBloc>().add(const LoadEarningsSummaryEvent()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Today Highlight Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          StitchColors.primaryFreshDark,
                          StitchColors.primaryFresh
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Net Earnings",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${s.todayEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${s.todayDeliveries} Deliveries Completed Today',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Weekly Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          'This Week',
                          '₹${s.thisWeekEarnings.toStringAsFixed(0)}',
                          '${s.thisWeekDeliveries} orders',
                          StitchColors.accentGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          'Tips & Surge',
                          '₹${(s.tipsTotal + s.surgeBonus).toStringAsFixed(0)}',
                          '100% credited',
                          StitchColors.infoBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Weekly Bar Chart
                  EarningsChartWidget(weeklyData: s.weeklyDailyChart),

                  const SizedBox(height: 20),

                  // Weekly Target Milestone Meter
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StitchColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: StitchColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Weekly Milestone Streak',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${s.milestoneProgressPercentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: StitchColors.accentGold,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: (s.milestoneProgressPercentage / 100)
                              .clamp(0.0, 1.0),
                          backgroundColor: StitchColors.darkSurfaceElevated,
                          color: StitchColors.accentGold,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Complete 50 orders this week for an extra ₹1,500 bonus.',
                          style: TextStyle(
                              color: StitchColors.textSecondaryDark,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMetricTile(
      String title, String mainValue, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StitchColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: StitchColors.textSecondaryDark, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            mainValue,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(
                  color: StitchColors.textSecondaryDark, fontSize: 11)),
        ],
      ),
    );
  }
}
