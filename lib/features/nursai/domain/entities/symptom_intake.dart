/// Patient-provided details for a triage assessment.
class SymptomIntake {
  SymptomIntake({
    required this.symptoms,
    required this.age,
    required this.durationDays,
    required this.location,
    this.medicalHistory = '',
    List<String> currentMedications = const [],
  }) : currentMedications = List.unmodifiable(currentMedications);

  final String symptoms;
  final int age;
  final int durationDays;
  final String medicalHistory;
  final List<String> currentMedications;
  final String location;
}
