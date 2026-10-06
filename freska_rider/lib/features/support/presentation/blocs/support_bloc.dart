import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/support_repository.dart';
import 'support_event.dart';
import 'support_state.dart';

export 'support_event.dart';
export 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository repository;

  SupportBloc({required this.repository}) : super(SupportInitial()) {
    on<LoadTicketsEvent>(_onLoadTickets);
    on<CreateTicketEvent>(_onCreateTicket);
  }

  Future<void> _onLoadTickets(
    LoadTicketsEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(SupportLoading());
    try {
      final tickets = await repository.getTickets();
      emit(TicketsLoaded(tickets: tickets));
    } catch (e) {
      emit(SupportError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateTicket(
    CreateTicketEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(SupportLoading());
    try {
      final ticket = await repository.createTicket(
        category: event.category,
        subject: event.subject,
        description: event.description,
        priority: event.priority,
        orderId: event.orderId,
        attachment: event.attachment,
      );
      emit(TicketCreatedSuccess(ticket: ticket));
      add(const LoadTicketsEvent());
    } catch (e) {
      emit(SupportError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
