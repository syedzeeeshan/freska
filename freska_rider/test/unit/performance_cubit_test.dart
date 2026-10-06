import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/features/performance/domain/entities/performance_metrics_entity.dart';
import 'package:freska_rider/features/performance/domain/repositories/performance_repository.dart';
import 'package:freska_rider/features/performance/presentation/blocs/performance_cubit.dart';
import 'package:freska_rider/features/performance/presentation/blocs/performance_state.dart';
import 'package:mocktail/mocktail.dart';

class MockPerformanceRepository extends Mock implements PerformanceRepository {}

void main() {
  late MockPerformanceRepository mockRepository;
  late PerformanceCubit performanceCubit;

  setUp(() {
    mockRepository = MockPerformanceRepository();
    performanceCubit = PerformanceCubit(repository: mockRepository);
  });

  tearDown(() {
    performanceCubit.close();
  });

  const tMetrics = PerformanceMetricsEntity(
    ratingAverage: 4.95,
    ratingCount: 140,
    acceptanceRate: 98.0,
    onTimeRate: 99.1,
    completedDeliveriesCount: 220,
    tier: 'gold',
    tierMultiplier: 1.10,
    nextTier: 'platinum',
    deliveriesToNextTier: 280,
    tierProgressPercentage: 6.7,
    topCompliments: [
      ComplimentBadge(
          badge: 'fast_delivery', label: 'Lightning Fast', count: 95),
    ],
  );

  test('initial state should be PerformanceInitial', () {
    expect(performanceCubit.state, equals(PerformanceInitial()));
  });

  blocTest<PerformanceCubit, PerformanceState>(
    'emits [PerformanceLoading, PerformanceLoaded] when loadPerformance succeeds',
    build: () {
      when(() => mockRepository.getMetrics()).thenAnswer((_) async => tMetrics);
      when(() => mockRepository.getReviews(page: any(named: 'page')))
          .thenAnswer((_) async => []);
      return performanceCubit;
    },
    act: (cubit) => cubit.loadPerformance(),
    expect: () => [
      PerformanceLoading(),
      const PerformanceLoaded(metrics: tMetrics, reviews: []),
    ],
  );
}
