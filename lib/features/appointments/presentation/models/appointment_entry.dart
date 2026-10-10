import 'package:care_match/shared/widgets/doctor_summary.dart';
import 'appointment_draft.dart';

enum AppointmentStatus { upcoming, completed, cancelled }

class AppointmentEntry {
  const AppointmentEntry({
    required this.id,
    required this.doctor,
    required this.dateTime,
    required this.type,
    required this.status,
    this.location = 'CareMatch Medical Center',
  });
  final String id;
  final DoctorSummary doctor;
  final DateTime dateTime;
  final ConsultationType type;
  final AppointmentStatus status;
  final String location;
}

List<AppointmentEntry> sampleAppointmentEntries() {
  final now = DateTime.now();
  const emily = DoctorSummary(
    name: 'Dr. Emily Carter',
    specialty: 'Internal Medicine',
    availability: 'Confirmed',
  );
  const james = DoctorSummary(
    name: 'Dr. James Patel',
    specialty: 'Family Medicine',
    availability: 'Confirmed',
  );
  const sophia = DoctorSummary(
    name: 'Dr. Sophia Nguyen',
    specialty: 'General Physician',
    availability: 'Confirmed',
  );
  return [
    AppointmentEntry(
      id: 'emily-upcoming',
      doctor: emily,
      dateTime: now.add(const Duration(hours: 1)),
      type: ConsultationType.video,
      status: AppointmentStatus.upcoming,
    ),
    AppointmentEntry(
      id: 'james-upcoming',
      doctor: james,
      dateTime: now.add(const Duration(days: 6)),
      type: ConsultationType.chat,
      status: AppointmentStatus.upcoming,
    ),
    AppointmentEntry(
      id: 'sophia-upcoming',
      doctor: sophia,
      dateTime: now.add(const Duration(days: 13)),
      type: ConsultationType.inPerson,
      status: AppointmentStatus.upcoming,
    ),
    AppointmentEntry(
      id: 'emily-completed',
      doctor: emily,
      dateTime: now.subtract(const Duration(days: 7)),
      type: ConsultationType.video,
      status: AppointmentStatus.completed,
    ),
    AppointmentEntry(
      id: 'james-cancelled',
      doctor: james,
      dateTime: now.subtract(const Duration(days: 3)),
      type: ConsultationType.chat,
      status: AppointmentStatus.cancelled,
    ),
  ];
}
