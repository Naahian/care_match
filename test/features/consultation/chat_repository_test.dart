import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/consultation/data/datasources/chat_live_data_source.dart';
import 'package:care_match/features/consultation/data/repositories/chat_repository_impl.dart';
import 'package:care_match/features/consultation/domain/repositories/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/chat_test_scope.dart';

Map<String, Object?> messageJson() => {
  'message_id': testMessageId,
  'chat_id': testChatId,
  'sender_uid': 'patient',
  'text': 'Hello',
  'created_at': '2026-01-01T00:00:00Z',
};
Map<String, Object?> chatJson() => {
  'chat_id': testChatId,
  'participant_uids': ['patient', 'doctor'],
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'last_message': messageJson(),
};

void main() {
  late _Adapter adapter;
  late Dio dio;
  late _Live live;
  late ChatRepositoryImpl repository;
  setUp(() {
    adapter = _Adapter();
    live = _Live();
    dio = createDioClient(
      baseUrl: 'https://example.com/api/v1',
      readAccessToken: () async => 'token',
      adapter: adapter,
    );
    repository = ChatRepositoryImpl(dio: dio, live: live);
  });
  tearDown(() => dio.close());
  test(
    'creates, lists and gets chats using the backend envelope and cursor',
    () async {
      adapter.data = chatJson();
      final created = await repository.createChat('doctor');
      expect(adapter.request!.method, 'POST');
      expect(adapter.request!.data, {'recipient_uid': 'doctor'});
      expect(created.participantUids, ['patient', 'doctor']);
      expect(created.lastMessage!.text, 'Hello');
      expect((await repository.getChat(testChatId)).id, testChatId);
      expect(adapter.request!.uri.path, '/api/v1/chats/$testChatId');
      adapter.data = {
        'items': [chatJson()],
        'next_cursor': 'next',
      };
      final page = await repository.listChats(cursor: 'old');
      expect(page.nextCursor, 'next');
      expect(adapter.request!.queryParameters, {'cursor': 'old', 'limit': 20});
      expect(adapter.request!.headers['Authorization'], 'Bearer token');
    },
  );
  test(
    'lists history and posts only text and the stable client message ID',
    () async {
      adapter.data = {
        'items': [messageJson()],
        'next_cursor': null,
      };
      final page = await repository.listMessages(
        testChatId,
        cursor: 'old-message',
      );
      expect(page.items.single.createdAt, DateTime.utc(2026));
      expect(adapter.request!.queryParameters, {
        'cursor': 'old-message',
        'limit': 50,
      });
      adapter.data = messageJson();
      final sent = await repository.sendMessage(
        testChatId,
        text: 'Hello',
        clientMessageId: testMessageId,
      );
      expect(adapter.request!.uri.path, '/api/v1/chats/$testChatId/messages');
      expect(adapter.request!.data, {
        'text': 'Hello',
        'client_message_id': testMessageId,
      });
      expect(sent.id, testMessageId);
    },
  );
  test(
    'rejects malformed or mismatched data and preserves safe failure causes',
    () async {
      for (final data in [
        {
          ...chatJson(),
          'participant_uids': ['patient', 'patient'],
        },
        {...chatJson(), 'created_at': 'invalid'},
        {...chatJson(), 'chat_id': 'wrong'},
      ]) {
        adapter.data = data;
        await expectLater(
          repository.getChat(testChatId),
          throwsA(isA<ChatException>()),
        );
      }
      adapter.data = {
        'items': [
          {...messageJson(), 'chat_id': 'other'},
        ],
        'next_cursor': null,
      };
      await expectLater(
        repository.listMessages(testChatId),
        throwsA(isA<ChatException>()),
      );
      adapter.status = 403;
      await expectLater(
        repository.getChat(testChatId),
        throwsA(
          isA<ChatException>()
              .having((e) => e.accessDenied, 'accessDenied', true)
              .having((e) => e.cause, 'cause', isA<DioException>()),
        ),
      );
    },
  );
  test('maps live dates and rejects foreign chat snapshots', () async {
    live.rows = [
      {
        ...chatJson(),
        'created_at': DateTime.utc(2026),
        'updated_at': DateTime.utc(2026),
      },
    ];
    expect(
      (await repository.watchChats('patient').first).single.id,
      testChatId,
    );
    await expectLater(
      repository.watchChats('outsider').first,
      throwsA(isA<ChatException>()),
    );
    live.rows = [
      {...messageJson(), 'created_at': DateTime.utc(2026)},
    ];
    expect(
      (await repository.watchMessages(testChatId).first).single.text,
      'Hello',
    );
    live.failure = const ChatException('Permission denied', accessDenied: true);
    await expectLater(
      repository.watchMessages(testChatId).first,
      throwsA(
        isA<ChatException>().having((e) => e.accessDenied, 'denied', true),
      ),
    );
  });
  test(
    'uncertain send failures retain retry safety, definite rejections do not',
    () async {
      adapter.status = 503;
      await expectLater(
        repository.sendMessage(
          testChatId,
          text: 'Hello',
          clientMessageId: testMessageId,
        ),
        throwsA(
          isA<ChatException>().having(
            (e) => e.mayHaveSucceeded,
            'uncertain',
            true,
          ),
        ),
      );
      adapter.status = 422;
      await expectLater(
        repository.sendMessage(
          testChatId,
          text: 'Hello',
          clientMessageId: testMessageId,
        ),
        throwsA(
          isA<ChatException>().having(
            (e) => e.mayHaveSucceeded,
            'uncertain',
            false,
          ),
        ),
      );
      adapter.status = 200;
      adapter.data = {...messageJson(), 'message_id': 'unexpected-id'};
      await expectLater(
        repository.sendMessage(
          testChatId,
          text: 'Hello',
          clientMessageId: testMessageId,
        ),
        throwsA(
          isA<ChatException>().having(
            (e) => e.mayHaveSucceeded,
            'uncertain',
            true,
          ),
        ),
      );
    },
  );
}

class _Live implements ChatLiveDataSource {
  List<Map<String, dynamic>> rows = [];
  Object? failure;
  Stream<List<Map<String, dynamic>>> _stream() async* {
    if (failure != null) throw failure!;
    yield rows;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchChats(String uid) => _stream();
  @override
  Stream<List<Map<String, dynamic>>> watchMessages(String chatId) => _stream();
}

class _Adapter implements HttpClientAdapter {
  Object? data;
  int status = 200;
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'status': status, 'msg': 'Result', 'data': data}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
