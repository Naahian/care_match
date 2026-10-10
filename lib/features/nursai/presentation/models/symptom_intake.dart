enum BreathingDifficulty { no, aLittle, yes }

/// Form data only; urgency and doctor matching require the AI service.
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
