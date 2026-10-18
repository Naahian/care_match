import 'dart:async';

import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/presentation/screens/create_account_screen.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:care_match/features/auth/presentation/screens/verify_number_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../support/auth_test_scope.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  late FakeAuthRepository repository;
  late GoRouter router;

  Future<void> mount(WidgetTester tester, {bool signup = false}) async {
    repository = FakeAuthRepository();
    router = GoRouter(
      initialLocation: signup ? '/signup' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          name: AppRoutes.login,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: AppRoutes.forgotPassword,
          builder: (_, _) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: AppRoutes.createAccount,
          builder: (_, _) => const CreateAccountScreen(),
        ),
        GoRoute(
          path: '/verify',
          name: AppRoutes.verifyNumber,
          builder: (_, state) => VerifyNumberScreen(
            phoneNumber: state.uri.queryParameters['phone']!,
          ),
        ),
        GoRoute(
          path: '/home',
          name: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('Authenticated home')),
        ),
        GoRoute(
          path: '/profile',
          name: AppRoutes.setUpProfile,
          builder: (_, _) => const Scaffold(body: Text('Profile setup')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      authTestScope(
        Sizer(builder: (_, _, _) => MaterialApp.router(routerConfig: router)),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(
    WidgetTester tester,
    String label, {
    Type buttonType = FilledButton,
  }) async {
    await tester.pumpAndSettle();
    final finder = find.widgetWithText(buttonType, label);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> signupFields(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Test Patient',
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
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
  }

  testWidgets('login validates inputs without calling authentication', (
    tester,
  ) async {
    await mount(tester);
    await tap(tester, 'Log in');
    expect(repository.signInCalls, 0);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/login');
  });

  testWidgets(
    'login uses entered credentials and waits for success before navigation',
    (tester) async {
      await mount(tester);
      repository.pendingSignIn = Completer<AuthUser>();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'patient@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        ' secret ',
      );
      await tap(tester, 'Log in');
      expect(repository.email, 'patient@example.com');
      expect(repository.password, ' secret ');
      expect(router.routeInformationProvider.value.uri.path, '/login');
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Log in'))
            .onPressed,
        isNull,
      );
      repository.pendingSignIn!.complete(
        const AuthUser(uid: 'email-user', emailVerified: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Authenticated home'), findsOneWidget);
    },
  );

  testWidgets('failed login displays feedback and remains on login', (
    tester,
  ) async {
    await mount(tester);
    repository.error = FirebaseAuthException(code: 'invalid-credential');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'patient@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tap(tester, 'Log in');
    await tester.pumpAndSettle();
    expect(find.text('The email or password is incorrect.'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/login');
  });

  testWidgets(
    'forgot password validates email, sends a reset, and returns to login',
    (tester) async {
      await mount(tester);
      await tester.ensureVisible(find.text('Forgot password?'));
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      await tap(tester, 'Send reset link');
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(repository.resetEmail, isNull);
      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tap(tester, 'Send reset link');
      await tester.pumpAndSettle();
      expect(repository.resetEmail, isNull);
      await tester.enterText(
        find.byType(TextFormField),
        '  patient@example.com  ',
      );
      repository.pendingPasswordReset = Completer<void>();
      await tap(tester, 'Send reset link');
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
        isFalse,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      repository.pendingPasswordReset!.complete();
      await tester.pumpAndSettle();
      expect(repository.resetEmail, 'patient@example.com');
      expect(repository.signInCalls, 0);
      expect(find.text('Check your inbox'), findsOneWidget);
      await tap(tester, 'Back to log in', buttonType: TextButton);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/login');
    },
  );

  testWidgets('failed password reset shows an error and permits retry', (
    tester,
  ) async {
    await mount(tester);
    router.goNamed(AppRoutes.forgotPassword);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'patient@example.com');
    repository.error = FirebaseAuthException(code: 'network-request-failed');
    await tap(tester, 'Send reset link');
    await tester.pumpAndSettle();
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
    expect(find.text('Check your inbox'), findsNothing);
    repository.error = null;
    await tap(tester, 'Send reset link');
    await tester.pumpAndSettle();
    expect(find.text('Check your inbox'), findsOneWidget);
    await tap(tester, 'Use another email', buttonType: TextButton);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);
    await tap(tester, 'Back to log in', buttonType: TextButton);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets(
    'backend sign-up shows email verification before returning to login',
    (tester) async {
      await mount(tester, signup: true);
      await signupFields(tester);
      await tap(tester, 'Create account');
      await tester.pumpAndSettle();
      expect(repository.signUpCalls, 1);
      expect(repository.name, 'Test Patient');
      expect(repository.verificationEmailCalls, 0);
      expect(repository.currentUser, isNull);
      expect(repository.phoneRequests, 0);
      expect(repository.email, 'patient@example.com');
      expect(repository.password, 'secret123');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Verify email before sign in'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('patient@example.com'),
        ),
        findsOneWidget,
      );
      expect(find.text('Authenticated home'), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/signup');
      await tap(tester, 'Go to sign in');
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/login');
    },
  );

  testWidgets('doctor signup validates and submits all doctor details', (
    tester,
  ) async {
    await mount(tester, signup: true);
    await tester.ensureVisible(find.byType(DropdownButtonFormField<bool>));
    await tester.tap(find.byType(DropdownButtonFormField<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Doctor').last);
    await tester.pumpAndSettle();
    await signupFields(tester);
    await tap(tester, 'Create account');
    await tester.pumpAndSettle();
    expect(repository.signUpCalls, 0);
    expect(find.text('Select at least one available day.'), findsOneWidget);
    expect(find.text('Select a start and end time.'), findsOneWidget);
    for (final entry in {
      'Phone number': '+8801700000000',
      'Specialties': 'Cardiology, Internal medicine',
      'Degrees': 'MBBS, MD',
      'Clinic 1 name': 'Care Clinic',
      'Clinic 1 location': 'Dhaka',
    }.entries) {
      final field = find.widgetWithText(TextFormField, entry.key);
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
    }
    for (final entry in {
      'Start 1: Select time': const TimeOfDay(hour: 9, minute: 0),
      'End 1: Select time': const TimeOfDay(hour: 17, minute: 0),
    }.entries) {
      final button = find.text(entry.key);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(TimePickerDialog)),
      ).pop(entry.value);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('Monday'));
    await tester.tap(find.text('Monday'));
    await tester.pump();
    await tap(tester, 'Create account');
    await tester.pumpAndSettle();
    expect(repository.signUpCalls, 1);
    final doctor = repository.doctorDetails!;
    expect(doctor.phone, '+8801700000000');
    expect(doctor.clinics.single.name, 'Care Clinic');
    expect(doctor.clinics.single.location, 'Dhaka');
    expect(doctor.specialties, ['Cardiology', 'Internal medicine']);
    expect(doctor.degrees, ['MBBS', 'MD']);
    expect(doctor.timeAvailable.single.start, '09:00:00');
    expect(doctor.timeAvailable.single.end, '17:00:00');
    expect(doctor.daysAvailable, ['Monday']);
    expect(repository.currentUser, isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/signup');
    await tap(tester, 'Go to sign in');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
  });

  testWidgets('unverified email cannot navigate to home', (tester) async {
    await mount(tester);
    repository.emailVerified = false;
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'patient@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tap(tester, 'Log in');
    await tester.pumpAndSettle();
    expect(repository.currentUser, isNull);
    expect(repository.verificationEmailCalls, 1);
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(
      find.textContaining('Verify your email before signing in.'),
      findsOneWidget,
    );
  });

  testWidgets('sign-up failure does not request SMS or navigate', (
    tester,
  ) async {
    await mount(tester, signup: true);
    repository.error = FirebaseAuthException(code: 'email-already-in-use');
    await signupFields(tester);
    await tap(tester, 'Create account');
    await tester.pumpAndSettle();
    expect(repository.phoneRequests, 0);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text('An account already uses this email address.'),
      findsOneWidget,
    );
    expect(router.routeInformationProvider.value.uri.path, '/signup');
  });
}
