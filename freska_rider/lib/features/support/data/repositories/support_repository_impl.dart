import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  final ApiClient apiClient;

  SupportRepositoryImpl({required this.apiClient});

  @override
  Future<List<SupportTicketEntity>> getTickets({int page = 1}) async {
    final response =
        await apiClient.get('/rider/support/tickets?page=$page');
    final dataList = response.data['data']['data'] as List<dynamic>;

    return dataList.map((item) {
      final map = item as Map<String, dynamic>;
      return SupportTicketEntity(
        id: map['id'] as int,
        ticketNumber: map['ticket_number'] as String,
        category: map['category'] as String,
        subject: map['subject'] as String,
        description: map['description'] as String? ?? '',
        priority: map['priority'] as String? ?? 'medium',
        status: map['status'] as String,
        attachmentUrl: map['attachment_url'] as String?,
        resolutionNotes: map['resolution_notes'] as String?,
        createdAt: map['created_at'] as String,
      );
    }).toList();
  }

  @override
  Future<SupportTicketEntity> createTicket({
    required String category,
    required String subject,
    required String description,
    String priority = 'medium',
    int? orderId,
    File? attachment,
  }) async {
    final formData = FormData.fromMap({
      'category': category,
      'subject': subject,
      'description': description,
      'priority': priority,
      'order_id': orderId,
    });

    if (attachment != null) {
      formData.files.add(MapEntry(
        'attachment',
        await MultipartFile.fromFile(attachment.path,
            filename: 'ticket_proof.jpg'),
      ));
    }

    final response =
        await apiClient.post('/rider/support/tickets', data: formData);
    final map = response.data['data'] as Map<String, dynamic>;

    return SupportTicketEntity(
      id: map['id'] as int,
      ticketNumber: map['ticket_number'] as String,
      category: map['category'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      status: map['status'] as String,
      attachmentUrl: map['attachment_url'] as String?,
      resolutionNotes: map['resolution_notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  @override
  Future<SupportTicketEntity> getTicketDetails(int ticketId) async {
    final response =
        await apiClient.get('/rider/support/tickets/$ticketId');
    final map = response.data['data'] as Map<String, dynamic>;

    return SupportTicketEntity(
      id: map['id'] as int,
      ticketNumber: map['ticket_number'] as String,
      category: map['category'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      status: map['status'] as String,
      attachmentUrl: map['attachment_url'] as String?,
      resolutionNotes: map['resolution_notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
