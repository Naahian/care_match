class Doctor {
  Doctor({
    required this.id,
    this.name,
    List<String> specialties = const [],
    List<String> degrees = const [],
    List<DoctorClinic> clinics = const [],
    List<String> daysAvailable = const [],
    List<DoctorTimeRange> timeAvailable = const [],
    this.verified = false,
  }) : specialties = List.unmodifiable(specialties),
       degrees = List.unmodifiable(degrees),
       clinics = List.unmodifiable(clinics),
       daysAvailable = List.unmodifiable(daysAvailable),
       timeAvailable = List.unmodifiable(timeAvailable);

  final String id;
  final String? name;
  final List<String> specialties;
  final List<String> degrees;
  final List<DoctorClinic> clinics;
  final List<String> daysAvailable;
  final List<DoctorTimeRange> timeAvailable;
  final bool verified;
}

class DoctorClinic {
  const DoctorClinic({required this.name, required this.location});
  final String name;
  final String location;
}

class DoctorTimeRange {
  const DoctorTimeRange({required this.start, required this.end});
  final String start;
  final String end;
}
