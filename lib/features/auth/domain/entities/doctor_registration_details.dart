class DoctorRegistrationDetails {
  DoctorRegistrationDetails({
    required this.phone,
    required List<DoctorClinic> clinics,
    required List<String> specialties,
    required List<String> degrees,
    required List<DoctorTimeRange> timeAvailable,
    required List<String> daysAvailable,
  }) : clinics = List.unmodifiable(clinics),
       specialties = List.unmodifiable(specialties),
       degrees = List.unmodifiable(degrees),
       timeAvailable = List.unmodifiable(timeAvailable),
       daysAvailable = List.unmodifiable(daysAvailable);

  final String phone;
  final List<DoctorClinic> clinics;
  final List<String> specialties;
  final List<String> degrees;
  final List<DoctorTimeRange> timeAvailable;
  final List<String> daysAvailable;
}

class DoctorClinic {
  const DoctorClinic({required this.name, required this.location});
  final String name;
  final String location;
}

class DoctorTimeRange {
  const DoctorTimeRange({required this.start, required this.end});

  /// API time strings in HH:mm:ss format.
  final String start;
  final String end;
}
