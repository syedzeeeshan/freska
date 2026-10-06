import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/features/notifications/domain/entities/notification_entity.dart';
import 'package:freska_rider/features/notifications/domain/repositories/notification_repository.dart';
import 'package:freska_rider/features/notifications/presentation/blocs/notification_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;
  late NotificationBloc notificationBloc;

  setUp(() {
    mockRepository = MockNotificationRepository();
    notificationBloc = NotificationBloc(repository: mockRepository);
  });

  tearDown(() {
    notificationBloc.close();
  });

  const tNotifications = [
    NotificationEntity(
      id: 1,
      title: 'Order Offer Dispatched',
      body: 'New delivery assignment #8942 offered to you.',
      type: 'order_assignment',
      isRead: false,
      createdAt: '2026-09-24T09:00:00Z',
    ),
  ];

  test('initial state should be NotificationInitial', () {
    expect(notificationBloc.state, equals(NotificationInitial()));
  });

  blocTest<NotificationBloc, NotificationState>(
    'emits [NotificationLoading, NotificationsLoaded] when LoadNotificationsEvent succeeds',
    build: () {
      when(() => mockRepository.getNotifications(page: any(named: 'page')))
          .thenAnswer((_) async => {
                'notifications': tNotifications,
                'unread_count': 1,
              });
      return notificationBloc;
    },
    act: (bloc) => bloc.add(const LoadNotificationsEvent()),
    expect: () => [
      NotificationLoading(),
      const NotificationsLoaded(notifications: tNotifications, unreadCount: 1),
    ],
  );
}
