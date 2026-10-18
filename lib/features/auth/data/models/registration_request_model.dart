import '../../domain/entities/doctor_registration_details.dart';

class RegistrationRequestModel {
  const RegistrationRequestModel({
    required this.email,
    required this.password,
    required this.displayName,
    this.doctorDetails,
  });
  final String email;
  final String password;
  final String displayName;
  final DoctorRegistrationDetails? doctorDetails;

  Map<String, dynamic> toJson() {
    final doctor = doctorDetails;
    return {
      'email': email.trim(),
      'password': password,
      'display_name': displayName.trim(),
      if (doctor != null) ...{
        'phone': doctor.phone.trim(),
        'clinics': [
          for (final clinic in doctor.clinics)
            {'name': clinic.name.trim(), 'location': clinic.location.trim()},
        ],
        'specialties': doctor.specialties.map((value) => value.trim()).toList(),
        'degrees': doctor.degrees.map((value) => value.trim()).toList(),
        'time_available': [
          for (final time in doctor.timeAvailable)
            {'start': time.start, 'end': time.end},
        ],
        'days_available': doctor.daysAvailable,
      },
    };
  }
}
