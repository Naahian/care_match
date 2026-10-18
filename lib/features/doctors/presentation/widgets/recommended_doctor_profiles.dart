import 'doctor_profile.dart';
import 'doctor_summary.dart';

const sampleRecommendedProfiles = [
  sampleDoctorProfile,
  DoctorProfile(
    summary: DoctorSummary(
      name: 'Dr. James Patel',
      specialty: 'Family Medicine',
      availability: 'Available today',
    ),
    biography: 'Family medicine and primary care consultations.',
    hospital: 'CareMatch Medical Center',
    careAreas: ['Family Medicine'],
  ),
  DoctorProfile(
    summary: DoctorSummary(
      name: 'Dr. Sophia Nguyen',
      specialty: 'General Physician',
      availability: 'Available tomorrow',
      availableToday: false,
    ),
    biography: 'General health and primary care consultations.',
    hospital: 'CareMatch Medical Center',
    careAreas: ['Primary Care'],
  ),
];
