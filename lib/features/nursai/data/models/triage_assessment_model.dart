import '../../domain/entities/triage_assessment.dart';

class TriageAssessmentModel {
  static TriageAssessment fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected a triage object.');
    }
    String text(String key) {
      final field = value[key];
      if (field is! String || field.trim().isEmpty) {
        throw FormatException('Invalid triage $key.');
      }
      return field.trim();
    }

    List<String> texts(String key) {
      final field = value[key];
      if (field is! List) throw FormatException('Invalid triage $key.');
      return field.map((item) {
        if (item is! String || item.trim().isEmpty) {
          throw FormatException('Invalid triage $key item.');
        }
        return item.trim();
      }).toList();
    }

    final urgencyText = text('urgency');
    final urgency = TriageUrgency.values.where((u) => u.name == urgencyText);
    final createdAt = DateTime.tryParse(text('created_at'));
    if (urgency.isEmpty || createdAt == null) {
      throw const FormatException('Invalid triage urgency or date.');
    }
    return TriageAssessment(
      id: text('triage_id'),
      urgency: urgency.single,
      summary: text('summary'),
      createdAt: createdAt,
      recommendedSpecialties: texts('recommended_specialties'),
      redFlags: texts('red_flags'),
    );
  }
}
