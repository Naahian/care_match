import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.doctorId,
    required super.patientId,
    required super.scheduledFor,
    required super.status,
    required super.reason,
    super.notes,
    super.videoRoomId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String requiredText(String key, {bool allowEmpty = false}) {
      final value = json[key];
      if (value is! String || (!allowEmpty && value.trim().isEmpty)) {
        throw FormatException('Invalid appointment field: $key.');
      }
      return value.trim();
    }

    String? optionalText(String key) {
      if (json[key] == null) return null;
      final value = requiredText(key, allowEmpty: true);
      return value.isEmpty ? null : value;
    }

    final rawDate = requiredText('scheduled_for');
    final parts = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[Tt](\d{2}):(\d{2}):(\d{2})(?:\.\d+)?(?:[Zz]|[+-](\d{2}):(\d{2}))?$',
    ).firstMatch(rawDate);
    final date = DateTime.tryParse(rawDate);
    if (parts == null || date == null) {
      throw const FormatException('Invalid appointment date.');
    }
    final year = int.parse(parts[1]!);
    final month = int.parse(parts[2]!);
    final day = int.parse(parts[3]!);
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > DateTime.utc(year, month + 1, 0).day ||
        int.parse(parts[4]!) > 23 ||
        int.parse(parts[5]!) > 59 ||
        int.parse(parts[6]!) > 59 ||
        (parts[7] != null &&
            (int.parse(parts[7]!) > 23 || int.parse(parts[8]!) > 59))) {
      throw const FormatException('Invalid appointment date.');
    }
    final rawStatus = requiredText('status');
    final status = AppointmentStatus.values
        .where((s) => s.name == rawStatus)
        .firstOrNull;
    if (status == null) {
      throw const FormatException('Invalid appointment status.');
    }
    return AppointmentModel(
      id: requiredText('appointment_id'),
      doctorId: requiredText('doctor_id'),
      patientId: requiredText('patient_id'),
      scheduledFor: date,
      status: status,
      reason: requiredText('reason', allowEmpty: true),
      notes: optionalText('notes'),
      videoRoomId: optionalText('video_room_id'),
    );
  }
}
