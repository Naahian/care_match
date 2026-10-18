import '../../domain/entities/doctor.dart';
import '../widgets/doctor_profile.dart';
import '../widgets/doctor_summary.dart';

extension DoctorPresentation on Doctor {
  DoctorSummary get summary => DoctorSummary(
    name: name ?? 'Name not provided',
    specialty: specialties.isEmpty
        ? 'Specialty not provided'
        : specialties.join(', '),
    availability: daysAvailable.isEmpty
        ? 'Availability not provided'
        : daysAvailable.join(', '),
    availableToday: false,
  );

  DoctorProfile get profile => DoctorProfile(
    id: id,
    daysAvailable: daysAvailable,
    timeAvailable: timeAvailable,
    summary: summary,
    biography: [
      if (degrees.isNotEmpty) 'Qualifications: ${degrees.join(', ')}',
      if (clinics.isNotEmpty)
        clinics.map((c) => '${c.name}, ${c.location}').join('\n'),
      if (timeAvailable.isNotEmpty)
        'Consultation hours: ${timeAvailable.map((t) => '${t.start} – ${t.end}').join(', ')}',
      if (degrees.isEmpty && clinics.isEmpty && timeAvailable.isEmpty)
        'Profile details not provided.',
    ].join('\n\n'),
    hospital: clinics.isEmpty
        ? 'Not provided'
        : clinics.map((c) => c.name).join(', '),
    careAreas: specialties,
  );
}
