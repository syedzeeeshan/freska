import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../blocs/performance_cubit.dart';
import '../blocs/performance_state.dart';
import '../widgets/circular_score_gauge.dart';
import '../widgets/tier_progress_card.dart';

class PerformanceMetricsScreen extends StatefulWidget {
  const PerformanceMetricsScreen({super.key});

  @override
  State<PerformanceMetricsScreen> createState() =>
      _PerformanceMetricsScreenState();
}

class _PerformanceMetricsScreenState extends State<PerformanceMetricsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PerformanceCubit>().loadPerformance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance & Badges')),
      body: BlocBuilder<PerformanceCubit, PerformanceState>(
        builder: (context, state) {
          if (state is PerformanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PerformanceLoaded) {
            final m = state.metrics;
            final reviews = state.reviews;

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<PerformanceCubit>().loadPerformance(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Tier Progress Card
                  TierProgressCard(
                    currentTier: m.tier,
                    multiplier: m.tierMultiplier,
                    nextTier: m.nextTier,
                    deliveriesRemaining: m.deliveriesToNextTier,
                    progressPercentage: m.tierProgressPercentage,
                  ),
                  const SizedBox(height: 20),

                  // Circular Score Gauges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircularScoreGauge(
                        score: m.ratingAverage,
                        maxScore: 5.0,
                        label: 'RATING',
                        activeColor: StitchColors.accentGold,
                      ),
                      CircularScoreGauge(
                        score: m.acceptanceRate,
                        maxScore: 100.0,
                        label: 'ACCEPT %',
                        activeColor: StitchColors.primaryFresh,
                      ),
                      CircularScoreGauge(
                        score: m.onTimeRate,
                        maxScore: 100.0,
                        label: 'ON-TIME %',
                        activeColor: StitchColors.infoBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Compliments Badges
                  const Text(
                    'Customer Compliments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: m.topCompliments.map((badge) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: StitchColors.darkSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: StitchColors.darkBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: StitchColors.accentGold, size: 20),
                            const SizedBox(width: 8),
                            Text(badge.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: StitchColors.accentGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${badge.count}',
                                style: const TextStyle(
                                    color: StitchColors.accentGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Recent Customer Reviews
                  const Text(
                    'Recent Customer Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No written reviews yet. Deliver great experiences to earn compliments!',
                          style: TextStyle(
                              color: StitchColors.textSecondaryDark,
                              fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...reviews.map((r) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: List.generate(5, (idx) {
                                      final starVal = idx + 1;
                                      final rating =
                                          (r['rating'] as num?)?.toInt() ?? 5;
                                      return Icon(
                                        starVal <= rating
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: StitchColors.accentGold,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  Text(
                                    (r['created_at'] as String? ?? '')
                                        .substring(0, 10),
                                    style: const TextStyle(
                                        color: StitchColors.textSecondaryDark,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                              if ((r['feedback_comment'] as String?)
                                      ?.isNotEmpty ??
                                  false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '"${r['feedback_comment']}"',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
