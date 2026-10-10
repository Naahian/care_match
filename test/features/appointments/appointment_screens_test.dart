import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';
import 'package:care_match/features/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:care_match/features/appointments/presentation/screens/appointment_date_time_screen.dart';
import 'package:care_match/features/appointments/presentation/screens/appointment_payment_screen.dart';
import 'package:care_match/features/appointments/presentation/screens/appointment_confirmation_screen.dart';
import 'package:care_match/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:care_match/features/appointments/presentation/widgets/patient_appointment_card.dart';
import 'package:care_match/features/appointments/presentation/widgets/consultation_type_card.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

AppointmentDraft draft() => AppointmentDraft(doctor: sampleDoctorProfile)
  ..date = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1))
  ..time = const TimeOfDay(hour: 10, minute: 0);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Appointment screens fit $size with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final booking = draft();
      for (final screen in [
        BookAppointmentScreen(draft: booking),
        AppointmentDateTimeScreen(draft: booking),
        AppointmentPaymentScreen(draft: booking),
        AppointmentConfirmationScreen(draft: booking),
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
        expect(find.textContaining('Credit'), findsNothing);
        expect(find.textContaining('Add to calendar'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('Booking flow preserves in-person details and wallet selection', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/doctors/dr-emily-carter');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book an appointment'));
    await tester.pumpAndSettle();
    expect(find.byType(BookAppointmentScreen), findsOneWidget);
    final inPerson = find.widgetWithText(ConsultationTypeCard, 'In person');
    await tester.ensureVisible(inPerson);
    await tester.pumpAndSettle();
    await tester.tap(find.text('In person'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Follow-up visit');
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    final dateScreen = tester.widget<AppointmentDateTimeScreen>(
      find.byType(AppointmentDateTimeScreen),
    );
    expect(dateScreen.draft.type, ConsultationType.inPerson);
    expect(dateScreen.draft.reason, 'Follow-up visit');
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Continue to payment'),
          )
          .onPressed,
      isNull,
    );
    final slotLabel = MaterialLocalizations.of(
      tester.element(find.byType(AppointmentDateTimeScreen)),
    ).formatTimeOfDay(const TimeOfDay(hour: 10, minute: 0));
    await tester.scrollUntilVisible(
      find.text(slotLabel),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(slotLabel));
    await tester.pump();
    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();
    final payment = tester.widget<AppointmentPaymentScreen>(
      find.byType(AppointmentPaymentScreen),
    );
    expect(payment.draft.total, 103);
    await tester.scrollUntilVisible(
      find.text('Apple Pay'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple Pay'));
    await tester.pump();
    expect(payment.draft.paymentMethod, AppointmentPaymentMethod.applePay);
    await tester.tap(find.text('Pay & confirm'));
    await tester.pumpAndSettle();
    final confirmation = tester.widget<AppointmentConfirmationScreen>(
      find.byType(AppointmentConfirmationScreen),
    );
    expect(confirmation.draft.type, ConsultationType.inPerson);
    expect(confirmation.draft.time, const TimeOfDay(hour: 10, minute: 0));
    expect(confirmation.draft.doctor.summary.name, 'Dr. Emily Carter');
    expect(router.canPop(), isFalse);
    await tester.tap(find.text('View appointment'));
    await tester.pumpAndSettle();
    expect(find.byType(MyAppointmentsScreen), findsOneWidget);
    final bookedAppointment = tester
        .widget<PatientAppointmentCard>(
          find.byType(PatientAppointmentCard).first,
        )
        .appointment;
    expect(bookedAppointment.type, ConsultationType.inPerson);
    expect(bookedAppointment.dateTime, confirmation.draft.scheduledAt);
  });

  testWidgets(
    'Later-step deep links restart booking without an available draft',
    (tester) async {
      final router = createAppRouter(
        initialLocation: '/appointments/dr-emily-carter/payment',
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        Sizer(builder: (_, _, _) => MyApp(router: router)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BookAppointmentScreen), findsOneWidget);
      expect(find.byType(AppointmentPaymentScreen), findsNothing);
    },
  );

  testWidgets('Changing date clears the selected slot', (tester) async {
    final booking = draft();
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => MaterialApp(
          theme: AppTheme.light,
          home: AppointmentDateTimeScreen(draft: booking),
        ),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(booking.date!.add(const Duration(days: 1)));
    await tester.pump();
    expect(booking.time, isNull);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Continue to payment'),
          )
          .onPressed,
      isNull,
    );
  });
}
