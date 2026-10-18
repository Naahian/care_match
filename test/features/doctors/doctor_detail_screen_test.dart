import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

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
