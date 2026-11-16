import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers.dart' show authSessionProvider;
import '../../../appointments/domain/repositories/appointments_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/doctor_overview.dart';
import '../../providers.dart';

class DoctorHomeState {
  const DoctorHomeState({this.overview, this.loading = false, this.error});
  final DoctorOverview? overview;
  final bool loading;
  final String? error;
}

final doctorHomeControllerProvider =
    NotifierProvider.autoDispose<DoctorHomeController, DoctorHomeState>(
      DoctorHomeController.new,
    );

class DoctorHomeController extends Notifier<DoctorHomeState> {
  int _revision = 0;
  @override
  DoctorHomeState build() {
    ref.watch(
      authSessionProvider.select((session) => session.asData?.value?.uid),
    );
    _revision++;
    return const DoctorHomeState();
  }

  Future<void> load() async {
    if (state.loading) return;
    final revision = ++_revision;
    state = DoctorHomeState(overview: state.overview, loading: true);
    try {
      final data = await ref.read(getDoctorOverviewProvider)();
      if (!ref.mounted || revision != _revision) return;
      state = DoctorHomeState(overview: data);
    } catch (error) {
      if (!ref.mounted || revision != _revision) return;
      state = DoctorHomeState(
        overview: state.overview,
        error: error is AppointmentsException
            ? error.message
            : error is ProfileException
            ? error.message
            : 'Could not load your practice. Please try again.',
      );
    }
  }
}
