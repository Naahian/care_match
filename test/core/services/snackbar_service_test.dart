import 'package:care_match/core/services/snackbar_service.dart';
import 'package:care_match/core/theme/theme_extensions.dart';
import 'package:care_match/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('the app connects the global service to its root messenger', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: SizedBox()),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    snackbar.success('Global notification');
    await tester.pumpAndSettle();
    expect(find.text('Global notification'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    final extras = AppExtras.forBrightness(brightness);
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );
    final theme = ThemeData(colorScheme: scheme, extensions: [extras]);

    for (final type in ['success', 'failed', 'info']) {
      testWidgets('$type uses semantic colors and icon in $brightness', (
        tester,
      ) async {
        final service = SnackbarService();
        await tester.pumpWidget(
          MaterialApp(
            scaffoldMessengerKey: service.messengerKey,
            theme: theme,
            home: const Scaffold(body: SizedBox()),
          ),
        );
        final (background, foreground, icon) = switch (type) {
          'success' => (
            extras.successContainer,
            extras.onSuccessContainer,
            Icons.check_circle_outline_rounded,
          ),
          'failed' => (
            scheme.errorContainer,
            scheme.onErrorContainer,
            Icons.error_outline_rounded,
          ),
          _ => (
            extras.infoContainer,
            extras.onInfoContainer,
            Icons.info_outline_rounded,
          ),
        };
        switch (type) {
          case 'success':
            service.success('Saved');
          case 'failed':
            service.failed('Saved');
          default:
            service.info('Saved');
        }
        await tester.pumpAndSettle();
        expect(find.text('Saved'), findsOneWidget);
        expect(find.byIcon(icon), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          background,
        );
        expect(
          tester.widget<Text>(find.text('Saved')).style!.color,
          foreground,
        );
        expect(tester.widget<Icon>(find.byIcon(icon)).color, foreground);
      });
    }
  }

  testWidgets('a new notification replaces queued notifications', (
    tester,
  ) async {
    final service = SnackbarService();
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: service.messengerKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    service.success('First');
    await tester.pumpAndSettle();
    service.info('Second');
    service.failed('Latest');
    await tester.pumpAndSettle();
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('calls during build are displayed after the frame', (
    tester,
  ) async {
    final service = SnackbarService();
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: service.messengerKey,
        home: Builder(
          builder: (_) {
            service.info('Ready');
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmounted messenger and empty messages are ignored', (
    tester,
  ) async {
    final service = SnackbarService();
    expect(() => service.info('Before mount'), returnsNormally);
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: service.messengerKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    service.info('  ');
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(() => service.failed('After disposal'), returnsNormally);
  });
}
