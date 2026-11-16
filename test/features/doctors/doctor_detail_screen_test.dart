import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';
import 'package:care_match/features/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final type in [ConsultationType.chat, ConsultationType.video]) {
    testWidgets(
      '${type.label} opens booking with the selected consultation type',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  const DoctorDetailScreen(profile: sampleDoctorProfile),
            ),
            GoRoute(
              path: '/appointments/:doctorId/book',
              name: AppRoutes.bookAppointment,
              builder: (_, state) => BookAppointmentScreen(
                draft: state.extra! as AppointmentDraft,
              ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          Sizer(
            builder: (_, _, _) =>
                MaterialApp.router(theme: AppTheme.light, routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();
        final tile = find.text(type.label);
        await tester.scrollUntilVisible(
          tile,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.drag(find.byType(ListView).first, const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        final booking = tester.widget<BookAppointmentScreen>(
          find.byType(BookAppointmentScreen),
        );
        expect(booking.draft.doctor, sampleDoctorProfile);
        expect(booking.draft.type, type);
        expect(
          GoRouterState.of(
            tester.element(find.byType(BookAppointmentScreen)),
          ).pathParameters['doctorId'],
          sampleDoctorProfile.routeId,
        );
      },
    );
  }

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Profile scrolls while booking stays visible at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        Sizer(
          builder: (context, _, _) => MaterialApp(
            theme: size.width > 600 ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const DoctorDetailScreen(profile: sampleDoctorProfile),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final booking = find.text('Book an appointment');
      expect(booking.hitTestable(), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Video Consult'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('৳100'), findsWidgets);
      expect(booking.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
