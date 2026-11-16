import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../appointments/providers.dart';
import '../profile/providers.dart';
import 'domain/get_doctor_overview.dart';

final doctorHomeClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
final getDoctorOverviewProvider = Provider<GetDoctorOverview>(
  (ref) => GetDoctorOverview(
    profiles: ref.watch(profileRepositoryProvider),
    appointments: ref.watch(appointmentsRepositoryProvider),
    now: ref.watch(doctorHomeClockProvider),
  ),
);
