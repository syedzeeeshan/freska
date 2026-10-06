import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final int id;

  const MarkNotificationAsReadEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}
