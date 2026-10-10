import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:care_match/features/records/presentation/screens/my_reports_screen.dart';
import 'package:care_match/features/records/presentation/widgets/medical_report_card.dart';
import 'package:care_match/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:care_match/features/appointments/presentation/widgets/patient_appointment_card.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:care_match/features/consultation/presentation/screens/chat_list_screen.dart';
import 'package:care_match/features/consultation/presentation/screens/video_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Patient pages fit $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final screen in [
        const MyProfileScreen(),
        const MyReportsScreen(),
        const MyAppointmentsScreen(),
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

  testWidgets(
    'Reports combine category and search filters, with an empty state',
    (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) =>
              MaterialApp(theme: AppTheme.light, home: const MyReportsScreen()),
        ),
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lab'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Thyroid');
      await tester.pumpAndSettle();
      expect(find.byType(MedicalReportCard), findsOneWidget);
      expect(find.text('Thyroid Panel'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'not a report');
      await tester.pumpAndSettle();
      expect(find.text('No reports found.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Prescriptions'));
      await tester.pumpAndSettle();
      expect(find.text('Prescription'), findsOneWidget);
    },
  );

  testWidgets('Appointment tabs show matching records and details', (
    tester,
  ) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => MaterialApp(
          theme: AppTheme.light,
          home: const MyAppointmentsScreen(),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientAppointmentCard), findsOneWidget);
    expect(find.text('Join video'), findsNothing);
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(find.text('Appointment details'), findsOneWidget);
    Navigator.of(tester.element(find.text('Appointment details'))).pop();
    await tester.pumpAndSettle();
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
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
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

  testWidgets('Upcoming appointments join video or chat without rescheduling', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/appointments');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    for (final entry in {
      'Join video': VideoOnboardingScreen,
      'Join chat': ChatListScreen,
    }.entries) {
      await tester.scrollUntilVisible(find.text(entry.key), 200);
      expect(find.text('Reschedule'), findsNothing);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(find.text('Dr. Sophia Nguyen'), 200);
    final inPersonCard = find.ancestor(
      of: find.text('Dr. Sophia Nguyen'),
      matching: find.byType(PatientAppointmentCard),
    );
    expect(
      find.descendant(of: inPersonCard, matching: find.byType(FilledButton)),
      findsNothing,
    );
    expect(
      find.descendant(of: inPersonCard, matching: find.text('View details')),
      findsOneWidget,
    );
    expect(find.text('Reschedule'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
