import '../entities/symptom_intake.dart';
import '../entities/triage_assessment.dart';

abstract interface class NursaiRepository {
  Future<TriageAssessment> assess(SymptomIntake intake);
}

class NursaiException implements Exception {
  const NursaiException(this.message, {this.cause});
  final String message;
  final Object? cause;
}
