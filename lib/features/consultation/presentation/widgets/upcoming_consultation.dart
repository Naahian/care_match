/// Lightweight upcoming-consultation display model for the video onboarding
/// UI.
///
/// Static sample data for the UI. Replace with your real data source.
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

const UpcomingConsultation sampleConsultation = UpcomingConsultation(
  doctorName: 'Dr. Imtiaz Hossain',
  specialty: 'Dermatologist',
  schedule: 'Today, 10:30 AM',
);
