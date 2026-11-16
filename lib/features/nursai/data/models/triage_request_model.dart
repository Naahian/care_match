import '../../domain/entities/symptom_intake.dart';

class TriageRequestModel {
  const TriageRequestModel(this.intake);
  final SymptomIntake intake;

  Map<String, Object?> toJson() => {
    'symptoms': intake.symptoms.trim(),
    'age': intake.age,
    'duration_days': intake.durationDays,
    'medical_history': intake.medicalHistory.trim(),
    'current_medications': intake.currentMedications
        .map((medication) => medication.trim())
        .where((medication) => medication.isNotEmpty)
        .toList(),
    'location': intake.location.trim(),
  };
}
