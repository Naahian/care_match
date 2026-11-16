import '../../appointments/domain/entities/appointment.dart';
import '../../profile/domain/entities/user_profile.dart';

class DoctorOverview {
  DoctorOverview({
    required this.profile,
    required List<Appointment> appointments,
    required this.now,
  }) : appointments = List.unmodifiable(appointments);
  final UserProfile profile;
  final List<Appointment> appointments;
  final DateTime now;

  int get upcomingCount => appointments
      .where((a) => a.isActive && !a.scheduledFor.isBefore(now))
      .length;

  List<Appointment> get today {
    final local = now.toLocal();
    final result = appointments.where((a) {
      final date = a.scheduledFor.toLocal();
      return a.status != AppointmentStatus.cancelled &&
          date.year == local.year &&
          date.month == local.month &&
          date.day == local.day;
    }).toList()..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return List.unmodifiable(result);
  }

  int get inPersonTodayCount =>
      today.where((a) => a.type == AppointmentType.inPerson).length;
}
