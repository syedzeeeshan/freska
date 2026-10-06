import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

export 'notification_event.dart';
export 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final res = await repository.getNotifications();
      emit(NotificationsLoaded(
        notifications: res['notifications'],
        unreadCount: res['unread_count'],
      ));
    } catch (e) {
      emit(NotificationError(
          message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAsRead(event.id);
      add(const LoadNotificationsEvent());
    } catch (e) {
      // silent failure on read status
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAllAsRead();
      add(const LoadNotificationsEvent());
    } catch (e) {
      // silent failure
    }
  }
}
