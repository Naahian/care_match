/// Display values for a stored consultation message.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    this.isMine = false,
  });

  final String text;
  final String time;
  final bool isMine;
}
