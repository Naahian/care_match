import 'support/appointments_test_scope.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:care_match/features/records/presentation/screens/my_reports_screen.dart';
import 'package:care_match/features/consultation/presentation/screens/chat_list_screen.dart';
import 'package:care_match/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:care_match/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:care_match/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'Notification tab opens and actionable tiles route to their screens',
    (tester) async {
      final router = createAppRouter(initialLocation: '/home');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        appointmentsTestScope(
          Sizer(builder: (_, _, _) => MyApp(router: router)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('3 unread notifications'), findsOneWidget);
      for (final entry in {
        'Your appointment is coming up': MyAppointmentsScreen,
        'Your report is ready': MyReportsScreen,
        'You have a new message': ChatListScreen,
        'Keep your profile up to date': MyProfileScreen,
      }.entries) {
        await tester.ensureVisible(find.text(entry.key));
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(find.byType(entry.value), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
      }
      await tester.scrollUntilVisible(find.text('You’re all caught up'), -200);
      expect(find.text('You’re all caught up'), findsOneWidget);
      final informationalTile = tester.widget<NotificationTile>(
        find.ancestor(
          of: find.text('Welcome to CareMatch'),
          matching: find.byType(NotificationTile),
        ),
      );
      expect(informationalTile.onTap, isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Mark all as read clears unread indicators', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const NotificationsScreen()),
    );
    await tester.tap(find.text('Mark all as read'));
    await tester.pump();
    expect(find.text('You’re all caught up'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Mark all as read'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widgetList<NotificationTile>(find.byType(NotificationTile))
          .every((tile) => !tile.isUnread),
      isTrue,
    );
  });

  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    testWidgets('Notifications fit $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const NotificationsScreen(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Your privacy matters'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
