import '../../domain/entities/appointment.dart';
import '../../domain/entities/patient_appointment.dart';

enum AppointmentsFilter { upcoming, completed, cancelled }

class AppointmentsState {
  const AppointmentsState({
    this.appointments = const [],
    this.filter = AppointmentsFilter.upcoming,
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
    this.doctorDetailsUnavailable = false,
    this.updatingIds = const {},
    this.updateErrors = const {},
    this.uncertainIds = const {},
  });

  final List<PatientAppointment> appointments;
  final AppointmentsFilter filter;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;
  final bool doctorDetailsUnavailable;
  final Set<String> updatingIds;
  final Map<String, String> updateErrors;
  final Set<String> uncertainIds;

  List<PatientAppointment> get visibleAppointments {
    final items = appointments
        .where(
          (entry) => switch (filter) {
            AppointmentsFilter.upcoming => entry.appointment.canCancel,
            AppointmentsFilter.completed =>
              entry.appointment.status == AppointmentStatus.completed,
            AppointmentsFilter.cancelled =>
              entry.appointment.status == AppointmentStatus.cancelled,
          },
        )
        .toList();
    items.sort(
      (a, b) => filter == AppointmentsFilter.upcoming
          ? a.appointment.scheduledFor.compareTo(b.appointment.scheduledFor)
          : b.appointment.scheduledFor.compareTo(a.appointment.scheduledFor),
    );
    return List.unmodifiable(items);
  }

  AppointmentsState copyWith({
    List<PatientAppointment>? appointments,
    AppointmentsFilter? filter,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
    bool? doctorDetailsUnavailable,
    Set<String>? updatingIds,
    Map<String, String>? updateErrors,
    Set<String>? uncertainIds,
  }) => AppointmentsState(
    appointments: appointments ?? this.appointments,
    filter: filter ?? this.filter,
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    doctorDetailsUnavailable:
        doctorDetailsUnavailable ?? this.doctorDetailsUnavailable,
    updatingIds: updatingIds ?? this.updatingIds,
    updateErrors: updateErrors ?? this.updateErrors,
    uncertainIds: uncertainIds ?? this.uncertainIds,
  );
}
