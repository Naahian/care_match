import 'doctor_summary.dart';

class DoctorProfile {
  const DoctorProfile({
    required this.summary,
    required this.biography,
    required this.hospital,
    required this.careAreas,
    required this.chatPrice,
    required this.videoPrice,
    this.inPersonPrice = 'Not provided',
  });
  final DoctorSummary summary;
  final String biography;
  final String hospital;
  final List<String> careAreas;
  final String chatPrice;
  final String videoPrice;
  final String inPersonPrice;
}

const sampleDoctorProfile = DoctorProfile(
  summary: DoctorSummary(
    name: 'Dr. Emily Carter',
    specialty: 'Internal Medicine',
    distance: '',
    experience: '',
    availability: 'Available today',
    availableToday: true,
  ),
  biography:
      'Dr. Emily Carter is a board-certified internal medicine physician with a passion for preventive care and helping patients achieve better long-term health outcomes.',
  hospital: 'CareMatch Medical Center',
  careAreas: ['Primary Care', 'Preventive Care', 'Chronic Conditions'],
  chatPrice: r'$49',
  videoPrice: r'$79',
  // Sample price for the booking UI; replace with the doctor's actual fee.
  inPersonPrice: r'$99',
);

/// Stable sample identifiers also work when a detail URL is opened directly.
String doctorProfileId(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

DoctorProfile profileForSummary(DoctorSummary summary) => DoctorProfile(
  summary: summary,
  biography:
      'Consult ${summary.name} for ${summary.specialty.toLowerCase()} care.',
  hospital: 'Not provided',
  careAreas: [summary.specialty],
  chatPrice: 'Not provided',
  videoPrice: 'Not provided',
);
