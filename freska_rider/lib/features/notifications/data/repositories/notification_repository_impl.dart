import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient apiClient;

  NotificationRepositoryImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response =
        await apiClient.get('/rider/notifications?page=$page');
    final data = response.data['data'] as Map<String, dynamic>;
    final rawList = data['notifications']['data'] as List<dynamic>;

    final notifications = rawList.map((item) {
      final map = item as Map<String, dynamic>;
      return NotificationEntity(
        id: map['id'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
        type: map['type'] as String,
        data: map['data'] as Map<String, dynamic>?,
        isRead: map['is_read'] as bool? ?? false,
        createdAt: map['created_at'] as String,
      );
    }).toList();

    return {
      'notifications': notifications,
      'unread_count': (data['unread_count'] ?? 0) as int,
    };
  }

  @override
  Future<void> markAsRead(int id) async {
    await apiClient.patch('/rider/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.patch('/rider/notifications/read-all');
  }

  @override
  Future<void> registerDevice({
    required String deviceId,
    String? fcmToken,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
  }) async {
    await apiClient.post('/rider/devices/register', data: {
      'device_id': deviceId,
      'fcm_token': fcmToken,
      'device_model': deviceModel,
      'os_version': osVersion,
      'app_version': appVersion,
    });
  }
}
