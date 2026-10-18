import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/core/providers.dart';
import 'package:care_match/core/services/firebase_auth_service.dart';
import 'package:care_match/features/auth/presentation/screens/create_account_screen.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../support/auth_test_scope.dart' show SilentSnackbar;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final baseUrl in ['', 'not-a-url']) {
    testWidgets('auth routes and Firebase login work with API URL "$baseUrl"', (
      tester,
    ) async {
      final firebase = _SignedOutFirebaseAuth();
      final router = createAppRouter(initialLocation: '/auth/login');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthServiceProvider.overrideWithValue(
              FirebaseAuthService(auth: firebase),
            ),
            apiBaseUrlProvider.overrideWithValue(baseUrl),
            snackbarProvider.overrideWithValue(SilentSnackbar()),
          ],
          child: Sizer(
            builder: (_, _, _) => MaterialApp.router(routerConfig: router),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'patient@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      final login = find.widgetWithText(FilledButton, 'Log in');
      await tester.ensureVisible(login);
      await tester.pumpAndSettle();
      await tester.tap(login);
      await tester.pumpAndSettle();
      expect(firebase.signInCalls, 1);
      expect(find.text('The email or password is incorrect.'), findsOneWidget);

      router.pushNamed(AppRoutes.createAccount);
      await tester.pumpAndSettle();
      expect(find.byType(CreateAccountScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Patient',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'patient@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Configure API_BASE_URL with your backend URL before creating an account.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CreateAccountScreen)),
      );
      expect(container.read(authControllerProvider).isLoading, isFalse);
      expect(container.read(authRepositoryProvider).currentUser, isNull);
      // The failed API provider must not poison the auth providers or routing.
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _SignedOutFirebaseAuth implements FirebaseAuth {
  int signInCalls = 0;
  @override
  User? get currentUser => null;
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
  @override
  Stream<User?> idTokenChanges() => const Stream.empty();
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    throw FirebaseAuthException(code: 'invalid-credential');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
