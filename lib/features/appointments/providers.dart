import '../consultation/providers.dart';
import '../auth/providers.dart' show authSessionProvider;
import '../profile/account_profile_provider.dart';
import 'domain/entities/appointment.dart';
import 'domain/usecases/create_paid_booking_chat.dart';
import 'dart:math';
import 'data/repositories/payments_repository_impl.dart';
import 'domain/repositories/payments_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../doctors/providers.dart';
import 'data/repositories/appointments_repository_impl.dart';
import 'domain/repositories/appointments_repository.dart';
import 'domain/usecases/get_patient_appointments.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>(
  (ref) => AppointmentsRepositoryImpl(dio: ref.watch(dioProvider)),
);

final appointmentRoleProvider = FutureProvider<AppointmentRole>((ref) async {
  ref.watch(
    authSessionProvider.select((session) => session.asData?.value?.uid),
  );
  final profile = await ref.watch(accountProfileProvider.future);
  return switch (profile.role) {
    'doctor' => AppointmentRole.doctor,
    'patient' => AppointmentRole.patient,
    _ => throw const AppointmentsException(
      'Your account role could not be determined. Please sign in again.',
    ),
  };
});

final getPatientAppointmentsProvider = Provider<GetPatientAppointments>(
  (ref) => GetPatientAppointments(
    appointmentsRepository: ref.watch(appointmentsRepositoryProvider),
    doctorsRepository: ref.watch(doctorsRepositoryProvider),
  ),
);

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepositoryImpl(dio: ref.watch(dioProvider)),
);
final paymentKeyGeneratorProvider = Provider<String Function()>(
  (ref) => () {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  },
);

final createPaidBookingChatProvider = Provider<CreatePaidBookingChat>(
  (ref) => CreatePaidBookingChat(repository: ref.watch(chatRepositoryProvider)),
);
