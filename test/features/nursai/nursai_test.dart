import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/nursai/data/repositories/nursai_repository_impl.dart';
import 'package:care_match/features/nursai/domain/entities/symptom_intake.dart';
import 'package:care_match/features/nursai/domain/entities/triage_assessment.dart';
import 'package:care_match/features/nursai/domain/repositories/nursai_repository.dart';
import 'package:care_match/features/nursai/presentation/controllers/nursai_controller.dart';
import 'package:care_match/features/nursai/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/nursai_test_scope.dart';

const intake = SymptomIntake(
  symptoms: 'Sore throat',
  age: 28,
  duration: '1–3 days',
  location: 'Dhaka',
  breathingDifficulty: BreathingDifficulty.aLittle,
);

Map<String, Object?> payload() => {
  'triage_id': 'triage-1',
  'urgency': 'medium',
  'summary': 'Service summary',
  'created_at': '2026-10-19T10:00:00Z',
  'recommended_specialties': ['General Physician'],
  'red_flags': ['A red flag'],
};

void main() {
  late _Adapter adapter;
  late Dio dio;
  late NursaiRepositoryImpl repository;
  setUp(() {
    adapter = _Adapter();
    dio = createDioClient(
      baseUrl: 'https://example.com/api/v1',
      readAccessToken: () async => 'token',
      adapter: adapter,
    );
    repository = NursaiRepositoryImpl(dio: dio);
  });
  tearDown(() => dio.close());

  test('posts authenticated intake and maps the full assessment', () async {
    final result = await repository.assess(intake);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.uri.path, '/api/v1/triage');
    expect(adapter.request!.headers['Authorization'], 'Bearer token');
    expect(adapter.request!.data, {
      'symptoms':
          'Sore throat\nDuration: 1–3 days.\nBreathing difficulty: A little.',
      'age': 28,
      'location': 'Dhaka',
    });
    expect(result.id, 'triage-1');
    expect(result.urgency, TriageUrgency.medium);
    expect(result.summary, 'Service summary');
    expect(result.createdAt, DateTime.utc(2026, 10, 19, 10));
    expect(result.recommendedSpecialties, ['General Physician']);
    expect(result.redFlags, ['A red flag']);
    expect(() => result.redFlags.add('change'), throwsUnsupportedError);
  });

  test(
    'rejects malformed assessment fields and unsuccessful envelopes',
    () async {
      for (final invalid in <Map<String, Object?>>[
        {'triage_id': ''},
        {'urgency': 'unknown'},
        {'created_at': 'yesterday'},
        {'summary': null},
        {
          'recommended_specialties': [7],
        },
        {'red_flags': 'flag'},
      ]) {
        adapter.body = {
          'status': 201,
          'msg': 'Created',
          'data': {...payload(), ...invalid},
        };
        await expectLater(
          repository.assess(intake),
          throwsA(isA<NursaiException>()),
        );
      }
      adapter.body = {'status': 500, 'msg': 'failed', 'data': null};
      await expectLater(
        repository.assess(intake),
        throwsA(isA<NursaiException>()),
      );
    },
  );

  test('maps transport failures without exposing backend content', () async {
    adapter.status = 500;
    await expectLater(
      repository.assess(intake),
      throwsA(
        isA<NursaiException>().having(
          (e) => e.cause,
          'cause',
          isA<DioException>(),
        ),
      ),
    );
    adapter.status = 401;
    await expectLater(
      repository.assess(intake),
      throwsA(
        isA<NursaiException>().having(
          (e) => e.message,
          'message',
          contains('sign in'),
        ),
      ),
    );
  });

  test(
    'controller guards duplicate submissions and clears errors on retry',
    () async {
      final fake = _Repository();
      final container = ProviderContainer.test(
        overrides: [nursaiRepositoryProvider.overrideWithValue(fake)],
      );
      container.listen(nursaiControllerProvider, (_, _) {});
      final controller = container.read(nursaiControllerProvider.notifier);
      final first = controller.assess(intake);
      await controller.assess(intake);
      expect(fake.calls, 1);
      expect(container.read(nursaiControllerProvider).isLoading, isTrue);
      fake.result.completeError(const NursaiException('Try again'));
      await first;
      expect(
        container.read(nursaiControllerProvider).errorMessage,
        'Try again',
      );
      fake.result = Completer<TriageAssessment>();
      final retry = controller.assess(intake);
      expect(container.read(nursaiControllerProvider).errorMessage, isNull);
      fake.result.complete(testAssessment());
      await retry;
      final state = container.read(nursaiControllerProvider);
      expect(state.assessment!.id, 'triage-1');
      expect(state.isLoading, isFalse);
    },
  );

  test('a response arriving after disposal is ignored', () async {
    final fake = _Repository();
    final container = ProviderContainer(
      overrides: [nursaiRepositoryProvider.overrideWithValue(fake)],
    );
    container.listen(nursaiControllerProvider, (_, _) {});
    final pending = container
        .read(nursaiControllerProvider.notifier)
        .assess(intake);
    container.dispose();
    fake.result.complete(testAssessment());
    await expectLater(pending, completes);
  });
}

class _Repository implements NursaiRepository {
  var calls = 0;
  var result = Completer<TriageAssessment>();
  @override
  Future<TriageAssessment> assess(SymptomIntake intake) {
    calls++;
    return result.future;
  }
}

class _Adapter implements HttpClientAdapter {
  Object? body = {'status': 201, 'msg': 'Created', 'data': payload()};
  int status = 201;
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
