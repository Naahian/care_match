import 'support/auth_test_scope.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final destination in [AppRoutes.profile, AppRoutes.preferences]) {
    testWidgets('Logout from $destination clears the navigation stack', (
      tester,
    ) async {
      final router = createAppRouter(initialLocation: '/home');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        authTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
      );
      await tester.pumpAndSettle();
      router.pushNamed(destination);
      await tester.pumpAndSettle();
      expect(router.canPop(), isTrue);
      await tester.scrollUntilVisible(find.text('Log out'), 250);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
