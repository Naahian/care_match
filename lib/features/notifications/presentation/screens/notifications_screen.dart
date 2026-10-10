import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../models/app_notification.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<String> _readIds = {};

  bool _isUnread(AppNotification notification) =>
      notification.isUnread && !_readIds.contains(notification.id);

  void _openNotification(AppNotification notification) {
    final route = notification.routeName;
    if (route == null) return;
    setState(() => _readIds.add(notification.id));
    context.pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = sampleNotifications.where(_isUnread).length;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  children: [
                    Text(
                      unreadCount == 0
                          ? 'You’re all caught up'
                          : '$unreadCount unread notifications',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: unreadCount == 0
                          ? null
                          : () => setState(
                              () => _readIds.addAll(
                                sampleNotifications.map(
                                  (notification) => notification.id,
                                ),
                              ),
                            ),
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < sampleNotifications.length;
                        index++
                      ) ...[
                        if (index > 0) const Divider(),
                        NotificationTile(
                          notification: sampleNotifications[index],
                          isUnread: _isUnread(sampleNotifications[index]),
                          onTap: sampleNotifications[index].routeName == null
                              ? null
                              : () => _openNotification(
                                  sampleNotifications[index],
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(current: 2),
    );
  }
}
