import 'package:equatable/equatable.dart';

class SupportTicketEntity extends Equatable {
  final int id;
  final String ticketNumber;
  final String category;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final String? attachmentUrl;
  final String? resolutionNotes;
  final String createdAt;

  const SupportTicketEntity({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    this.attachmentUrl,
    this.resolutionNotes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        category,
        subject,
        description,
        priority,
        status,
        attachmentUrl,
        resolutionNotes,
        createdAt,
      ];
}
