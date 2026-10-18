import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'package:care_match/features/home/data/repositories/home_repository_impl.dart';
import 'package:care_match/features/home/domain/entities/featured_doctor.dart';
import 'package:care_match/features/home/domain/repositories/home_repository.dart';
import 'package:care_match/features/home/presentation/controllers/home_controller.dart';
import 'package:care_match/features/home/presentation/home_screen.dart';
import 'package:care_match/features/home/presentation/widgets/doctor_card_shimmer.dart';
import 'package:care_match/features/home/providers.dart';
import 'package:care_match/router.dart';
import 'package:care_match/shared/widgets/doctor_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  late _Adapter adapter;
  late Dio dio;
  late HomeRepositoryImpl repository;

  setUp(() {
    adapter = _Adapter();
    dio = createDioClient(
      baseUrl: 'https://example.com/api/v1',
      readAccessToken: () async => 'token',
      adapter: adapter,
    );
    repository = HomeRepositoryImpl(dio: dio);
  });
  tearDown(() => dio.close());

  test(
    'uses GET doctors with limit and verified, mapping up to five doctors',
    () async {
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': List.generate(
          7,
          (index) => {
            'uid': 'doctor-$index',
            'display_name': ' Doctor $index ',
            'specialties': [' Medicine ', 'Cardiology'],
            'degrees': ['MBBS', 'MD'],
            'clinics': [
              {'name': 'Care Clinic', 'location': 'Dhaka'},
            ],
            'days_available': ['Monday'],
            'time_available': [
              {'start': '17:52:22.832Z', 'end': '18:52:22.832Z'},
            ],
            'verified': index.isEven,
          },
        ),
      };
      final doctors = await repository.getFeaturedDoctors();
      expect(adapter.request!.method, 'GET');
      expect(adapter.request!.uri.path, '/api/v1/users/doctors');
      expect(adapter.request!.uri.queryParameters, {
        'limit': '5',
        'verified': 'true',
      });
      expect(doctors, hasLength(5));
      expect(doctors.first.id, 'doctor-0');
      expect(doctors.first.name, 'Doctor 0');
      expect(doctors.first.specialties, ['Medicine', 'Cardiology']);
      expect(doctors.first.availability, isNull);
      expect(doctors.first.degrees, ['MBBS', 'MD']);
      expect(doctors.first.clinics.single.name, 'Care Clinic');
      expect(doctors.first.clinics.single.location, 'Dhaka');
      expect(doctors.first.daysAvailable, ['Monday']);
      expect(doctors.first.timeAvailable.single.start, '17:52:22.832Z');
      expect(doctors.first.timeAvailable.single.end, '18:52:22.832Z');
      expect(doctors.first.verified, isTrue);
      expect(doctors[1].verified, isFalse);
    },
  );

  test(
    'supports empty data and rejects malformed responses and profiles',
    () async {
      adapter.body = {'status': 200, 'msg': 'Success', 'data': []};
      expect(await repository.getFeaturedDoctors(), isEmpty);
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': [
          {'uid': 'firebase-id', 'display_name': null},
        ],
      };
      final doctors = await repository.getFeaturedDoctors();
      expect(doctors.single.id, 'firebase-id');
      expect(doctors.single.name, isNull);
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': [
          {'display_name': 'Missing identifier'},
        ],
      };
      await expectLater(
        repository.getFeaturedDoctors(),
        throwsA(isA<HomeException>()),
      );
      adapter.body = 'invalid';
      await expectLater(
        repository.getFeaturedDoctors(),
        throwsA(isA<HomeException>()),
      );
    },
  );

  test(
    'rejects invalid nested doctor fields and unsuccessful envelopes',
    () async {
      for (final fields in <Map<String, Object?>>[
        {'verified': 'false'},
        {'degrees': 'MBBS'},
        {
          'specialties': [42],
        },
        {
          'clinics': [
            {'name': 'Clinic'},
          ],
        },
        {
          'days_available': [false],
        },
        {
          'time_available': [
            {'start': '17:52:22.832Z'},
          ],
        },
      ]) {
        adapter.body = {
          'status': 200,
          'msg': 'Success',
          'data': [
            {'uid': 'doctor', ...fields},
          ],
        };
        await expectLater(
          repository.getFeaturedDoctors(),
          throwsA(isA<HomeException>()),
        );
      }
      adapter.body = {'status': 400, 'msg': 'Failure', 'data': []};
      await expectLater(
        repository.getFeaturedDoctors(),
        throwsA(isA<HomeException>()),
      );
      adapter.body = {'status': 200, 'data': {}};
      await expectLater(
        repository.getFeaturedDoctors(),
        throwsA(isA<HomeException>()),
      );
    },
  );

  test('network failures become domain failures', () async {
    adapter.status = 500;
    await expectLater(
      repository.getFeaturedDoctors(),
      throwsA(
        isA<HomeException>().having(
          (e) => e.cause,
          'cause',
          isA<DioException>(),
        ),
      ),
    );
  });

  test(
    'controller prevents duplicate requests and can retry failures',
    () async {
      final fake = _Repository();
      final container = ProviderContainer.test(
        overrides: [homeRepositoryProvider.overrideWithValue(fake)],
      );
      container.listen(homeControllerProvider, (_, _) {});
      final controller = container.read(homeControllerProvider.notifier);
      final load = controller.loadDoctors();
      await controller.loadDoctors();
      expect(fake.calls, 1);
      expect(container.read(homeControllerProvider).isLoading, isTrue);
      fake.result.completeError(const HomeException('Please retry.'));
      await load;
      expect(
        container.read(homeControllerProvider).errorMessage,
        'Please retry.',
      );
      fake.result = Completer<List<FeaturedDoctor>>();
      final retry = controller.loadDoctors();
      fake.result.complete([
        const FeaturedDoctor(id: 'doctor', name: 'API doctor'),
      ]);
      await retry;
      expect(
        container.read(homeControllerProvider).doctors.single.name,
        'API doctor',
      );
      expect(container.read(homeControllerProvider).errorMessage, isNull);
    },
  );

  testWidgets('loads on entry once and opens fetched doctor details', (
    tester,
  ) async {
    final fake = _Repository();
    final router = createAppRouter(initialLocation: '/home');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(fake)],
        child: Sizer(
          builder: (_, _, _) =>
              MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        ),
      ),
    );
    await tester.pump();
    expect(fake.calls, 1);
    expect(find.byType(DoctorCardShimmer), findsNWidgets(5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    fake.result.complete(
      List.generate(
        5,
        (i) => FeaturedDoctor(
          id: 'real-id-$i',
          name: 'API Doctor $i',
          specialties: const ['Cardiology'],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(fake.calls, 1);
    expect(find.byType(DoctorCard), findsNWidgets(5));
    expect(find.byType(DoctorCardShimmer), findsNothing);
    expect(find.text('Dr. Emily Carter'), findsNothing);
    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('API Doctor 0'));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorDetailScreen), findsOneWidget);
    expect(
      GoRouterState.of(
        tester.element(find.byType(DoctorDetailScreen)),
      ).pathParameters['doctorId'],
      'real-id-0',
    );
    expect(find.text('API Doctor 0'), findsOneWidget);
    expect(find.text('Doctor not found'), findsNothing);
  });

  testWidgets(
    'failed load offers retry and an empty response has no sample cards',
    (tester) async {
      final fake = _Repository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [homeRepositoryProvider.overrideWithValue(fake)],
          child: Sizer(
            builder: (_, _, _) =>
                MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      fake.result.completeError(const HomeException('Please retry.'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -350));
      await tester.pumpAndSettle();
      fake.result = Completer<List<FeaturedDoctor>>();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      fake.result.complete([]);
      await tester.pumpAndSettle();
      expect(fake.calls, 2);
      expect(find.text('No verified doctors found.'), findsOneWidget);
      expect(find.byType(DoctorCard), findsNothing);
    },
  );
}

class _Repository implements HomeRepository {
  var calls = 0;
  var result = Completer<List<FeaturedDoctor>>();

  @override
  Future<List<FeaturedDoctor>> getFeaturedDoctors() {
    calls++;
    return result.future;
  }
}

class _Adapter implements HttpClientAdapter {
  Object? body = [];
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
