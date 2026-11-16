enum AppointmentStatus { requested, confirmed, completed, cancelled }

enum AppointmentRole { patient, doctor }

enum AppointmentType {
  video('video', 'Video consultation'),
  chat('chat', 'Chat consultation'),
  inPerson('in_person', 'In person');

  const AppointmentType(this.value, this.label);
  final String value;
  final String label;
}

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
    this.patient,
    this.patientName,
    this.type = AppointmentType.video,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final DateTime scheduledFor;
  final AppointmentStatus status;
  final String reason;
  final String? notes;
  final String? videoRoomId;
  final AppointmentPatient? patient;
  final String? patientName;
  final AppointmentType type;

  bool get isActive =>
      status == AppointmentStatus.requested ||
      status == AppointmentStatus.confirmed;
}

class AppointmentPatient {
  const AppointmentPatient({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
  });

  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
}
