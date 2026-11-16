class ConsultationMessage {
  const ConsultationMessage({
    required this.id,
    required this.chatId,
    required this.senderUid,
    required this.text,
    required this.createdAt,
  });
  final String id;
  final String chatId;
  final String senderUid;
  final String text;
  final DateTime createdAt;
}

class ConsultationChat {
  ConsultationChat({
    required this.id,
    required List<String> participantUids,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  }) : participantUids = List.unmodifiable(participantUids);
  final String id;
  final List<String> participantUids;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ConsultationMessage? lastMessage;

  String otherParticipant(String uid) =>
      participantUids.firstWhere((id) => id != uid);
}

class ChatPage<T> {
  ChatPage({required List<T> items, this.nextCursor})
    : items = List.unmodifiable(items);
  final List<T> items;
  final String? nextCursor;
}
