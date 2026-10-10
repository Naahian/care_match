import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../models/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.isUnread,
    this.onTap,
  });

  final AppNotification notification;
  final bool isUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isReport = notification.category == NotificationCategory.report;
    return Semantics(
      label: isUnread ? 'Unread notification' : 'Read notification',
      child: ListTile(
        onTap: onTap,
        contentPadding: AppSpacing.card,
        tileColor: isUnread
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        leading: CircleAvatar(
          backgroundColor: isReport
              ? scheme.secondaryContainer
              : scheme.primaryContainer,
          foregroundColor: isReport ? scheme.secondary : scheme.primary,
          child: Icon(notification.icon),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                notification.timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUnread)
              Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
