import 'package:care_match/features/appointments/domain/entities/appointment.dart';
import 'package:care_match/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget appointmentsTestScope(Widget child) => ProviderScope(
  overrides: [
    appointmentsRepositoryProvider.overrideWithValue(
      TestAppointmentsRepository(),
    ),
    doctorsRepositoryProvider.overrideWithValue(
      TestAppointmentDoctorsRepository(),
    ),
    authSessionProvider.overrideWith((ref) => const Stream.empty()),
  ],
  child: child,
);

Appointment testAppointment({
  String id = 'requested',
  String doctorId = 'emily',
  AppointmentStatus status = AppointmentStatus.requested,
  DateTime? scheduledFor,
}) => Appointment(
  id: id,
  doctorId: doctorId,
  patientId: 'patient',
  scheduledFor: scheduledFor ?? DateTime.utc(2030, 10, 17, 12),
  status: status,
  reason: 'Follow-up visit',
  notes: 'Bring reports',
);

class TestAppointmentsRepository implements AppointmentsRepository {
  final List<Appointment> records = [
    testAppointment(),
    testAppointment(
      id: 'confirmed',
      doctorId: 'james',
      status: AppointmentStatus.confirmed,
    ),
    testAppointment(id: 'another-request', doctorId: 'sophia'),
    testAppointment(id: 'completed', status: AppointmentStatus.completed),
    testAppointment(
      id: 'cancelled',
      doctorId: 'james',
      status: AppointmentStatus.cancelled,
    ),
  ];

  @override
  Future<List<Appointment>> getAppointments() async =>
      List.unmodifiable(records);

  @override
  Future<Appointment> updateStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) async {
    final index = records.indexWhere((record) => record.id == appointmentId);
    final old = records[index];
    return records[index] = Appointment(
      id: old.id,
      doctorId: old.doctorId,
      patientId: old.patientId,
      scheduledFor: old.scheduledFor,
      status: status,
      reason: old.reason,
      notes: old.notes,
      videoRoomId: old.videoRoomId,
    );
  }
}

class TestAppointmentDoctorsRepository implements DoctorsRepository {
  @override
  Future<List<Doctor>> getDoctors() async => [
    Doctor(
      id: 'emily',
      name: 'Dr. Emily Carter',
      specialties: ['Internal Medicine'],
    ),
    Doctor(
      id: 'james',
      name: 'Dr. James Patel',
      specialties: ['Family Medicine'],
    ),
    Doctor(
      id: 'sophia',
      name: 'Dr. Sophia Nguyen',
      specialties: ['General Physician'],
    ),
  ];
}
