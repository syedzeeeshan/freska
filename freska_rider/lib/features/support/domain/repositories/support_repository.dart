import 'dart:io';
import '../entities/support_ticket_entity.dart';

abstract class SupportRepository {
  Future<List<SupportTicketEntity>> getTickets({int page = 1});
  Future<SupportTicketEntity> createTicket({
    required String category,
    required String subject,
    required String description,
    String priority = 'medium',
    int? orderId,
    File? attachment,
  });
  Future<SupportTicketEntity> getTicketDetails(int ticketId);
}
