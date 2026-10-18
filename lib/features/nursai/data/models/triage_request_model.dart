import '../../domain/entities/symptom_intake.dart';

class TriageRequestModel {
  const TriageRequestModel(this.intake);
  final SymptomIntake intake;

  Map<String, Object?> toJson() => {
    'symptoms':
        '${intake.symptoms.trim()}\n'
        'Duration: ${intake.duration}.\n'
        'Breathing difficulty: ${switch (intake.breathingDifficulty) {
          BreathingDifficulty.no => 'No',
          BreathingDifficulty.aLittle => 'A little',
          BreathingDifficulty.yes => 'Yes',
        }}.',
    'age': intake.age,
    'location': intake.location.trim(),
  };
}
