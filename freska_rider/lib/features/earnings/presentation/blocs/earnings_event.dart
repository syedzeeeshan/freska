import 'package:equatable/equatable.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEarningsSummaryEvent extends EarningsEvent {
  const LoadEarningsSummaryEvent();
}

class RefreshEarningsEvent extends EarningsEvent {
  const RefreshEarningsEvent();
}
