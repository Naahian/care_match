import 'package:care_match/features/doctors/providers.dart';
import 'doctors_test_scope.dart';
import 'package:care_match/features/nursai/domain/entities/symptom_intake.dart';
import 'package:care_match/features/nursai/domain/entities/triage_assessment.dart';
import 'package:care_match/features/nursai/domain/repositories/nursai_repository.dart';
import 'package:care_match/features/nursai/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

TriageAssessment testAssessment() => TriageAssessment(
  id: 'triage-1',
  urgency: TriageUrgency.medium,
  summary: 'Assessment from the service.',
  createdAt: DateTime.utc(2026, 10, 19),
  recommendedSpecialties: ['General Physician'],
  redFlags: ['Watch for worsening symptoms.'],
);

Widget nursaiTestScope(Widget child) => ProviderScope(
  overrides: [
    doctorsRepositoryProvider.overrideWithValue(TestDoctorsRepository()),
    nursaiRepositoryProvider.overrideWithValue(TestNursaiRepository()),
  ],
  child: child,
);

class TestNursaiRepository implements NursaiRepository {
  @override
  Future<TriageAssessment> assess(SymptomIntake intake) async =>
      testAssessment();
}
