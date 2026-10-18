import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';
import 'package:care_match/features/appointments/presentation/screens/appointment_date_time_screen.dart';
import 'package:care_match/features/doctors/data/models/doctor_model.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/entities/doctor_availability.dart';
import 'package:care_match/features/doctors/presentation/ui_models/doctor_presentation.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

DoctorModel responseDoctor() => DoctorModel.fromJson({
  'uid': '4b0Z73B7mzgXsQy4qtKdayob3v42',
  'display_name': 'Tamzid Shafi',
  'specialties': ['Medicine'],
  'degrees': ['MBBS'],
  'clinics': [
    {'name': 'Labaid', 'location': 'Mirpur-10, Dhaka'},
  ],
  'days_available': ['Monday', 'Tuesday'],
  'time_available': [
    {'start': '05:39:00', 'end': '10:39:00'},
  ],
  'verified': true,
});

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test(
    'the supplied response reaches booking with the exact weekdays and hours',
    () {
      final profile = responseDoctor().profile;
      expect(profile.daysAvailable, ['Monday', 'Tuesday']);
      expect(profile.timeAvailable.single.start, '05:39:00');
      expect(profile.timeAvailable.single.end, '10:39:00');
      final schedule = DoctorAvailability(
        daysAvailable: profile.daysAvailable,
        timeAvailable: profile.timeAvailable,
      );
      final now = DateTime(2026, 10, 18, 12);
      for (final day in [19, 20]) {
        final slots = schedule.slotsForDate(DateTime(2026, 10, day), now: now);
        expect(slots, hasLength(10));
        expect(slots.first, DateTime(2026, 10, day, 5, 39));
        expect(slots.last, DateTime(2026, 10, day, 10, 9));
        expect(slots.contains(DateTime(2026, 10, day, 10, 39)), isFalse);
      }
      expect(schedule.slotsForDate(DateTime(2026, 10, 18), now: now), isEmpty);
      expect(schedule.slotsForDate(DateTime(2026, 10, 21), now: now), isEmpty);
    },
  );

  test(
    'past slots and slots too short to fit a whole consultation are excluded',
    () {
      final doctor = responseDoctor();
      final schedule = DoctorAvailability(
        daysAvailable: doctor.daysAvailable,
        timeAvailable: doctor.timeAvailable,
      );
      final slots = schedule.slotsForDate(
        DateTime(2026, 10, 19),
        now: DateTime(2026, 10, 19, 6),
      );
      expect(slots.first, DateTime(2026, 10, 19, 6, 9));
      expect(slots, hasLength(9));
      expect(
        schedule.slotsForDate(
          DateTime(2026, 10, 19),
          now: DateTime(2026, 10, 19, 10, 9),
        ),
        isEmpty,
      );
    },
  );

  test(
    'multiple ranges preserve breaks and overlapping slots are deduplicated and sorted',
    () {
      final schedule = DoctorAvailability(
        daysAvailable: [' monday '],
        timeAvailable: [
          const DoctorTimeRange(start: '13:15', end: '14:00'),
          const DoctorTimeRange(start: '09:00', end: '10:00'),
          const DoctorTimeRange(start: '09:30', end: '10:30'),
        ],
      );
      expect(
        schedule.slotsForDate(
          DateTime(2026, 10, 19),
          now: DateTime(2026, 10, 18),
        ),
        [
          DateTime(2026, 10, 19, 9),
          DateTime(2026, 10, 19, 9, 30),
          DateTime(2026, 10, 19, 10),
          DateTime(2026, 10, 19, 13, 15),
        ],
      );
    },
  );

  test(
    'missing, invalid and reversed availability never falls back to fake slots',
    () {
      for (final range in [
        const DoctorTimeRange(start: '24:00:00', end: '25:00:00'),
        const DoctorTimeRange(start: '10:00', end: '09:00'),
        const DoctorTimeRange(start: '10:00', end: '10:00'),
        const DoctorTimeRange(start: 'invalid', end: '10:00'),
      ]) {
        final schedule = DoctorAvailability(
          daysAvailable: ['Monday'],
          timeAvailable: [range],
        );
        expect(schedule.hasSchedule, isFalse);
        expect(
          schedule.slotsForDate(
            DateTime(2026, 10, 19),
            now: DateTime(2026, 10, 18),
          ),
          isEmpty,
        );
      }
      expect(
        DoctorAvailability(daysAvailable: [], timeAvailable: []).hasSchedule,
        isFalse,
      );
    },
  );

  test(
    'fractional UTC times round up safely to the draft minute precision',
    () {
      final schedule = DoctorAvailability(
        daysAvailable: ['Monday'],
        timeAvailable: [
          const DoctorTimeRange(start: '17:52:22.832Z', end: '18:52:22.832Z'),
        ],
      );
      final first = DateTime.utc(2026, 10, 19, 17, 53).toLocal();
      expect(schedule.slotsForDate(first, now: DateTime.utc(2026, 10, 18)), [
        first,
      ]);
    },
  );

  test(
    'explicit offsets are converted before grouping slots by local calendar date',
    () {
      final schedule = DoctorAvailability(
        daysAvailable: ['Monday'],
        timeAvailable: [
          const DoctorTimeRange(start: '05:39:00+06:00', end: '06:39:00+06:00'),
        ],
      );
      final first = DateTime.utc(2026, 10, 18, 23, 39).toLocal();
      final slots = schedule.slotsForDate(
        first,
        now: DateTime.utc(2026, 10, 18),
      );
      expect(slots, contains(first));
      expect(slots.every((slot) => DateUtils.isSameDay(slot, first)), isTrue);
    },
  );

  Future<void> showSchedule(
    WidgetTester tester,
    AppointmentDraft draft,
    DateTime Function() now,
  ) => tester.pumpWidget(
    Sizer(
      builder: (_, _, _) => MaterialApp(
        theme: AppTheme.light,
        home: AppointmentDateTimeScreen(draft: draft, now: now),
      ),
    ),
  );

  testWidgets(
    'calendar selects the first allowed day, disables others, and clears the time on date changes',
    (tester) async {
      final draft = AppointmentDraft(doctor: responseDoctor().profile)
        ..date = DateTime(2026, 10, 21)
        ..time = const TimeOfDay(hour: 9, minute: 0);
      await showSchedule(tester, draft, () => DateTime(2026, 10, 18, 12));
      await tester.pumpAndSettle();
      expect(draft.date, DateTime(2026, 10, 19));
      expect(draft.time, isNull);
      final calendar = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      expect(calendar.selectableDayPredicate!(DateTime(2026, 10, 19)), isTrue);
      expect(calendar.selectableDayPredicate!(DateTime(2026, 10, 20)), isTrue);
      expect(calendar.selectableDayPredicate!(DateTime(2026, 10, 21)), isFalse);
      final label = MaterialLocalizations.of(
        tester.element(find.byType(CalendarDatePicker)),
      ).formatTimeOfDay(const TimeOfDay(hour: 5, minute: 39));
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(label));
      await tester.pump();
      expect(draft.time, const TimeOfDay(hour: 5, minute: 39));
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Continue to payment'),
            )
            .onPressed,
        isNotNull,
      );
      calendar.onDateChanged(DateTime(2026, 10, 20));
      await tester.pump();
      expect(draft.time, isNull);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Continue to payment'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets('a missing schedule clears the draft and disables payment', (
    tester,
  ) async {
    final draft = AppointmentDraft(doctor: sampleDoctorProfile)
      ..date = DateTime(2026, 10, 19)
      ..time = const TimeOfDay(hour: 9, minute: 0);
    await showSchedule(tester, draft, () => DateTime(2026, 10, 18, 12));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsNothing);
    expect(
      find.text('This doctor has not provided a valid appointment schedule.'),
      findsOneWidget,
    );
    expect(draft.scheduledAt, isNull);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Continue to payment'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'an expired selection is revalidated before navigating to payment',
    (tester) async {
      var now = DateTime(2026, 10, 19, 5);
      final draft = AppointmentDraft(doctor: responseDoctor().profile)
        ..date = DateTime(2026, 10, 19)
        ..time = const TimeOfDay(hour: 5, minute: 39);
      await showSchedule(tester, draft, () => now);
      await tester.pumpAndSettle();
      expect(draft.time, isNotNull);
      now = DateTime(2026, 10, 19, 5, 39);
      await tester.tap(find.text('Continue to payment'));
      await tester.pump();
      expect(draft.time, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
