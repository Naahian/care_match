import 'package:care_match/shared/widgets/doctor_summary.dart';

export 'package:care_match/shared/widgets/doctor_summary.dart'
    show DoctorSummary;

const List<DoctorSummary> sampleDoctors = [
  DoctorSummary(
    name: 'Dr. Farzana Rahman',
    specialty: 'General Physician',
    distance: '3.2 km',
    experience: '8 yrs exp',
    availability: 'Available today',
    availableToday: true,
  ),
  DoctorSummary(
    name: 'Dr. Imtiaz Hossain',
    specialty: 'Dermatologist',
    distance: '2.4 km',
    experience: '10 yrs exp',
    availability: 'Available today',
    availableToday: true,
  ),
  DoctorSummary(
    name: 'Dr. Nusrat Jahan',
    specialty: 'Pediatrician',
    distance: '3.3 km',
    experience: '12 yrs exp',
    availability: 'Available tomorrow',
    availableToday: false,
  ),
];
