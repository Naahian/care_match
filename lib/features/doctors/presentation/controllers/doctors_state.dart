import '../../domain/entities/doctor.dart';

class DoctorsState {
  const DoctorsState({
    this.doctors = const [],
    this.query = '',
    this.specialty = '',
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  final List<Doctor> doctors;
  final String query;
  final String specialty;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  List<Doctor> get visibleDoctors {
    final terms = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty);
    return List.unmodifiable(
      doctors.where((doctor) {
        final text = [
          doctor.name ?? '',
          ...doctor.specialties,
          ...doctor.degrees,
          for (final clinic in doctor.clinics)
            '${clinic.name} ${clinic.location}',
        ].join(' ').toLowerCase();
        return terms.every(text.contains) &&
            (specialty.isEmpty ||
                doctor.specialties.any(
                  (s) => s.toLowerCase() == specialty.toLowerCase(),
                ));
      }),
    );
  }

  DoctorsState copyWith({
    List<Doctor>? doctors,
    String? query,
    String? specialty,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) => DoctorsState(
    doctors: doctors ?? this.doctors,
    query: query ?? this.query,
    specialty: specialty ?? this.specialty,
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
