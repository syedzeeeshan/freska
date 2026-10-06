import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_rider/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'dashboard_summary_state.dart';

class DashboardSummaryCubit extends Cubit<DashboardSummaryState> {
  final DashboardRepository dashboardRepository;

  DashboardSummaryCubit({required this.dashboardRepository})
      : super(const DashboardSummaryState());

  Future<void> loadDashboardSummary({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(state.copyWith(
          status: DashboardSummaryStatus.loading, errorMessage: null));
    }

    try {
      final summary = await dashboardRepository.getDashboardSummary();
      emit(state.copyWith(
        status: DashboardSummaryStatus.success,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardSummaryStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
