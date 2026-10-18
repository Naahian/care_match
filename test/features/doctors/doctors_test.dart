import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:care_match/features/doctors/data/repositories/doctors_repository_impl.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:care_match/features/doctors/presentation/controllers/doctors_controller.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'package:care_match/features/doctors/presentation/ui_models/doctor_presentation.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'package:care_match/router.dart';
import 'package:care_match/shared/widgets/doctor_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

final _doctors = [
  Doctor(
    id: 'backend-id',
    name: 'Dr. API Doctor',
    specialties: ['Cardiology'],
    degrees: ['MD'],
    daysAvailable: ['Monday'],
    clinics: [const DoctorClinic(name: 'Care Clinic', location: 'Dhaka')],
    timeAvailable: [const DoctorTimeRange(start: '09:00:00', end: '12:00:00')],
  ),
  Doctor(id: 'second-id', name: 'Dr. Other', specialties: ['Dermatology']),
];

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('repository', () {
    late _Adapter adapter;
    late Dio dio;
    late DoctorsRepositoryImpl repository;
    setUp(() {
      adapter = _Adapter();
      dio = createDioClient(
        baseUrl: 'https://example.com/api/v1',
        readAccessToken: () async => 'token',
        adapter: adapter,
      );
      repository = DoctorsRepositoryImpl(dio: dio);
    });
    tearDown(() => dio.close());

    test(
      'loads the API directory and applies the default BDT consultation fee',
      () async {
        adapter.data = [
          {
            'uid': ' firebase-id ',
            'display_name': ' API Doctor ',
            'specialties': [' Cardiology '],
            'degrees': ['MD'],
            'clinics': [
              {'name': 'Care Clinic', 'location': 'Dhaka'},
            ],
            'days_available': ['Monday'],
            'time_available': [
              {'start': '09:00:00', 'end': '12:00:00'},
            ],
            'verified': true,
          },
        ];
        final result = await repository.getDoctors();
        expect(adapter.request!.uri.path, '/api/v1/users/doctors');
        expect(adapter.request!.headers['Authorization'], 'Bearer token');
        final doctor = result.single;
        expect(doctor.id, 'firebase-id');
        expect(doctor.verified, isTrue);
        expect(doctor.profile.routeId, 'firebase-id');
        expect(doctor.profile.biography, contains('MD'));
        expect(doctor.profile.biography, contains('Care Clinic, Dhaka'));
        expect(doctor.profile.biography, contains('09:00:00'));
        expect(doctor.profile.chatPrice, '৳100');
        expect(doctor.profile.videoPrice, '৳100');
        expect(doctor.profile.inPersonPrice, '৳100');
        expect(doctor.profile.daysAvailable, ['Monday']);
        expect(doctor.profile.timeAvailable.single.start, '09:00:00');
        expect(doctor.summary.availability, 'Monday');
        expect(doctor.summary.availableToday, isFalse);
        expect(() => doctor.specialties.add('Other'), throwsUnsupportedError);
      },
    );

    test('empty and minimally populated responses remain honest', () async {
      expect(await repository.getDoctors(), isEmpty);
      adapter.data = [
        {'uid': 'id'},
      ];
      final doctor = (await repository.getDoctors()).single;
      expect(doctor.summary.name, 'Name not provided');
      expect(doctor.summary.availability, 'Availability not provided');
      expect(doctor.profile.hospital, 'Not provided');
    });

    test('rejects malformed records including nested fields', () async {
      for (final value in <Object?>[
        {},
        [null],
        [
          {'uid': ' '},
        ],
        [
          {'uid': 3},
        ],
        [
          {'uid': 'id', 'display_name': 4},
        ],
        [
          {'uid': 'id', 'verified': 'true'},
        ],
        [
          {'uid': 'id', 'specialties': 'Cardiology'},
        ],
        [
          {
            'uid': 'id',
            'degrees': [false],
          },
        ],
        [
          {
            'uid': 'id',
            'clinics': [
              {'name': 'Clinic'},
            ],
          },
        ],
        [
          {
            'uid': 'id',
            'time_available': [
              {'start': '09:00'},
            ],
          },
        ],
      ]) {
        adapter.data = value;
        await expectLater(
          repository.getDoctors(),
          throwsA(
            isA<DoctorsException>().having(
              (e) => e.cause,
              'cause',
              isA<FormatException>(),
            ),
          ),
        );
      }
    });

    test('preserves envelope and HTTP failure codes for diagnostics', () async {
      adapter.envelopeStatus = 403;
      await expectLater(
        repository.getDoctors(),
        throwsA(
          isA<DoctorsException>().having((e) => e.statusCode, 'code', 403),
        ),
      );
      adapter.httpStatus = 500;
      await expectLater(
        repository.getDoctors(),
        throwsA(
          isA<DoctorsException>()
              .having((e) => e.cause, 'cause', isA<DioException>())
              .having((e) => e.statusCode, 'code', 500),
        ),
      );
    });
  });

  test(
    'controller handles duplicate loads, retry, refresh and filters during loading',
    () async {
      final repository = _Repository();
      final container = ProviderContainer.test(
        overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(doctorsControllerProvider, (_, _) {});
      final controller = container.read(doctorsControllerProvider.notifier);
      final first = controller.load();
      await controller.load();
      expect(repository.calls, 1);
      controller.search(' API   DHAKA ');
      controller.selectSpecialty('Cardiology');
      repository.pending.completeError(const DoctorsException('Try again'));
      await first;
      expect(
        container.read(doctorsControllerProvider).errorMessage,
        'Try again',
      );
      repository.pending = Completer<List<Doctor>>();
      final retry = controller.load();
      expect(container.read(doctorsControllerProvider).errorMessage, isNull);
      repository.pending.complete(_doctors);
      await retry;
      expect(
        container.read(doctorsControllerProvider).visibleDoctors.single.id,
        'backend-id',
      );
      await controller.load();
      expect(repository.calls, 2);
      controller.search('');
      controller.selectSpecialty('dermatology');
      expect(
        container.read(doctorsControllerProvider).visibleDoctors.single.id,
        'second-id',
      );
      controller.selectSpecialty('');
      expect(
        container.read(doctorsControllerProvider).visibleDoctors,
        hasLength(2),
      );
      controller.search('missing');
      expect(container.read(doctorsControllerProvider).visibleDoctors, isEmpty);
      repository.pending = Completer<List<Doctor>>();
      final refresh = controller.load(refresh: true);
      repository.pending.complete([]);
      await refresh;
      expect(container.read(doctorsControllerProvider).doctors, isEmpty);
      expect(repository.calls, 3);
    },
  );

  test('in-flight completion is safe after disposal', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(doctorsControllerProvider, (_, _) {});
    final load = container.read(doctorsControllerProvider.notifier).load();
    container.dispose();
    repository.pending.complete(_doctors);
    await load;
  });

  for (final path in ['/doctors/backend-id', '/appointments/backend-id/book']) {
    testWidgets('direct link $path resolves backend ID', (tester) async {
      final repository = _Repository()..pending.complete(_doctors);
      final router = createAppRouter(initialLocation: path);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
          child: Sizer(
            builder: (_, _, _) =>
                MaterialApp.router(theme: AppTheme.light, routerConfig: router),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dr. API Doctor'), findsOneWidget);
      expect(repository.calls, 1);
      if (path.startsWith('/doctors/')) {
        await tester.tap(find.text('Book an appointment'));
        await tester.pumpAndSettle();
      }
      final booking = tester.widget<BookAppointmentScreen>(
        find.byType(BookAppointmentScreen),
      );
      expect(booking.draft.doctor.routeId, 'backend-id');
      expect(booking.draft.doctor.chatPrice, '৳100');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'search and specialty actions filter API cards and preserve identity',
    (tester) async {
      final repository = _Repository()..pending.complete(_doctors);
      final router = createAppRouter(initialLocation: '/doctors?query=Dhaka');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
          child: Sizer(
            builder: (_, _, _) =>
                MaterialApp.router(theme: AppTheme.light, routerConfig: router),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DoctorCard), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.byTooltip('Search doctors'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorCard), findsNWidgets(2));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Cardiology'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorCard), findsOneWidget);
      await tester.ensureVisible(find.text('Dr. API Doctor'));
      await tester.tap(find.text('Dr. API Doctor'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DoctorDetailScreen>(find.byType(DoctorDetailScreen))
            .profile
            .id,
        'backend-id',
      );
      expect(repository.calls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'direct profile links distinguish failure from not found and allow retry',
    (tester) async {
      final repository = _Repository();
      final router = createAppRouter(initialLocation: '/doctors/absent-id');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
          child: Sizer(
            builder: (_, _, _) =>
                MaterialApp.router(theme: AppTheme.light, routerConfig: router),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.pending.completeError(const DoctorsException('Please retry'));
      await tester.pumpAndSettle();
      expect(find.text('Please retry'), findsOneWidget);
      expect(find.text('Doctor not found'), findsNothing);
      repository.pending = Completer<List<Doctor>>();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      repository.pending.complete(_doctors);
      await tester.pumpAndSettle();
      expect(find.text('Doctor not found'), findsOneWidget);
      expect(find.byType(DoctorDetailScreen), findsNothing);
    },
  );
}

class _Repository implements DoctorsRepository {
  int calls = 0;
  var pending = Completer<List<Doctor>>();
  @override
  Future<List<Doctor>> getDoctors() {
    calls++;
    return pending.future;
  }
}

class _Adapter implements HttpClientAdapter {
  Object? data = [];
  int envelopeStatus = 200;
  int httpStatus = 200;
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'status': envelopeStatus, 'msg': 'Result', 'data': data}),
      httpStatus,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
