import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_bloc.dart';
import 'package:freska_rider/features/dashboard/presentation/bloc/duty_state.dart';
import 'package:freska_rider/features/dashboard/presentation/cubit/dashboard_summary_cubit.dart';
import 'package:freska_rider/features/dashboard/presentation/cubit/dashboard_summary_state.dart';
import 'package:freska_rider/features/dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_cubit.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_state.dart';

class MockDutyBloc extends Mock implements DutyBloc {}

class MockDashboardSummaryCubit extends Mock implements DashboardSummaryCubit {}

class MockOrderOfferCubit extends Mock implements OrderOfferCubit {}

void main() {
  late MockDutyBloc mockDutyBloc;
  late MockDashboardSummaryCubit mockSummaryCubit;
  late MockOrderOfferCubit mockOfferCubit;

  const tSummary = DashboardSummaryEntity(
    isOnline: true,
    metrics: DashboardMetrics(
      todayEarnings: 520.00,
      todayDeliveriesCount: 6,
      todayOnlineHours: 4.2,
      acceptanceRate: 98.0,
      ratingAverage: 4.9,
      currentCashInHand: 420.0,
      maxCashLimit: 5000.0,
    ),
    hasActiveOrder: false,
    activeOrder: null,
    hasPendingOffer: false,
    pendingOffer: null,
  );

  setUp(() {
    mockDutyBloc = MockDutyBloc();
    mockSummaryCubit = MockDashboardSummaryCubit();
    mockOfferCubit = MockOrderOfferCubit();

    when(() => mockDutyBloc.state).thenReturn(const DutyState(isOnline: true));
    when(() => mockDutyBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockSummaryCubit.state).thenReturn(const DashboardSummaryState(
      status: DashboardSummaryStatus.success,
      summary: tSummary,
    ));
    when(() => mockSummaryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSummaryCubit.loadDashboardSummary(
        isRefresh: any(named: 'isRefresh'))).thenAnswer((_) async {});

    when(() => mockOfferCubit.state).thenReturn(const OrderOfferState());
    when(() => mockOfferCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets(
      'RiderDashboardScreen displays header, duty status, and overview metrics',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DutyBloc>.value(value: mockDutyBloc),
            BlocProvider<DashboardSummaryCubit>.value(value: mockSummaryCubit),
            BlocProvider<OrderOfferCubit>.value(value: mockOfferCubit),
          ],
          child: const RiderDashboardScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify title and location
    expect(find.text('Freska Partner'), findsOneWidget);
    expect(find.text('Koramangala Hub'), findsOneWidget);

    // Verify Duty button
    expect(find.text('ON DUTY'), findsOneWidget);

    // Verify section title and metrics
    expect(find.text("TODAY'S OVERVIEW"), findsOneWidget);
    expect(find.text('₹520.00'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('4.2 hrs'), findsOneWidget);
    expect(find.text('4.9 ★'), findsOneWidget);

    // Verify Cash in Hand meter
    expect(find.text('Cash in Hand (COD)'), findsOneWidget);
    expect(find.text('₹420.00 / ₹5000'), findsOneWidget);

    // Verify Support and Emergency SOS buttons
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Emergency SOS'), findsOneWidget);
  });
}
