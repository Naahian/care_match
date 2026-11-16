import 'dart:convert';
import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/consultation/data/repositories/video_call_repository_impl.dart';
import 'package:care_match/features/consultation/domain/repositories/video_call_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requests a token for the appointment and maps the response', () async {
    final adapter = _VideoAdapter();
    final dio = createDioClient(
      baseUrl: 'https://example.com/api/v1',
      readAccessToken: () async => 'auth-token',
      adapter: adapter,
    );
    addTearDown(dio.close);

    final token = await VideoCallRepositoryImpl(
      dio: dio,
    ).getToken('appointment-123');

    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.uri.path, '/api/v1/video/token');
    expect(adapter.request!.data, {'appointment_id': 'appointment-123'});
    expect(token.token, 'rtc-token');
    expect(token.channelName, 'appointment-123');
  });

  test('rejects a token response for a different channel', () async {
    final adapter = _VideoAdapter()..channelName = 'different-appointment';
    final dio = createDioClient(
      baseUrl: 'https://example.com/api/v1',
      readAccessToken: () async => 'auth-token',
      adapter: adapter,
    );
    addTearDown(dio.close);

    await expectLater(
      VideoCallRepositoryImpl(dio: dio).getToken('appointment-123'),
      throwsA(
        isA<VideoCallException>().having(
          (error) => error.cause,
          'cause',
          isA<FormatException>(),
        ),
      ),
    );
  });
}

class _VideoAdapter implements HttpClientAdapter {
  RequestOptions? request;
  String channelName = 'appointment-123';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'status': 200,
        'msg': 'Success',
        'data': {'token': 'rtc-token', 'channelName': channelName},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
