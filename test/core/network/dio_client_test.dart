import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/core/network/interceptors/auth_interceptor.dart';
import 'package:care_match/core/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _RecordingAdapter adapter;
  late Dio dio;
  String? token;
  var tokenReads = 0;

  setUp(() {
    adapter = _RecordingAdapter();
    token = 'first-token';
    tokenReads = 0;
    dio = createDioClient(
      baseUrl: 'https://api.example.com/v1',
      readAccessToken: () async {
        tokenReads++;
        return token;
      },
      adapter: adapter,
    );
  });

  tearDown(() => dio.close(force: true));

  test(
    'reads the current token for every request and removes stale headers',
    () async {
      await dio.get<void>('/patients');
      token = 'second-token';
      await dio.get<void>(
        '/patients',
        options: Options(headers: {'authorization': 'Bearer stale'}),
      );
      expect(tokenReads, 2);
      expect(
        adapter.requests.first.headers['Authorization'],
        'Bearer first-token',
      );
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer second-token',
      );
      expect(
        adapter.requests.last.headers.keys.where(
          (key) => key.toLowerCase() == 'authorization',
        ),
        hasLength(1),
      );
      expect(adapter.requests.last.followRedirects, isFalse);
    },
  );

  for (final missingToken in [null, '', '   ']) {
    test('missing token ($missingToken) prevents network access', () async {
      token = missingToken;
      await expectLater(
        dio.post<void>('/patients', data: {'name': 'Patient'}),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<StateError>(),
          ),
        ),
      );
      expect(adapter.requests, isEmpty);
    });
  }

  test('public endpoints skip token lookup and remove authorization', () async {
    dio.options.headers['Authorization'] = 'Bearer stale';
    await dio.get<void>(
      '/public',
      options: Options(extra: {AuthInterceptor.requiresAuth: false}),
    );
    expect(tokenReads, 0);
    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test(
    'token lookup failure rejects the request before network access',
    () async {
      final failure = StateError('Token unavailable');
      final client = createDioClient(
        baseUrl: 'https://api.example.com',
        readAccessToken: () async => throw failure,
        adapter: adapter,
      );
      addTearDown(client.close);
      await expectLater(
        client.get<void>('/patients'),
        throwsA(
          isA<DioException>().having((e) => e.error, 'error', same(failure)),
        ),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'absolute URLs outside the API origin never receive credentials',
    () async {
      await expectLater(
        dio.get<void>('https://other.example.com/patients'),
        throwsA(isA<DioException>()),
      );
      expect(tokenReads, 0);
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'CRUD requests preserve methods, payloads, query parameters, and responses',
    () async {
      final response = await dio.get<Map<String, dynamic>>(
        '/patients',
        queryParameters: {'page': 2},
      );
      await dio.post<void>('/patients', data: {'name': 'New'});
      await dio.put<void>('/patients/123', data: {'name': 'Updated'});
      await dio.patch<void>('/patients/123', data: {'name': 'Patched'});
      await dio.delete<void>('/patients/123');
      expect(response.data, {'ok': true});
      expect(adapter.requests.map((r) => r.method), [
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);
      expect(
        adapter.requests.first.uri.toString(),
        'https://api.example.com/v1/patients?page=2',
      );
      expect(adapter.requests[1].data, {'name': 'New'});
      expect(adapter.requests[2].data, {'name': 'Updated'});
      expect(adapter.requests[3].data, {'name': 'Patched'});
      expect(
        adapter.requests.every(
          (r) => r.headers['Authorization'] == 'Bearer first-token',
        ),
        isTrue,
      );
    },
  );

  test('401 responses are preserved without retrying a mutation', () async {
    adapter.statusCode = 401;
    await expectLater(
      dio.post<void>('/patients', data: {'name': 'New'}),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(adapter.requests, hasLength(1));
  });

  test('base URL must be an absolute HTTP API URL', () {
    for (final url in [
      '',
      '/api',
      'ftp://example.com',
      'https://user:pass@example.com',
      'https://example.com?token=secret',
    ]) {
      expect(
        () => createDioClient(baseUrl: url, readAccessToken: () async => token),
        throwsArgumentError,
      );
    }
  });

  test(
    'provider uses overridable configuration and closes its adapter',
    () async {
      final container = ProviderContainer.test(
        overrides: [
          apiBaseUrlProvider.overrideWithValue('https://api.example.com'),
          accessTokenReaderProvider.overrideWithValue(
            () async => 'provider-token',
          ),
        ],
      );
      final client = container.read(dioProvider);
      client.httpClientAdapter = adapter;
      await client.get<void>('/patients');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer provider-token',
      );
      container.dispose();
      expect(adapter.closed, isTrue);
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  var statusCode = 200;
  var closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"ok":true}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) => closed = true;
}
