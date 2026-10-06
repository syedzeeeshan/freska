
abstract class NotificationRepository {
  Future<Map<String, dynamic>> getNotifications({int page = 1});
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<void> registerDevice({
    required String deviceId,
    String? fcmToken,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
  });
}
