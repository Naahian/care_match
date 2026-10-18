import 'support/appointments_test_scope.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:care_match/features/records/presentation/screens/my_reports_screen.dart';
import 'package:care_match/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:care_match/features/appointments/presentation/widgets/patient_appointment_card.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/profile/domain/entities/user_profile.dart';
import 'package:care_match/features/profile/domain/repositories/profile_repository.dart';
import 'package:care_match/features/profile/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

Widget _profileScope(Widget child) => ProviderScope(
  overrides: [
    profileRepositoryProvider.overrideWithValue(_EmptyProfileRepository()),
    appointmentsRepositoryProvider.overrideWithValue(
      TestAppointmentsRepository(),
    ),
    doctorsRepositoryProvider.overrideWithValue(
      TestAppointmentDoctorsRepository(),
    ),
    authSessionProvider.overrideWith((ref) => const Stream.empty()),
  ],
  child: child,
);

class _EmptyProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getProfile() async => const UserProfile();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Patient pages fit $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final screen in [
        _profileScope(const MyProfileScreen()),
        const MyReportsScreen(),
        appointmentsTestScope(const MyAppointmentsScreen()),
      ]) {
        await tester.pumpWidget(
          Sizer(
            builder: (_, _, _) => MaterialApp(
              theme: size.width > 600 ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.5)),
                child: child!,
              ),
              home: screen,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('Appointment tabs show matching records without detail actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => MaterialApp(
          theme: AppTheme.light,
          home: appointmentsTestScope(const MyAppointmentsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientAppointmentCard), findsOneWidget);
    expect(find.text('Join video'), findsNothing);
    expect(find.text('View details'), findsNothing);
    await tester.tap(find.text('Dr. Emily Carter'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cancelled'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. James Patel'), findsOneWidget);
    expect(find.text('Reschedule'), findsNothing);
  });

  testWidgets('Profile destinations open reports and appointments', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/profile');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _profileScope(Sizer(builder: (_, _, _) => MyApp(router: router))),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('My Reports'), 200);
    await tester.tap(find.text('My Reports'));
    await tester.pumpAndSettle();
    expect(find.byType(MyReportsScreen), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('My Appointments'), 200);
    await tester.tap(find.text('My Appointments'));
    await tester.pumpAndSettle();
    expect(find.byType(MyAppointmentsScreen), findsOneWidget);
  });

  testWidgets(
    'Upcoming appointments show server statuses and cancellation actions',
    (tester) async {
      final router = createAppRouter(initialLocation: '/appointments');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        appointmentsTestScope(
          Sizer(builder: (_, _, _) => MyApp(router: router)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PatientAppointmentCard), findsWidgets);
      expect(find.text('Requested'), findsWidgets);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Join video'), findsNothing);
      expect(find.text('Join chat'), findsNothing);
      await tester.scrollUntilVisible(find.text('Dr. Sophia Nguyen'), 200);
      expect(find.text('Cancel appointment'), findsWidgets);
      expect(find.text('Reschedule'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
