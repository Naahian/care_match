import 'package:care_match/core/services/storage_service.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/features/welcome/presentation/onboarding.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'support/auth_test_scope.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final initialValue in [null, false, true]) {
    testWidgets('startup routes correctly with opened flag $initialValue', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues({
        if (initialValue != null)
          StorageService.hasOpenedKey: initialValue.toString(),
      });
      final storage = StorageService();
      final router = createAppRouter(
        isFirstOpen: await storage.checkAndMarkFirstOpen(),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        authTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
      );
      // The welcome illustration animates continuously.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        router.routeInformationProvider.value.uri.path,
        initialValue == true ? '/auth/login' : '/welcome',
      );
      expect(
        find.byType(initialValue == true ? LoginScreen : OnboardingScreen),
        findsOneWidget,
      );
      expect(await storage.readBool(key: StorageService.hasOpenedKey), isTrue);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      final nextRouter = createAppRouter(
        isFirstOpen: await StorageService().checkAndMarkFirstOpen(),
      );
      addTearDown(nextRouter.dispose);
      await tester.pumpWidget(
        authTestScope(Sizer(builder: (_, _, _) => MyApp(router: nextRouter))),
      );
      await tester.pumpAndSettle();
      expect(nextRouter.routeInformationProvider.value.uri.path, '/auth/login');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
