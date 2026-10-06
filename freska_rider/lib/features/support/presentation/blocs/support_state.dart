import 'package:equatable/equatable.dart';
import '../../domain/entities/support_ticket_entity.dart';

abstract class SupportState extends Equatable {
  const SupportState();
  @override
  List<Object?> get props => [];
}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class TicketsLoaded extends SupportState {
  final List<SupportTicketEntity> tickets;
  const TicketsLoaded({required this.tickets});
  @override
  List<Object?> get props => [tickets];
}

class TicketCreatedSuccess extends SupportState {
  final SupportTicketEntity ticket;
  const TicketCreatedSuccess({required this.ticket});
  @override
  List<Object?> get props => [ticket];
}

class SupportError extends SupportState {
  final String message;
  const SupportError({required this.message});
  @override
  List<Object?> get props => [message];
}
