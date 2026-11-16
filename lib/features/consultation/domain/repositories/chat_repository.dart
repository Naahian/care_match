import '../entities/chat.dart';

abstract interface class ChatRepository {
  Future<ChatPage<ConsultationChat>> listChats({String? cursor});
  Future<ConsultationChat> createChat(String recipientUid);
  Future<ConsultationChat> getChat(String chatId);
  Future<ChatPage<ConsultationMessage>> listMessages(
    String chatId, {
    String? cursor,
  });
  Future<ConsultationMessage> sendMessage(
    String chatId, {
    required String text,
    required String clientMessageId,
  });
  Stream<List<ConsultationChat>> watchChats(String uid);
  Stream<List<ConsultationMessage>> watchMessages(String chatId);
}

class ChatException implements Exception {
  const ChatException(
    this.message, {
    this.cause,
    this.accessDenied = false,
    this.mayHaveSucceeded = false,
  });
  final String message;
  final Object? cause;
  final bool accessDenied;
  final bool mayHaveSucceeded;
}
