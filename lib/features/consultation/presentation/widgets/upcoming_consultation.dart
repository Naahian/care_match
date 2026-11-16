/// Lightweight upcoming-consultation display model for the video onboarding UI.
class UpcomingConsultation {
  const UpcomingConsultation({
    required this.doctorName,
    required this.specialty,
    required this.schedule,
  });

  final String doctorName;
  final String specialty;
  final String schedule;
}
