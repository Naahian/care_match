import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/nursai/presentation/models/symptom_intake.dart';
import 'package:care_match/features/nursai/presentation/screens/symptom_entry_screen.dart';
import 'package:care_match/features/nursai/presentation/screens/symptom_assessment_screen.dart';
import 'package:care_match/features/doctors/presentation/screens/recommended_doctors_screen.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

const intake = SymptomIntake(
  symptoms: 'Sore throat',
  age: 28,
  duration: '1–3 days',
  location: 'Dhaka',
  breathingDifficulty: BreathingDifficulty.no,
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Symptom flow layouts fit $size with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final screen in [
        const SymptomEntryScreen(),
        const SymptomAssessmentScreen(intake: intake),
        const RecommendedDoctorsScreen(intake: intake),
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
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('Incomplete intake stays on the form with validation errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => MaterialApp(
          theme: AppTheme.light,
          home: const SymptomEntryScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.byType(SymptomEntryScreen), findsOneWidget);
    expect(find.text('Describe your symptoms.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Intake passes through preview assessment and recommended doctor navigation',
    (tester) async {
      final router = createAppRouter(
        initialLocation: '/symptoms?symptoms=Sore%20throat',
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        Sizer(builder: (_, _, _) => MyApp(router: router)),
      );
      await tester.pumpAndSettle();
      final age = find.widgetWithText(TextFormField, 'Your age in years');
      await tester.scrollUntilVisible(
        age,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(age, '28');
      final duration = find.byType(DropdownButtonFormField<String>);
      await tester.scrollUntilVisible(
        duration,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(duration);
      await tester.pumpAndSettle();
      await tester.tap(find.text('1–3 days').last);
      await tester.pumpAndSettle();
      final location = find.widgetWithText(TextFormField, 'Your city or area');
      await tester.scrollUntilVisible(
        location,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(location, 'Dhaka');
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'No'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'No'));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.byType(SymptomAssessmentScreen), findsOneWidget);
      final data = tester
          .widget<SymptomAssessmentScreen>(find.byType(SymptomAssessmentScreen))
          .intake;
      expect(data.age, 28);
      expect(data.location, 'Dhaka');
      expect(data.symptoms, 'Sore throat');
      expect(data.breathingDifficulty, BreathingDifficulty.no);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.byType(RecommendedDoctorsScreen), findsOneWidget);
      final sophia = find.text('Dr. Sophia Nguyen');
      await tester.scrollUntilVisible(
        sophia,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(sophia);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DoctorDetailScreen>(find.byType(DoctorDetailScreen))
            .profile
            .summary
            .name,
        'Dr. Sophia Nguyen',
      );
    },
  );

  testWidgets('Assessment direct link without intake redirects to the form', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/symptoms/assessment');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    expect(find.byType(SymptomEntryScreen), findsOneWidget);
  });
}
