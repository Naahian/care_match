import 'package:dio/dio.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_live_data_source.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required this.dio, required this.live});
  final Dio dio;
  final ChatLiveDataSource live;

  Future<T> _request<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object?) parse, {
    bool sending = false,
  }) async {
    try {
      return parse(ApiResponse.fromJson((await request()).data).data);
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      throw ChatException(
        switch (code) {
          401 => 'Sign in again to use chat.',
          403 || 404 => 'This conversation is unavailable.',
          409 =>
            'This message could not be confirmed. Please reload the conversation.',
          _ => 'Could not connect to chat. Please try again.',
        },
        cause: error,
        accessDenied: code == 401 || code == 403 || code == 404,
        mayHaveSucceeded: sending && (code == null || code >= 500),
      );
    } on ApiResponseException catch (error) {
      throw ChatException(
        'Could not load chat. Please try again.',
        cause: error,
        accessDenied: [401, 403, 404].contains(error.statusCode),
        mayHaveSucceeded: sending && error.statusCode >= 500,
      );
    } on FormatException catch (error) {
      throw ChatException(
        'The chat response was invalid. Please try again.',
        cause: error,
        mayHaveSucceeded: sending,
      );
    }
  }

  Map<String, Object?> _query(String? cursor, int limit) => {
    'limit': limit,
    'cursor': ?cursor,
  };
  String _id(String id) => Uri.encodeComponent(id);
  @override
  Future<ChatPage<ConsultationChat>> listChats({String? cursor}) => _request(
    () => dio.get<Object?>(
      ApiEndpoints.chats,
      queryParameters: _query(cursor, 20),
    ),
    (data) => ChatModel.page(data, ChatModel.chat),
  );
  @override
  Future<ConsultationChat> createChat(String recipientUid) => _request(
    () => dio.post<Object?>(
      ApiEndpoints.chats,
      data: {'recipient_uid': recipientUid},
    ),
    ChatModel.chat,
  );
  @override
  Future<ConsultationChat> getChat(String chatId) => _request(
    () => dio.get<Object?>(ApiEndpoints.getChat(_id(chatId))),
    (data) {
      final chat = ChatModel.chat(data);
      if (chat.id != chatId) {
        throw const FormatException('Wrong chat returned.');
      }
      return chat;
    },
  );
  @override
  Future<ChatPage<ConsultationMessage>> listMessages(
    String chatId, {
    String? cursor,
  }) => _request(
    () => dio.get<Object?>(
      ApiEndpoints.messages(_id(chatId)),
      queryParameters: _query(cursor, 50),
    ),
    (data) {
      final page = ChatModel.page(data, ChatModel.message);
      if (page.items.any((m) => m.chatId != chatId)) {
        throw const FormatException('Wrong chat messages.');
      }
      return page;
    },
  );
  @override
  Future<ConsultationMessage> sendMessage(
    String chatId, {
    required String text,
    required String clientMessageId,
  }) => _request(
    () => dio.post<Object?>(
      ApiEndpoints.messages(_id(chatId)),
      data: {'text': text, 'client_message_id': clientMessageId},
    ),
    (data) {
      final message = ChatModel.message(data);
      if (message.chatId != chatId ||
          message.id != clientMessageId ||
          message.text != text) {
        throw const FormatException('Unexpected sent message.');
      }
      return message;
    },
    sending: true,
  );

  @override
  Stream<List<ConsultationChat>> watchChats(String uid) async* {
    try {
      await for (final rows in live.watchChats(uid)) {
        final chats = rows.map(ChatModel.chat).toList();
        if (chats.any((chat) => !chat.participantUids.contains(uid))) {
          throw const ChatException(
            'This conversation is unavailable.',
            accessDenied: true,
          );
        }
        yield List.unmodifiable(chats);
      }
    } on FormatException catch (error) {
      throw ChatException(
        'Live chat data was invalid. Please retry.',
        cause: error,
      );
    }
  }

  @override
  Stream<List<ConsultationMessage>> watchMessages(String chatId) async* {
    try {
      await for (final rows in live.watchMessages(chatId)) {
        final messages = rows.map(ChatModel.message).toList();
        if (messages.any((m) => m.chatId != chatId)) {
          throw const FormatException('Wrong chat messages.');
        }
        yield List.unmodifiable(messages);
      }
    } on FormatException catch (error) {
      throw ChatException(
        'Live message data was invalid. Please retry.',
        cause: error,
      );
    }
  }
}
