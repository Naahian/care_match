import '../entities/appointment.dart';

abstract interface class AppointmentsRepository {
  Future<List<Appointment>> getAppointments({
    AppointmentRole role = AppointmentRole.patient,
  });
  Future<Appointment> updateStatus({
    required String appointmentId,
    required AppointmentStatus status,
  });
}

class AppointmentsException implements Exception {
  const AppointmentsException(
    this.message, {
    this.cause,
    this.statusCode,
    this.mayHaveSucceeded = false,
  });
  final String message;
  final Object? cause;
  final int? statusCode;
  final bool mayHaveSucceeded;
}
