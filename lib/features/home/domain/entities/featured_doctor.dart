class FeaturedDoctor {
  const FeaturedDoctor({
    required this.id,
    this.name,
    this.specialties = const [],
    this.availability,
    this.degrees = const [],
    this.clinics = const [],
    this.daysAvailable = const [],
    this.timeAvailable = const [],
    this.verified = false,
  });

  final String id;
  final String? name;
  final List<String> specialties;
  final String? availability;
  final List<String> degrees;
  final List<FeaturedDoctorClinic> clinics;
  final List<String> daysAvailable;
  final List<FeaturedDoctorTimeRange> timeAvailable;
  final bool verified;
}

class FeaturedDoctorClinic {
  const FeaturedDoctorClinic({required this.name, required this.location});

  final String name;
  final String location;
}

class FeaturedDoctorTimeRange {
  const FeaturedDoctorTimeRange({required this.start, required this.end});

  /// API time strings, including fractional seconds and timezone suffixes.
  final String start;
  final String end;
}
