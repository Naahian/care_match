import 'dart:async';
import 'package:care_match/features/consultation/domain/entities/chat.dart';
import 'package:care_match/features/consultation/domain/repositories/chat_repository.dart';
import 'package:care_match/features/consultation/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const testChatId =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const testMessageId = '12345678-1234-4234-8234-123456789abc';
ConsultationChat testChat() => ConsultationChat(
  id: testChatId,
  participantUids: ['patient', 'doctor'],
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
ConsultationMessage testMessage({
  String id = 'message-1',
  String text = 'A real message',
  String sender = 'doctor',
  int minute = 0,
}) => ConsultationMessage(
  id: id,
  chatId: testChatId,
  senderUid: sender,
  text: text,
  createdAt: DateTime.utc(2026, 1, 1, 0, minute),
);

Widget chatTestScope(Widget child, {TestChatRepository? repository}) =>
    ProviderScope(
      overrides: [
        consultationUserProvider.overrideWithValue('patient'),
        consultationDoctorsProvider.overrideWith((ref) async => {}),
        chatRepositoryProvider.overrideWithValue(
          repository ?? TestChatRepository(),
        ),
        chatMessageIdProvider.overrideWithValue(() => testMessageId),
      ],
      child: child,
    );

class TestChatRepository implements ChatRepository {
  final liveChats = StreamController<List<ConsultationChat>>.broadcast();
  final liveMessages = StreamController<List<ConsultationMessage>>.broadcast();
  List<ConsultationChat> chats = [testChat()];
  List<ConsultationMessage> messages = [];
  String? messageCursor;
  String? chatCursor;
  int sends = 0, creates = 0, gets = 0;
  String? recipient;
  final sentIds = <String>[];
  final requestedCursors = <String?>[];
  Completer<ConsultationMessage>? pendingSend;
  Completer<ChatPage<ConsultationChat>>? pendingChats;
  Completer<ConsultationChat>? pendingCreate;
  Object? sendFailure;
  Future<ChatPage<ConsultationMessage>> Function(String?)? messageLoader;

  @override
  Future<ChatPage<ConsultationChat>> listChats({String? cursor}) async =>
      pendingChats?.future ?? ChatPage(items: chats, nextCursor: chatCursor);
  @override
  Future<ConsultationChat> createChat(String recipientUid) async {
    creates++;
    recipient = recipientUid;
    return pendingCreate?.future ?? testChat();
  }

  @override
  Future<ConsultationChat> getChat(String chatId) async {
    gets++;
    return testChat();
  }

  @override
  Future<ChatPage<ConsultationMessage>> listMessages(
    String chatId, {
    String? cursor,
  }) async {
    requestedCursors.add(cursor);
    if (messageLoader != null) return messageLoader!(cursor);
    return ChatPage(items: messages, nextCursor: messageCursor);
  }

  @override
  Future<ConsultationMessage> sendMessage(
    String chatId, {
    required String text,
    required String clientMessageId,
  }) async {
    sends++;
    sentIds.add(clientMessageId);
    if (pendingSend != null) return pendingSend!.future;
    if (sendFailure != null) throw sendFailure!;
    final sent = testMessage(
      id: clientMessageId,
      text: text,
      sender: 'patient',
    );
    messages = [sent, ...messages.where((m) => m.id != sent.id)];
    liveMessages.add(messages);
    return sent;
  }

  @override
  Stream<List<ConsultationChat>> watchChats(String uid) => liveChats.stream;
  @override
  Stream<List<ConsultationMessage>> watchMessages(String chatId) =>
      liveMessages.stream;
  Future<void> dispose() async {
    await liveChats.close();
    await liveMessages.close();
  }
}
