/// Lightweight conversation display model for the chat list UI.
///
/// Static sample data for the UI. Replace with your real data source.
class Conversation {
  const Conversation({
    required this.doctorName,
    required this.specialty,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
  });

  final String doctorName;
  final String specialty;
  final String lastMessage;
  final String time;
  final bool isOnline;
}

const List<Conversation> sampleConversations = [
  Conversation(
    doctorName: 'Dr. Farzana Rahman',
    specialty: 'General Physician',
    lastMessage:
        'Your prescription is ready. Let me know if you have any '
        'questions.',
    time: '10:24 AM',
    isOnline: true,
  ),
  Conversation(
    doctorName: 'Dr. Anika Sarker',
    specialty: 'Dermatologist',
    lastMessage:
        'It looks like a fungal infection. I\u2019ll send you the '
        'prescription shortly.',
    time: 'Yesterday',
  ),
  Conversation(
    doctorName: 'Dr. Rafiq Hasan',
    specialty: 'Psychiatrist',
    lastMessage:
        'Thanks for sharing. Let\u2019s continue the current plan '
        'and follow up in 2 weeks.',
    time: 'Yesterday',
  ),
];
