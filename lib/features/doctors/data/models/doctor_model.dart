import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  DoctorModel({
    required super.id,
    super.name,
    super.specialties,
    super.degrees,
    super.clinics,
    super.daysAvailable,
    super.timeAvailable,
    super.verified,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      if (value == null) return null;
      if (value is! String) {
        throw const FormatException('Expected a text doctor field.');
      }
      return value.trim().isEmpty ? null : value.trim();
    }

    String requiredText(Object? value) {
      final result = text(value);
      if (result == null) {
        throw const FormatException('Required doctor field is missing.');
      }
      return result;
    }

    List<T> list<T>(String key, T Function(Object?) parse) {
      final value = json[key];
      if (value == null) return [];
      if (value is! List) throw FormatException('Expected a list for $key.');
      return value.map(parse).toList();
    }

    final verified = json['verified'];
    if (verified != null && verified is! bool) {
      throw const FormatException('Expected a boolean for verified.');
    }
    return DoctorModel(
      id: requiredText(json['uid']),
      name: text(json['display_name']),
      specialties: list('specialties', requiredText),
      degrees: list('degrees', requiredText),
      daysAvailable: list('days_available', requiredText),
      clinics: list('clinics', (item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a clinic object.');
        }
        return DoctorClinic(
          name: requiredText(item['name']),
          location: requiredText(item['location']),
        );
      }),
      timeAvailable: list('time_available', (item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected an availability object.');
        }
        return DoctorTimeRange(
          start: requiredText(item['start']),
          end: requiredText(item['end']),
        );
      }),
      verified: verified as bool? ?? false,
    );
  }
}
