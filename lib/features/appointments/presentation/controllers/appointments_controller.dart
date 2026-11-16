import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers.dart' show authSessionProvider;
import '../../domain/entities/appointment.dart';
import '../../domain/entities/patient_appointment.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../../providers.dart';
import '../../../notifications/domain/app_notification.dart';
import '../../../notifications/providers.dart';
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
      if (ref.read(appointmentRoleProvider).hasError) {
        ref.invalidate(appointmentRoleProvider);
      }
      final role = await ref.read(appointmentRoleProvider.future);
      if (!ref.mounted || revision != _revision) return;
      final result = await ref.read(getPatientAppointmentsProvider)(role: role);
      if (!ref.mounted || revision != _revision) return;
      state = state.copyWith(
        appointments: result.appointments,
        isLoading: false,
        hasLoaded: true,
        role: role,
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

  Future<void> cancelAppointment(String id) =>
      _updateStatus(id, AppointmentStatus.cancelled);

  Future<void> completeAppointment(String id) =>
      _updateStatus(id, AppointmentStatus.completed);

  Future<void> _updateStatus(String id, AppointmentStatus status) async {
    if (state.role != AppointmentRole.doctor ||
        state.isLoading ||
        state.updatingIds.contains(id) ||
        state.uncertainIds.contains(id)) {
      return;
    }
    final entry = state.appointments
        .where((entry) => entry.appointment.id == id)
        .firstOrNull;
    if (entry == null || !entry.appointment.isActive) return;
    final revision = _revision;
    state = state.copyWith(
      updatingIds: Set.unmodifiable({...state.updatingIds, id}),
      updateErrors: Map.unmodifiable({...state.updateErrors}..remove(id)),
    );
    try {
      final updated = await ref
          .read(appointmentsRepositoryProvider)
          .updateStatus(appointmentId: id, status: status);
      if (!ref.mounted || revision != _revision) return;
      if (updated.id != id ||
          updated.patientId != entry.appointment.patientId ||
          updated.doctorId != entry.appointment.doctorId ||
          updated.status != status) {
        throw const AppointmentsException(
          'The update could not be confirmed. Refresh appointments before trying again.',
          mayHaveSucceeded: true,
        );
      }
      state = state.copyWith(
        appointments: List.unmodifiable(
          state.appointments.map(
            (item) => item.appointment.id == id
                ? PatientAppointment(
                    appointment: Appointment(
                      id: updated.id,
                      doctorId: updated.doctorId,
                      patientId: updated.patientId,
                      scheduledFor: updated.scheduledFor,
                      status: updated.status,
                      reason: updated.reason,
                      notes: updated.notes,
                      videoRoomId: updated.videoRoomId,
                      patient: updated.patient ?? item.appointment.patient,
                      patientName:
                          updated.patientName ?? item.appointment.patientName,
                      type: updated.type,
                    ),
                    doctor: item.doctor,
                  )
                : item,
          ),
        ),
        updatingIds: Set.unmodifiable({...state.updatingIds}..remove(id)),
      );
      if (status == AppointmentStatus.cancelled) {
        unawaited(
          ref
              .read(notificationsControllerProvider.notifier)
              .add(
                type: NotificationType.appointmentCancelled,
                title: 'Appointment cancelled',
                message: 'Your appointment has been cancelled.',
                appointmentId: id,
              ),
        );
      }
    } catch (error) {
      if (!ref.mounted || revision != _revision) return;
      state = state.copyWith(
        updatingIds: Set.unmodifiable({...state.updatingIds}..remove(id)),
        updateErrors: Map.unmodifiable({
          ...state.updateErrors,
          id: _message(
            error,
            'Could not update this appointment. Please try again.',
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
