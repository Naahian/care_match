import 'package:care_match/shared/widgets/doctor_summary.dart';

export 'package:care_match/shared/widgets/doctor_summary.dart'
    show DoctorSummary;

const List<DoctorSummary> sampleDoctors = [
  DoctorSummary(
    name: 'Dr. Emily Carter',
    specialty: 'Internal Medicine',
    availability: 'Available today',
  ),
  DoctorSummary(
    name: 'Dr. James Patel',
    specialty: 'Family Medicine',
    availability: 'Available today',
  ),
];
