import '../../../../core/constants/constants.dart';
import '../../domain/entities/doctor.dart';
import 'doctor_summary.dart';

class DoctorProfile {
  const DoctorProfile({
    required this.summary,
    required this.biography,
    required this.hospital,
    required this.careAreas,
    this.chatPrice = AppConstants.defaultConsultationPrice,
    this.videoPrice = AppConstants.defaultConsultationPrice,
    this.inPersonPrice = AppConstants.defaultConsultationPrice,
    this.id,
    this.daysAvailable = const [],
    this.timeAvailable = const [],
  });
  final DoctorSummary summary;
  final String biography;
  final String hospital;
  final List<String> careAreas;
  final String chatPrice;
  final String videoPrice;
  final String inPersonPrice;
  final String? id;
  final List<String> daysAvailable;
  final List<DoctorTimeRange> timeAvailable;
  String get routeId => id ?? doctorProfileId(summary.name);
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
);
