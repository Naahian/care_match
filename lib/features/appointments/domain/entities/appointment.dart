enum AppointmentStatus { requested, confirmed, completed, cancelled }

class Appointment {
  const Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.scheduledFor,
    required this.status,
    required this.reason,
    this.notes,
    this.videoRoomId,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final DateTime scheduledFor;
  final AppointmentStatus status;
  final String reason;
  final String? notes;
  final String? videoRoomId;

  bool get canCancel =>
      status == AppointmentStatus.requested ||
      status == AppointmentStatus.confirmed;
}
