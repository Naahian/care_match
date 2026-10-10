import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/features/auth/presentation/screens/create_account_screen.dart';
import 'package:care_match/features/auth/presentation/screens/verify_number_screen.dart';
import 'package:care_match/features/auth/presentation/screens/set_up_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

Widget app(Widget screen, {double textScale = 1, bool dark = false}) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: screen,
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Auth screens fit $size with large text and keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      addTearDown(tester.view.reset);
      for (final screen in [
        const LoginScreen(),
        const CreateAccountScreen(),
        const VerifyNumberScreen(),
        const SetUpProfileScreen(),
      ]) {
        await tester.pumpWidget(
          app(screen, textScale: 1.5, dark: size.width > 600),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('Password visibility toggles without losing entered text', (
    tester,
  ) async {
    await tester.pumpWidget(app(const LoginScreen()));
    final password = find.byType(TextFormField).last;
    await tester.enterText(password, 'my-password');
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: password, matching: find.byType(TextField)),
          )
          .obscureText,
      isFalse,
    );
    expect(find.text('my-password'), findsOneWidget);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: password, matching: find.byType(TextField)),
          )
          .obscureText,
      isTrue,
    );
  });

  testWidgets('Account creation requires accepting the terms', (tester) async {
    await tester.pumpWidget(app(const CreateAccountScreen()));
    final button = find.widgetWithText(FilledButton, 'Create account');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('Verification AppBar shows a working back button when pushed', (
    tester,
  ) async {
    await tester.pumpWidget(app(const Scaffold(body: Text('Previous screen'))));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const VerifyNumberScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Previous screen'), findsOneWidget);
    expect(find.byType(VerifyNumberScreen), findsNothing);
  });

  testWidgets(
    'OTP filters pasted input and enables verification at six digits',
    (tester) async {
      await tester.pumpWidget(app(const VerifyNumberScreen()));
      final button = find.widgetWithText(FilledButton, 'Verify & continue');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'a2849167');
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '284916',
      );
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await tester.enterText(find.byType(TextField), '28');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.pump(const Duration(seconds: 24));
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Resend'))
            .onPressed,
        isNotNull,
      );
      await tester.ensureVisible(find.text('Resend'));
      await tester.tap(find.text('Resend'));
      await tester.pump();
      expect(find.text('Resend code in 00:24'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Profile selections update locally', (tester) async {
    await tester.pumpWidget(app(const SetUpProfileScreen()));
    await tester.tap(find.text('Select your gender'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();
    expect(find.text('Female'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
