import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/earnings_repository.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

export 'earnings_event.dart';
export 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository repository;

  EarningsBloc({required this.repository}) : super(EarningsInitial()) {
    on<LoadEarningsSummaryEvent>(_onLoadSummary);
  }

  Future<void> _onLoadSummary(
    LoadEarningsSummaryEvent event,
    Emitter<EarningsState> emit,
  ) async {
    emit(EarningsLoading());
    try {
      final summary = await repository.getEarningsSummary();
      emit(EarningsLoaded(summary: summary));
    } catch (e) {
      emit(EarningsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
