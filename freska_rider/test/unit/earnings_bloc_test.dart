import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/features/earnings/domain/entities/earnings_summary_entity.dart';
import 'package:freska_rider/features/earnings/domain/repositories/earnings_repository.dart';
import 'package:freska_rider/features/earnings/presentation/blocs/earnings_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockEarningsRepository extends Mock implements EarningsRepository {}

void main() {
  late MockEarningsRepository mockRepository;
  late EarningsBloc earningsBloc;

  setUp(() {
    mockRepository = MockEarningsRepository();
    earningsBloc = EarningsBloc(repository: mockRepository);
  });

  tearDown(() {
    earningsBloc.close();
  });

  const tSummary = EarningsSummaryEntity(
    todayEarnings: 240.0,
    todayDeliveries: 4,
    thisWeekEarnings: 1450.0,
    thisWeekDeliveries: 22,
    surgeBonus: 80.0,
    tipsTotal: 60.0,
    milestoneProgressPercentage: 44.0,
    weeklyDailyChart: [
      DailyChartBar(day: 'Mon', date: '2026-09-22', amount: 240.0, count: 4),
    ],
  );

  test('initial state should be EarningsInitial', () {
    expect(earningsBloc.state, equals(EarningsInitial()));
  });

  blocTest<EarningsBloc, EarningsState>(
    'emits [EarningsLoading, EarningsLoaded] when LoadEarningsSummaryEvent is successful',
    build: () {
      when(() => mockRepository.getEarningsSummary())
          .thenAnswer((_) async => tSummary);
      return earningsBloc;
    },
    act: (bloc) => bloc.add(const LoadEarningsSummaryEvent()),
    expect: () => [
      EarningsLoading(),
      const EarningsLoaded(summary: tSummary),
    ],
  );
}
