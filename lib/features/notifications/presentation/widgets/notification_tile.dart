import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.isUnread,
  });
  final AppNotification notification;
  final bool isUnread;
  IconData get icon => switch (notification.type) {
    NotificationType.appointmentCreated => Icons.event_available_outlined,
    NotificationType.appointmentCancelled => Icons.event_busy_outlined,
    NotificationType.appointmentReminder => Icons.alarm_outlined,
    NotificationType.appointmentCreationFailure => Icons.event_busy_outlined,
    NotificationType.paymentFailure => Icons.payment_outlined,
  };
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      contentPadding: AppSpacing.card,
      tileColor: isUnread
          ? scheme.primaryContainer.withValues(alpha: .28)
          : null,
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.primary,
        child: Icon(icon),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${MaterialLocalizations.of(context).formatMediumDate(notification.createdAt.toLocal())} · ${TimeOfDay.fromDateTime(notification.createdAt.toLocal()).format(context)}',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
      trailing: isUnread
          ? Icon(Icons.circle, size: 9, color: scheme.primary)
          : null,
    );
  }
}
