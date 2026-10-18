import '../../domain/entities/triage_assessment.dart';

class NursaiState {
  const NursaiState({
    this.isLoading = false,
    this.assessment,
    this.errorMessage,
  });
  final bool isLoading;
  final TriageAssessment? assessment;
  final String? errorMessage;
}
