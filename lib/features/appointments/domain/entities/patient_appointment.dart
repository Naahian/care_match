import '../../../doctors/domain/entities/doctor.dart';
import 'appointment.dart';

class PatientAppointment {
  const PatientAppointment({required this.appointment, this.doctor});
  final Appointment appointment;
  final Doctor? doctor;
}

class PatientAppointments {
  PatientAppointments({
    required List<PatientAppointment> appointments,
    this.doctorDetailsUnavailable = false,
  }) : appointments = List.unmodifiable(appointments);

  final List<PatientAppointment> appointments;
  final bool doctorDetailsUnavailable;
}
