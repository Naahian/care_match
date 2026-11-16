/// Display values for an API-backed conversation.
class Conversation {
  const Conversation({
    required this.peerName,
    this.photoUrl,
    required this.lastMessage,
    required this.time,
    this.specialty = '',
  });
  final String peerName;
  final String? photoUrl;
  final String specialty;
  final String lastMessage;
  final String time;
}
