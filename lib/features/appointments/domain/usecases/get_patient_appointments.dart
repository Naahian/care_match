import '../../../doctors/domain/entities/doctor.dart';
import '../../../doctors/domain/repositories/doctors_repository.dart';
import '../entities/patient_appointment.dart';
import '../repositories/appointments_repository.dart';

/// Loads the patient's records and enriches them with optional doctor details.
/// An unavailable doctor directory must not hide existing appointments.
class GetPatientAppointments {
  const GetPatientAppointments({
    required this.appointmentsRepository,
    required this.doctorsRepository,
  });
  final AppointmentsRepository appointmentsRepository;
  final DoctorsRepository doctorsRepository;

  Future<PatientAppointments> call() async {
    final appointments = await appointmentsRepository.getAppointments();
    if (appointments.isEmpty) return PatientAppointments(appointments: []);
    final doctors = <String, Doctor>{};
    try {
      for (final doctor in await doctorsRepository.getDoctors()) {
        doctors[doctor.id] = doctor;
      }
    } catch (_) {
      return PatientAppointments(
        appointments: appointments
            .map((a) => PatientAppointment(appointment: a))
            .toList(),
        doctorDetailsUnavailable: true,
      );
    }
    return PatientAppointments(
      appointments: appointments
          .map(
            (a) =>
                PatientAppointment(appointment: a, doctor: doctors[a.doctorId]),
          )
          .toList(),
      doctorDetailsUnavailable: appointments.any(
        (a) => !doctors.containsKey(a.doctorId),
      ),
    );
  }
}
