import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/welcome/presentation/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final (size, scale) in [
    (const Size(402, 930), 1.0),
    (const Size(320, 568), 1.5),
  ]) {
    testWidgets('All welcome illustrations and controls fit at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var starts = 0;
      var logins = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: OnboardingScreen(
            onGetStarted: () => starts++,
            onLogin: () => logins++,
          ),
        ),
      );

      for (final (index, asset) in [
        'welcome_2.png',
        'welcome_1.png',
        'welcome_3.png',
        'welcome_4.png',
      ].indexed) {
        final artwork = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == 'assets/images/$asset',
        );
        expect(artwork, findsOneWidget);
        await tester.ensureVisible(artwork);
        await tester.pump();
        final viewport = tester.getRect(find.byType(PageView));
        final imageBounds = tester.getRect(artwork);
        expect(imageBounds.height, greaterThan(0), reason: asset);
        expect(viewport.overlaps(imageBounds), isTrue, reason: asset);
        expect(tester.takeException(), isNull);
        if (index < 3) {
          await tester.tap(find.text('Next'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
      await tester.tap(find.text('Get started'));
      await tester.tap(find.text('Log in'));
      expect(starts, 1);
      expect(logins, 1);
    });
  }
}
