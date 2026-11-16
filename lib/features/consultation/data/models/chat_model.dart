import '../../domain/entities/chat.dart';

abstract final class ChatModel {
  static Map<String, dynamic> object(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected a chat object.');
    }
    return value;
  }

  static String text(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Expected a chat text field.');
    }
    return value;
  }

  static DateTime date(Object? value) {
    if (value is DateTime) return value;
    final result = value is String ? DateTime.tryParse(value) : null;
    if (result == null) throw const FormatException('Invalid chat timestamp.');
    return result;
  }

  static ConsultationMessage message(Object? value) {
    final json = object(value);
    return ConsultationMessage(
      id: text(json['message_id']),
      chatId: text(json['chat_id']),
      senderUid: text(json['sender_uid']),
      text: text(json['text']),
      createdAt: date(json['created_at']),
    );
  }

  static ConsultationChat chat(Object? value) {
    final json = object(value);
    final members = json['participant_uids'];
    if (members is! List || members.length != 2) {
      throw const FormatException('Invalid chat participants.');
    }
    final participants = members.map(text).toList();
    if (participants.toSet().length != 2) {
      throw const FormatException('Duplicate chat participants.');
    }
    final id = text(json['chat_id']);
    final last = json['last_message'] == null
        ? null
        : message(json['last_message']);
    if (last != null &&
        (last.chatId != id || !participants.contains(last.senderUid))) {
      throw const FormatException('Invalid chat preview.');
    }
    return ConsultationChat(
      id: id,
      participantUids: participants,
      createdAt: date(json['created_at']),
      updatedAt: date(json['updated_at']),
      lastMessage: last,
    );
  }

  static ChatPage<T> page<T>(Object? value, T Function(Object?) parse) {
    final json = object(value);
    final items = json['items'];
    final cursor = json['next_cursor'];
    if (items is! List ||
        (cursor != null && (cursor is! String || cursor.isEmpty))) {
      throw const FormatException('Invalid chat page.');
    }
    return ChatPage(
      items: items.map(parse).toList(),
      nextCursor: cursor as String?,
    );
  }
}
