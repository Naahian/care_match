import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../doctors/providers.dart';
import 'data/repositories/appointments_repository_impl.dart';
import 'domain/repositories/appointments_repository.dart';
import 'domain/usecases/get_patient_appointments.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>(
  (ref) => AppointmentsRepositoryImpl(dio: ref.watch(dioProvider)),
);

final getPatientAppointmentsProvider = Provider<GetPatientAppointments>(
  (ref) => GetPatientAppointments(
    appointmentsRepository: ref.watch(appointmentsRepositoryProvider),
    doctorsRepository: ref.watch(doctorsRepositoryProvider),
  ),
);
