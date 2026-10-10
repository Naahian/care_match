import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';

enum NotificationCategory {
  appointment,
  report,
  message,
  account,
  announcement,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.category,
    this.routeName,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final NotificationCategory category;
  final String? routeName;
  final bool isUnread;

  IconData get icon => switch (category) {
    NotificationCategory.appointment => Icons.calendar_month_outlined,
    NotificationCategory.report => Icons.description_outlined,
    NotificationCategory.message => Icons.chat_bubble_outline_rounded,
    NotificationCategory.account => Icons.person_outline_rounded,
    NotificationCategory.announcement => Icons.notifications_none_rounded,
  };
}

// Preview data until the notification service provides the patient's inbox.
const sampleNotifications = [
  AppNotification(
    id: 'appointment-reminder',
    title: 'Your appointment is coming up',
    message: 'Review your upcoming visits and appointment details.',
    timeLabel: '5 minutes ago',
    category: NotificationCategory.appointment,
    routeName: AppRoutes.appointments,
    isUnread: true,
  ),
  AppNotification(
    id: 'report-ready',
    title: 'Your report is ready',
    message: 'View your latest lab reports and medical records.',
    timeLabel: '30 minutes ago',
    category: NotificationCategory.report,
    routeName: AppRoutes.reports,
    isUnread: true,
  ),
  AppNotification(
    id: 'new-message',
    title: 'You have a new message',
    message: 'Open your conversations to catch up with your care team.',
    timeLabel: '1 hour ago',
    category: NotificationCategory.message,
    routeName: AppRoutes.chat,
    isUnread: true,
  ),
  AppNotification(
    id: 'welcome',
    title: 'Welcome to CareMatch',
    message: 'Your health, records, and care team, all in one place.',
    timeLabel: 'Yesterday',
    category: NotificationCategory.announcement,
  ),
  AppNotification(
    id: 'profile-reminder',
    title: 'Keep your profile up to date',
    message:
        'Check your personal details to help doctors understand your needs.',
    timeLabel: 'Yesterday',
    category: NotificationCategory.account,
    routeName: AppRoutes.profile,
  ),
  AppNotification(
    id: 'privacy-notice',
    title: 'Your privacy matters',
    message: 'CareMatch keeps you in control of your health information.',
    timeLabel: '2 days ago',
    category: NotificationCategory.announcement,
  ),
];
