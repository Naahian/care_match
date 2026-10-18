import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers.dart' show authSessionProvider;
import '../../domain/entities/appointment.dart';
import '../../domain/entities/patient_appointment.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../../providers.dart';
import 'appointments_state.dart';

final appointmentsControllerProvider =
    NotifierProvider<AppointmentsController, AppointmentsState>(
      AppointmentsController.new,
    );

class AppointmentsController extends Notifier<AppointmentsState> {
  int _revision = 0;

  @override
  AppointmentsState build() {
    ref.onDispose(() => _revision++);
    // Keep account invalidation active even when this cached controller has
    // no screen listeners (Riverpod pauses ordinary ref.listen subscriptions).
    final sessionSubscription = ref.container.listen(authSessionProvider, (
      previous,
      next,
    ) {
      if (!ref.mounted) return;
      if (next.isLoading) return;
      if (next.hasError) {
        _revision++;
        state = const AppointmentsState(
          errorMessage: 'Sign in again to access your appointments.',
        );
        return;
      }
      final user = next.asData?.value;
      if (previous?.asData?.value?.uid == user?.uid &&
          previous?.hasValue == true) {
        return;
      }
      _revision++;
      state = user == null
          ? const AppointmentsState(
              errorMessage: 'Sign in to view your appointments.',
            )
          : const AppointmentsState();
      if (user != null) unawaited(load());
    });
    ref.onDispose(sessionSubscription.close);
    return const AppointmentsState();
  }

  void selectFilter(AppointmentsFilter filter) =>
      state = state.copyWith(filter: filter);

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading ||
        state.updatingIds.isNotEmpty ||
        (state.hasLoaded && !refresh)) {
      return;
    }
    final revision = ++_revision;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(getPatientAppointmentsProvider)();
      if (!ref.mounted || revision != _revision) return;
      state = state.copyWith(
        appointments: result.appointments,
        isLoading: false,
        hasLoaded: true,
        doctorDetailsUnavailable: result.doctorDetailsUnavailable,
        updateErrors: const {},
        uncertainIds: const {},
      );
    } catch (error) {
      if (!ref.mounted || revision != _revision) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _message(
          error,
          'Could not load appointments. Please try again.',
        ),
      );
    }
  }

  Future<void> cancelAppointment(String id) async {
    if (state.isLoading ||
        state.updatingIds.contains(id) ||
        state.uncertainIds.contains(id)) {
      return;
    }
    final entry = state.appointments
        .where((entry) => entry.appointment.id == id)
        .firstOrNull;
    if (entry == null || !entry.appointment.canCancel) return;
    final revision = _revision;
    state = state.copyWith(
      updatingIds: Set.unmodifiable({...state.updatingIds, id}),
      updateErrors: Map.unmodifiable({...state.updateErrors}..remove(id)),
    );
    try {
      final updated = await ref
          .read(appointmentsRepositoryProvider)
          .updateStatus(appointmentId: id, status: AppointmentStatus.cancelled);
      if (!ref.mounted || revision != _revision) return;
      if (updated.id != id ||
          updated.patientId != entry.appointment.patientId ||
          updated.doctorId != entry.appointment.doctorId ||
          updated.status != AppointmentStatus.cancelled) {
        throw const AppointmentsException(
          'The update could not be confirmed. Refresh appointments before trying again.',
          mayHaveSucceeded: true,
        );
      }
      state = state.copyWith(
        appointments: List.unmodifiable(
          state.appointments.map(
            (item) => item.appointment.id == id
                ? PatientAppointment(appointment: updated, doctor: item.doctor)
                : item,
          ),
        ),
        updatingIds: Set.unmodifiable({...state.updatingIds}..remove(id)),
      );
    } catch (error) {
      if (!ref.mounted || revision != _revision) return;
      state = state.copyWith(
        updatingIds: Set.unmodifiable({...state.updatingIds}..remove(id)),
        updateErrors: Map.unmodifiable({
          ...state.updateErrors,
          id: _message(
            error,
            'Could not cancel this appointment. Please try again.',
          ),
        }),
        uncertainIds: error is AppointmentsException && error.mayHaveSucceeded
            ? Set.unmodifiable({...state.uncertainIds, id})
            : state.uncertainIds,
      );
    }
  }

  String _message(Object error, String fallback) =>
      error is AppointmentsException ? error.message : fallback;
}
