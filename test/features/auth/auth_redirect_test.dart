import 'dart:async';

import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/features/home/presentation/home_screen.dart';
import 'package:care_match/features/profile/presentation/screens/set_up_profile_screen.dart';
import 'package:care_match/features/welcome/presentation/onboarding.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../support/auth_test_scope.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  const user = AuthUser(uid: 'signed-in', emailVerified: true);

  for (final firstOpen in [true, false]) {
    testWidgets('restored session opens Home (first open: $firstOpen)', (
      tester,
    ) async {
      final repository = FakeAuthRepository()..currentUser = user;
      await tester.pumpWidget(
        authTestScope(
          Sizer(builder: (_, _, _) => MyApp(isFirstOpen: firstOpen)),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      final router = container.read(appRouterProvider(firstOpen));
      for (final entry in [
        '/welcome',
        '/auth/login',
        '/auth/create-account',
        '/auth/forgot-password',
      ]) {
        router.go(entry);
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      }
      router.go('/auth/profile', extra: true);
      await tester.pumpAndSettle();
      expect(find.byType(SetUpProfileScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('signed-out returning user stays on Login', (tester) async {
    await tester.pumpWidget(
      authTestScope(
        Sizer(builder: (_, _, _) => const MyApp(isFirstOpen: false)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('unverified session stays on Login', (tester) async {
    final repository = FakeAuthRepository()
      ..currentUser = const AuthUser(uid: 'unverified');
    await tester.pumpWidget(
      authTestScope(
        Sizer(builder: (_, _, _) => const MyApp(isFirstOpen: false)),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('late restored session redirects from Welcome to Home', (
    tester,
  ) async {
    final repository = _SessionRepository();
    addTearDown(repository.sessions.close);
    await tester.pumpWidget(
      authTestScope(
        Sizer(builder: (_, _, _) => const MyApp()),
        repository: repository,
      ),
    );
    await tester.pump();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    repository.currentUser = user;
    repository.sessions.add(user);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    final router = container.read(appRouterProvider(true));
    router.go('/settings');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Log out'), 250);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(repository.currentUser, isNull);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

class _SessionRepository extends FakeAuthRepository {
  final sessions = StreamController<AuthUser?>();

  @override
  Stream<AuthUser?> get authStateChanges => sessions.stream;
}
