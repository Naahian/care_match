import '../../domain/entities/featured_doctor.dart';

class FeaturedDoctorModel extends FeaturedDoctor {
  const FeaturedDoctorModel({
    required super.id,
    super.name,
    super.specialties,
    super.availability,
    super.degrees,
    super.clinics,
    super.daysAvailable,
    super.timeAvailable,
    super.verified,
  });

  factory FeaturedDoctorModel.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) =>
        value is String && value.trim().isNotEmpty ? value.trim() : null;

    final id = text(json['uid']);
    if (id == null) {
      throw const FormatException('Doctor identifier is missing.');
    }
    List<T> list<T>(String key, T Function(Object?) parse) {
      final value = json[key];
      if (value == null) return const [];
      if (value is! List) {
        throw FormatException('Expected a list for $key.');
      }
      return List.unmodifiable(value.map(parse));
    }

    String requiredText(Object? value) {
      final result = text(value);
      if (result == null) {
        throw const FormatException('Expected a non-empty doctor field.');
      }
      return result;
    }

    final verified = json['verified'];
    if (verified != null && verified is! bool) {
      throw const FormatException('Expected a boolean for verified.');
    }
    return FeaturedDoctorModel(
      id: id,
      name: text(json['display_name']),
      specialties: list('specialties', requiredText),
      degrees: list('degrees', requiredText),
      daysAvailable: list('days_available', requiredText),
      clinics: list('clinics', (value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Expected a clinic object.');
        }
        return FeaturedDoctorClinic(
          name: requiredText(value['name']),
          location: requiredText(value['location']),
        );
      }),
      timeAvailable: list('time_available', (value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Expected a time range object.');
        }
        return FeaturedDoctorTimeRange(
          start: requiredText(value['start']),
          end: requiredText(value['end']),
        );
      }),
      verified: verified as bool? ?? false,
    );
  }
}
