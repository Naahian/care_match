import 'dart:convert';
import 'dart:typed_data';
import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/records/data/records_repository_impl.dart';
import 'package:care_match/features/records/domain/patient_record.dart';
import 'package:care_match/features/records/providers.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/records/presentation/screens/my_reports_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads both authenticated endpoints and maps pagination and signed links',
    () async {
      final adapter = _Adapter();
      final dio = createDioClient(
        baseUrl: 'https://example.com/api/v1',
        readAccessToken: () async => 'token',
        adapter: adapter,
      );
      addTearDown(dio.close);
      final repository = RecordsRepositoryImpl(dio);
      for (final kind in RecordKind.values) {
        final page = await repository.list(kind, offset: 20);
        expect(
          adapter.request!.path,
          kind == RecordKind.prescriptions
              ? '/users/me/prescriptions'
              : '/users/me/medical-reports',
        );
        expect(adapter.request!.headers['Authorization'], 'Bearer token');
        expect(adapter.request!.queryParameters['offset'], 20);
        expect(page.nextOffset, 40);
        expect(page.records.single.filename, 'report.png');
        expect(page.records.single.isImage, isTrue);
      }
    },
  );

  testWidgets(
    'records show errors, retry, pagination, tabs and a closable viewer',
    (tester) async {
      final repository = _Repository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recordsRepositoryProvider.overrideWithValue(repository),
            authSessionProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(home: MyReportsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load records. Please try again.'),
        findsOneWidget,
      );
      repository.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('record-0.pdf'), findsOneWidget);
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(find.text('record-20.pdf'), findsOneWidget);
      await tester.tap(find.text('record-0.pdf'));
      await tester.pumpAndSettle();
      expect(find.text('Download'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      await tester.tap(find.text('Prescriptions'));
      await tester.pumpAndSettle();
      expect(repository.kinds, contains(RecordKind.prescriptions));
      expect(tester.takeException(), isNull);
    },
  );
}

class _Repository implements RecordsRepository {
  bool fail = true;
  final kinds = <RecordKind>[];
  @override
  Future<RecordPage> list(RecordKind kind, {int offset = 0}) async {
    kinds.add(kind);
    if (fail) throw Exception('offline');
    return RecordPage([
      PatientRecord(
        filename: 'record-$offset.pdf',
        path: '$offset',
        contentType: 'application/pdf',
        sizeBytes: 200,
        downloadUrl: 'https://example.com/file',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    ], offset == 0 ? 20 : null);
  }
}

class _Adapter implements HttpClientAdapter {
  RequestOptions? request;
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
        'data': {
          options.path.endsWith('prescriptions')
              ? 'prescriptions'
              : 'reports': [
            {
              'filename': 'report.png',
              'path': 'patient/report.png',
              'content_type': 'image/png',
              'size_bytes': 1234,
              'download_url': 'https://storage.example.com/signed',
              'expires_at': '2030-01-01T00:00:00Z',
              'created_at': null,
            },
          ],
          'next_offset': 40,
        },
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
