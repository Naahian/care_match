enum TriageUrgency { low, medium, high, emergency }

class TriageAssessment {
  TriageAssessment({
    required this.id,
    required this.urgency,
    required this.summary,
    required this.createdAt,
    required List<String> recommendedSpecialties,
    required List<String> redFlags,
  }) : recommendedSpecialties = List.unmodifiable(recommendedSpecialties),
       redFlags = List.unmodifiable(redFlags);

  final String id;
  final TriageUrgency urgency;
  final String summary;
  final DateTime createdAt;
  final List<String> recommendedSpecialties;
  final List<String> redFlags;
}
