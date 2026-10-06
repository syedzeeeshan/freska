import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cod_repository.dart';
import 'cod_event.dart';
import 'cod_state.dart';

export 'cod_event.dart';
export 'cod_state.dart';

class CodBloc extends Bloc<CodEvent, CodState> {
  final CodRepository repository;

  CodBloc({required this.repository}) : super(CodInitial()) {
    on<LoadCodSummaryEvent>(_onLoadSummary);
    on<SubmitRemittanceEvent>(_onSubmitRemittance);
  }

  Future<void> _onLoadSummary(
    LoadCodSummaryEvent event,
    Emitter<CodState> emit,
  ) async {
    emit(CodLoading());
    try {
      final summary = await repository.getCodSummary();
      final orders = await repository.getPendingCodOrders();
      emit(CodLoaded(summary: summary, pendingOrders: orders));
    } catch (e) {
      emit(CodError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSubmitRemittance(
    SubmitRemittanceEvent event,
    Emitter<CodState> emit,
  ) async {
    emit(CodLoading());
    try {
      await repository.submitHandover(
        amount: event.amount,
        handoverMethod: event.method,
        reference: event.reference,
      );
      emit(CodRemittanceSuccess());
      add(const LoadCodSummaryEvent());
    } catch (e) {
      emit(CodError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
