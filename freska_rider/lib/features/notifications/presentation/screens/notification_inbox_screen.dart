import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../blocs/notification_bloc.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationsEvent());
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order_assignment':
        return Icons.delivery_dining_rounded;
      case 'payout_credited':
        return Icons.account_balance_wallet_rounded;
      case 'security_alert':
        return Icons.security_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'order_assignment':
        return StitchColors.primaryFresh;
      case 'payout_credited':
        return StitchColors.accentGold;
      case 'security_alert':
        return StitchColors.dangerSOS;
      default:
        return StitchColors.infoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark All as Read',
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(const MarkAllNotificationsAsReadEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            final list = state.notifications;

            if (list.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => context
                    .read<NotificationBloc>()
                    .add(const LoadNotificationsEvent()),
                child: ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded,
                              size: 64, color: StitchColors.textSecondaryDark),
                          SizedBox(height: 16),
                          Text(
                            'Inbox is clear! No notifications.',
                            style: TextStyle(
                                color: StitchColors.textSecondaryDark,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => context
                  .read<NotificationBloc>()
                  .add(const LoadNotificationsEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notif = list[index];
                  final iconColor = _getColorForType(notif.type);

                  return InkWell(
                    onTap: () {
                      if (!notif.isRead) {
                        context
                            .read<NotificationBloc>()
                            .add(MarkNotificationAsReadEvent(id: notif.id));
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif.isRead
                            ? StitchColors.darkSurface
                            : StitchColors.darkSurfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: notif.isRead
                              ? StitchColors.darkBorder
                              : iconColor.withValues(alpha: 0.5),
                          width: notif.isRead ? 1 : 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIconForType(notif.type),
                                color: iconColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: notif.isRead
                                              ? FontWeight.w600
                                              : FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: StitchColors.primaryFresh,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notif.body,
                                  style: const TextStyle(
                                      color: StitchColors.textSecondaryDark,
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif.createdAt.substring(0, 10),
                                  style: TextStyle(
                                    color: StitchColors.textSecondaryDark
                                        .withValues(alpha: 0.6),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: StitchColors.dangerSOS)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
