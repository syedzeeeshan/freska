import 'package:equatable/equatable.dart';
import 'package:freska_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';

enum DashboardSummaryStatus { initial, loading, success, failure }

class DashboardSummaryState extends Equatable {
  final DashboardSummaryStatus status;
  final DashboardSummaryEntity? summary;
  final String? errorMessage;

  const DashboardSummaryState({
    this.status = DashboardSummaryStatus.initial,
    this.summary,
    this.errorMessage,
  });

  DashboardSummaryState copyWith({
    DashboardSummaryStatus? status,
    DashboardSummaryEntity? summary,
    String? errorMessage,
  }) {
    return DashboardSummaryState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
