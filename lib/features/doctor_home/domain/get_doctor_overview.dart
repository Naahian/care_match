import '../../appointments/domain/entities/appointment.dart';
import '../../appointments/domain/repositories/appointments_repository.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import 'doctor_overview.dart';

/// Combines account earnings/identity with the doctor's own appointments.
class GetDoctorOverview {
  const GetDoctorOverview({
    required this.profiles,
    required this.appointments,
    required this.now,
  });
  final ProfileRepository profiles;
  final AppointmentsRepository appointments;
  final DateTime Function() now;

  Future<DoctorOverview> call() async {
    final profile = await profiles.getProfile();
    if (profile.role != 'doctor') {
      throw const AppointmentsException(
        'This dashboard is available to doctors only.',
      );
    }
    final records = await appointments.getAppointments(
      role: AppointmentRole.doctor,
    );
    return DoctorOverview(profile: profile, appointments: records, now: now());
  }
}
