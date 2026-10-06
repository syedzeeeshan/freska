import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();
  @override
  List<Object?> get props => [];
}

class LoadTicketsEvent extends SupportEvent {
  const LoadTicketsEvent();
}

class CreateTicketEvent extends SupportEvent {
  final String category;
  final String subject;
  final String description;
  final String priority;
  final int? orderId;
  final File? attachment;

  const CreateTicketEvent({
    required this.category,
    required this.subject,
    required this.description,
    this.priority = 'medium',
    this.orderId,
    this.attachment,
  });

  @override
  List<Object?> get props =>
      [category, subject, description, priority, orderId, attachment];
}
