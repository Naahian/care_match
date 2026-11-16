import 'support/appointments_test_scope.dart';
import 'package:care_match/core/theme/theme.dart';
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

  testWidgets('Notification tab opens with an empty inbox', (tester) async {
    final router = createAppRouter(initialLocation: '/home');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      appointmentsTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.byType(NotificationTile), findsNothing);
    expect(find.text('Mark all as read'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    testWidgets('Notifications fit $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        await tester.pumpWidget(
          appointmentsTestScope(
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
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('No notifications yet'), findsOneWidget);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
