import 'support/doctors_test_scope.dart';
import 'support/auth_test_scope.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/features/auth/presentation/screens/create_account_screen.dart';
import 'package:care_match/features/auth/presentation/screens/login_screen.dart';
import 'package:care_match/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:care_match/features/profile/presentation/screens/set_up_profile_screen.dart';
import 'package:care_match/features/auth/presentation/screens/verify_number_screen.dart';
import 'package:care_match/features/consultation/presentation/screens/chat_list_screen.dart';
import 'package:care_match/features/consultation/presentation/screens/video_onboarding_screen.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:care_match/shared/widgets/doctor_card.dart';
import 'package:care_match/features/home/presentation/home_screen.dart';
import 'package:care_match/features/welcome/presentation/onboarding.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final destinations = <String, Type>{
    '/welcome': OnboardingScreen,
    '/auth/login': LoginScreen,
    '/auth/forgot-password': ForgotPasswordScreen,
    '/auth/create-account': CreateAccountScreen,
    '/auth/verify-number?phone=%2B880123456789': VerifyNumberScreen,
    '/auth/profile': SetUpProfileScreen,
    '/home': HomeScreen,
    '/doctors?query=skin': FindDoctorScreen,
    '/doctors/dr-emily-carter': DoctorDetailScreen,
    '/consultation/chat': ChatListScreen,
    '/consultation/video': VideoOnboardingScreen,
  };
  for (final entry in destinations.entries) {
    testWidgets('Direct link ${entry.key} builds the existing screen', (
      tester,
    ) async {
      final router = createAppRouter(initialLocation: entry.key);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _routerTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
      );
      if (entry.value == OnboardingScreen) {
        // The welcome illustration floats continuously, so it never settles.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.text('I have a sore throat\nand mild fever.'),
          findsOneWidget,
        );
        expect(find.text('Recommended'), findsOneWidget);
        await tester.tap(find.text('Next'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.text('How are you feeling today?\nAny improvement?'),
          findsOneWidget,
        );
        expect(find.text('I’m feeling better, thank you!'), findsOneWidget);
      } else {
        await tester.pumpAndSettle();
      }
      expect(find.byType(entry.value), findsOneWidget);
      if (entry.value == FindDoctorScreen) {
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'skin',
        );
      }
      if (entry.value == VerifyNumberScreen) {
        expect(
          tester
              .widget<VerifyNumberScreen>(find.byType(VerifyNumberScreen))
              .phoneNumber,
          '+880123456789',
        );
      }
      if (entry.value == SetUpProfileScreen) {
        expect(
          tester
              .widget<SetUpProfileScreen>(find.byType(SetUpProfileScreen))
              .isEditProfile,
          isFalse,
        );
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'Doctor selection preserves the doctor and supports back navigation',
    (tester) async {
      final router = createAppRouter(initialLocation: '/doctors');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _routerTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
      );
      await tester.pumpAndSettle();
      final card = find.byType(DoctorCard).first;
      expect(card, findsOneWidget);
      final name = find.text('Dr. Farzana Rahman');
      await tester.ensureVisible(name);
      await tester.pumpAndSettle();
      await tester.tap(name);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DoctorDetailScreen>(find.byType(DoctorDetailScreen))
            .profile
            .summary
            .name,
        'Dr. Farzana Rahman',
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(FindDoctorScreen), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets('Auth UI flow reaches home and clears the auth back stack', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/auth/login');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _routerTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateAccountScreen), findsOneWidget);
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '9876543210',
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    final create = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();
    expect(find.byType(VerifyNumberScreen), findsOneWidget);
    expect(
      tester
          .widget<VerifyNumberScreen>(find.byType(VerifyNumberScreen))
          .phoneNumber,
      '+19876543210',
    );
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    final verify = find.widgetWithText(FilledButton, 'Verify & continue');
    await tester.ensureVisible(verify);
    await tester.tap(verify);
    await tester.pumpAndSettle();
    expect(find.byType(SetUpProfileScreen), findsOneWidget);
    expect(
      tester
          .widget<SetUpProfileScreen>(find.byType(SetUpProfileScreen))
          .isEditProfile,
      isFalse,
    );
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(router.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Edit profile opens setup in edit mode', (tester) async {
    final router = createAppRouter(initialLocation: '/profile');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _routerTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SetUpProfileScreen>(find.byType(SetUpProfileScreen))
          .isEditProfile,
      isTrue,
    );
    expect(find.text('Save Edits'), findsOneWidget);
    expect(find.text('Skip for now'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Unknown doctor links do not show an unrelated sample profile', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/doctors/unknown');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _routerTestScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Doctor not found'), findsOneWidget);
    expect(find.byType(DoctorDetailScreen), findsNothing);
    router.goNamed(AppRoutes.video);
    await tester.pumpAndSettle();
    expect(find.byType(VideoOnboardingScreen), findsOneWidget);
  });
}

Widget _routerTestScope(Widget child) =>
    authTestScope(child, doctorsRepository: TestDoctorsRepository());
