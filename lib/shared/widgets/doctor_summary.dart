/// Lightweight doctor display model used by shared doctor cards and profile screens.
///
/// Static sample data for the UI. Replace with your real data source.
class DoctorSummary {
  const DoctorSummary({
    required this.name,
    required this.specialty,
    this.distance = '',
    this.experience = '',
    required this.availability,
    this.availableToday = true,
  });

  final String name;
  final String specialty;
  final String distance;
  final String experience;
  final String availability;
  final bool availableToday;
}
