import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/doctor_portal/portal_controller.dart';
import 'package:care_match/features/doctor_portal/presentation/models/portal_patient.dart';
import 'package:care_match/features/doctor_portal/presentation/screens/doctor_dashboard_screen.dart';
import 'package:care_match/features/doctor_portal/presentation/screens/patient_queue_screen.dart';
import 'package:care_match/features/doctor_portal/presentation/screens/doctor_schedule_screen.dart';
import 'package:care_match/features/doctor_portal/presentation/screens/doctor_portal_profile_screen.dart';
import 'package:care_match/features/doctor_portal/presentation/widgets/portal_schedule_tile.dart';
import 'package:care_match/features/doctor_portal/presentation/widgets/portal_stat_card.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() {
    doctorPortal.setStatus('sarah', QueueStatus.waiting);
    doctorPortal.selectDate(doctorPortal.today);
    doctorPortal.setAvailable(true);
    doctorPortal.updateProfile(
      doctorName: 'Dr. Emily Carter',
      doctorSpecialty: 'Internal Medicine',
    );
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1024, 768),
  ]) {
    testWidgets('Portal screens fit $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        for (final screen in [
          const DoctorDashboardScreen(),
          const PatientQueueScreen(),
          const DoctorScheduleScreen(),
          const DoctorPortalProfileScreen(),
        ]) {
          await tester.pumpWidget(
            Sizer(
              builder: (_, _, _) => MaterialApp(
                theme: theme,
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
          if (screen is DoctorDashboardScreen) {
            await tester.scrollUntilVisible(
              find.byType(GridView),
              200,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            final cards = find.byType(PortalStatCard);
            expect(cards, findsNWidgets(4));
            final firstSize = tester.getSize(cards.first);
            for (var index = 1; index < 4; index++) {
              expect(tester.getSize(cards.at(index)), firstSize);
            }
          }
          final scrollable = find.byType(Scrollable).first;
          await tester.drag(scrollable, const Offset(0, -800));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      }
    });
  }

  testWidgets('Tabs navigate and consultations update queue counts', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/doctor-portal');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorDashboardScreen), findsOneWidget);
    await tester.tap(find.text('Queue'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientQueueScreen), findsOneWidget);
    expect(find.text('Waiting (4)'), findsOneWidget);
    await tester.tap(find.text('View details').first);
    await tester.pumpAndSettle();
    expect(find.text('Patient details'), findsOneWidget);
    expect(find.text('Persistent headache and fatigue'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start consult').first);
    await tester.pumpAndSettle();
    expect(doctorPortal.count(QueueStatus.ongoing), 2);
    await tester.tap(find.text('Mark completed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting (3)'), findsOneWidget);
    await tester.tap(find.text('Completed (4)'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Johnson'), findsOneWidget);
    expect(find.text('Start consult'), findsNothing);
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorScheduleScreen), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorPortalProfileScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back to dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorDashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Schedule availability applies to the selected date', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/doctor-portal/schedule');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit availability'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unavailable'));
    await tester.pumpAndSettle();
    expect(doctorPortal.available, isFalse);
    expect(
      find.byTooltip(
        'Add appointment at ${const TimeOfDay(hour: 9, minute: 0).format(tester.element(find.byType(DoctorScheduleScreen)))}',
      ),
      findsNothing,
    );
    doctorPortal.selectDate(doctorPortal.today.add(const Duration(days: 1)));
    await tester.pumpAndSettle();
    expect(doctorPortal.available, isTrue);
    expect(find.text('Sarah Johnson'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Profile editor validates and saves across portal tabs', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/doctor-portal/profile');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), '');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter name.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Dr. Emily Smith',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Emily Smith'), findsOneWidget);
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Dr. Emily Smith'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Schedule leaves unbooked slots empty and opens details only', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/doctor-portal/schedule');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add_rounded), findsNothing);
    expect(find.text('Available slot'), findsNothing);
    final emptySlot = find.byWidgetPredicate(
      (widget) =>
          widget is PortalScheduleTile &&
          widget.time == const TimeOfDay(hour: 9, minute: 0),
    );
    expect(
      find.descendant(of: emptySlot, matching: find.byType(InkWell)),
      findsNothing,
    );
    for (final name in ['Sarah Johnson', 'James Wilson']) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.text('Patient details'), findsOneWidget);
      expect(find.text('Start consult'), findsNothing);
      expect(find.text('Continue consult'), findsNothing);
      expect(find.text('Mark completed'), findsNothing);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    }
    expect(doctorPortal.patientById('sarah')!.status, QueueStatus.waiting);
    expect(doctorPortal.patientById('james')!.status, QueueStatus.ongoing);
    await tester.pumpWidget(const SizedBox());
  });

  test('Unbooked slots stay empty while existing booking statuses update', () {
    final controller = PortalController();
    addTearDown(controller.dispose);
    expect(controller.bookingAt(const TimeOfDay(hour: 9, minute: 0)), isNull);
    const time = TimeOfDay(hour: 10, minute: 0);
    expect(controller.bookingAt(time)?.name, 'Sarah Johnson');
    controller.setStatus('sarah', QueueStatus.completed);
    expect(controller.bookingAt(time)?.status, QueueStatus.completed);
    controller.selectDate(controller.today.add(const Duration(days: 1)));
    expect(controller.bookingAt(time), isNull);
    controller.setAvailable(false);
    expect(controller.bookingAt(time), isNull);
  });
}
