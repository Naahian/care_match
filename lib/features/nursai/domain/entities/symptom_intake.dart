enum BreathingDifficulty { no, aLittle, yes }

/// Patient-provided details for a triage assessment.
class SymptomIntake {
  const SymptomIntake({
    required this.symptoms,
    required this.age,
    required this.duration,
    required this.location,
    required this.breathingDifficulty,
  });
  final String symptoms;
  final int age;
  final String duration;
  final String location;
  final BreathingDifficulty breathingDifficulty;
}
