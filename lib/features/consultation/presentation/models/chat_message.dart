/// Local display data for the demo conversation screen.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    this.isFromPatient = false,
  });

  final String text;
  final String time;
  final bool isFromPatient;
}
