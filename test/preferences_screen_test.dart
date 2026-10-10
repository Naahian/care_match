import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/settings/preferences_controller.dart';
import 'package:care_match/features/settings/presentation/screens/preferences_screen.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() {
    appPreferences.setThemeMode(ThemeMode.light);
    appPreferences.setLargerText(false);
    appPreferences.setShareAnonymousData(true);
  });

  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    testWidgets('Preferences fit $size with large text in both themes', (
      tester,
    ) async {
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
            home: const PreferencesScreen(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('Larger text'), 250);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('Settings navigation and controls update the app', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/home');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesScreen), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Preferences'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(appPreferences.themeMode, ThemeMode.system);
    await tester.scrollUntilVisible(
      find.text('Share anonymized AI chat data'),
      150,
    );
    await tester.tap(find.text('Share anonymized AI chat data'));
    await tester.pumpAndSettle();
    expect(appPreferences.shareAnonymousData, isFalse);
    await tester.scrollUntilVisible(find.text('Larger text'), 150);
    await tester.tap(find.text('Larger text'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Larger text'), 150);
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.text('Larger text')),
      ).scale(14),
      closeTo(16.8, 0.01),
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
