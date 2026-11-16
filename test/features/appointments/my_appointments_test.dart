import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/appointments/data/models/appointment_model.dart';
import 'package:care_match/features/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:care_match/features/appointments/domain/entities/appointment.dart';
import 'package:care_match/features/appointments/domain/entities/patient_appointment.dart';
import 'package:care_match/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:care_match/features/appointments/domain/usecases/get_patient_appointments.dart';
import 'package:care_match/features/appointments/presentation/controllers/appointments_controller.dart';
import 'package:care_match/features/appointments/presentation/controllers/appointments_state.dart';
import 'package:care_match/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:care_match/features/appointments/presentation/widgets/patient_appointment_card.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'package:care_match/features/profile/domain/entities/user_profile.dart';
import 'package:care_match/features/profile/domain/repositories/profile_repository.dart';
import 'package:care_match/features/profile/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/appointments_test_scope.dart';

Map<String, dynamic> _record({
  String id = 'appointment',
  String status = 'requested',
}) => {
  'appointment_id': id,
  'doctor_id': 'emily',
  'patient_id': 'patient',
  'scheduled_for': '2026-10-17T17:52:41.366Z',
  'status': status,
  'reason': 'Follow-up',
  'notes': 'Bring reports',
  'video_room_id': null,
};

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final type in AppointmentType.values) {
    test('maps patient name and appointment type ${type.value}', () {
      final item = AppointmentModel.fromJson(
        _record()
          ..['patient_name'] = 'Jane Doe'
          ..['appointment_type'] = type.value,
      );
      expect(item.patientName, 'Jane Doe');
      expect(item.type, type);
      expect(
        () => AppointmentModel.fromJson(
          _record()..['appointment_type'] = 'phone',
        ),
        throwsFormatException,
      );
    });

    for (final role in AppointmentRole.values) {
      testWidgets('${role.name} card actions match ${type.value}', (
        tester,
      ) async {
        var completed = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: PatientAppointmentCard(
                  appointment: PatientAppointment(
                    appointment: testAppointment(type: type),
                  ),
                  role: role,
                  onJoinVideo: () {},
                  onOpenChat: () {},
                  onCancel: () {},
                  onComplete: () => completed = true,
                ),
              ),
            ),
          ),
        );
        expect(
          find.text('Join video consultation'),
          type == AppointmentType.video ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Open chat consultation'),
          type == AppointmentType.chat ? findsOneWidget : findsNothing,
        );
        expect(
          find.text(type.label),
          role == AppointmentRole.doctor || type == AppointmentType.inPerson
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.text('Cancel appointment'),
          role == AppointmentRole.doctor ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Mark as completed'),
          role == AppointmentRole.doctor ? findsOneWidget : findsNothing,
        );
        if (role == AppointmentRole.doctor) {
          await tester.ensureVisible(find.text('Mark as completed'));
          await tester.tap(find.text('Mark as completed'));
          expect(completed, isTrue);
        }
      });
    }
  }

  group('API repository', () {
    late _Adapter adapter;
    late Dio dio;
    late AppointmentsRepositoryImpl repository;
    setUp(() {
      adapter = _Adapter();
      dio = createDioClient(
        baseUrl: 'https://example.com/api/v1',
        readAccessToken: () async => 'token',
        adapter: adapter,
      );
      repository = AppointmentsRepositoryImpl(dio: dio);
    });
    tearDown(() => dio.close());

    test('GET patient appointments maps the supplied contract', () async {
      adapter.data = [_record()];
      final item = (await repository.getAppointments()).single;
      expect(adapter.request!.method, 'GET');
      expect(adapter.request!.uri.path, '/api/v1/appointments');
      expect(adapter.request!.queryParameters, {'role': 'patient'});
      expect(adapter.request!.headers['Authorization'], 'Bearer token');
      expect(item.id, 'appointment');
      expect(item.doctorId, 'emily');
      expect(item.patientId, 'patient');
      expect(item.scheduledFor, DateTime.utc(2026, 10, 17, 17, 52, 41, 366));
      expect(item.reason, 'Follow-up');
      expect(item.notes, 'Bring reports');
      expect(item.videoRoomId, isNull);
      expect(item.status, AppointmentStatus.requested);
      expect(item.isActive, isTrue);
    });

    test('GET doctor appointments sends one doctor role value', () async {
      adapter.data = [
        _record()
          ..['patient'] = {
            'uid': 'patient',
            'display_name': 'Jane Doe',
            'email': 'jane@example.com',
            'phone_number': '+8801712345678',
          },
      ];
      final item = (await repository.getAppointments(
        role: AppointmentRole.doctor,
      )).single;
      expect(adapter.request!.queryParameters, {'role': 'doctor'});
      expect(item.patient!.name, 'Jane Doe');
      expect(item.patient!.email, 'jane@example.com');
      expect(item.patient!.phoneNumber, '+8801712345678');
      adapter.data = [
        _record()..['patient'] = {'uid': 'someone-else'},
      ];
      await expectLater(
        repository.getAppointments(role: AppointmentRole.doctor),
        throwsA(isA<AppointmentsException>()),
      );
    });

    test(
      'PATCH sends new_status in the query and trusts the returned record',
      () async {
        adapter.data = _record(id: 'a/b', status: 'cancelled')
          ..['notes'] = 'Updated by server';
        final result = await repository.updateStatus(
          appointmentId: 'a/b',
          status: AppointmentStatus.cancelled,
        );
        expect(adapter.request!.method, 'PATCH');
        expect(adapter.request!.path, '/appointments/a%2Fb/status');
        expect(adapter.request!.queryParameters, {'new_status': 'cancelled'});
        expect(adapter.request!.data, isNull);
        expect(result.status, AppointmentStatus.cancelled);
        expect(result.notes, 'Updated by server');
      },
    );

    test(
      'supports empty data, nullable fields and every documented status',
      () async {
        expect(await repository.getAppointments(), isEmpty);
        for (final status in AppointmentStatus.values) {
          final item = AppointmentModel.fromJson(
            _record(status: status.name)
              ..['notes'] = null
              ..['video_room_id'] = 'room',
          );
          expect(item.status, status);
          expect(item.notes, isNull);
          expect(item.videoRoomId, 'room');
        }
      },
    );

    test(
      'rejects malformed fields, duplicate IDs and invalid calendar dates',
      () async {
        final malformed = [
          {'appointment_id': ''},
          {'doctor_id': 4},
          {'patient_id': null},
          {'reason': false},
          {'notes': 42},
          {'video_room_id': []},
          {'status': 'unknown'},
          {'scheduled_for': 'not a date'},
          {'scheduled_for': '2026-02-30T17:00:00Z'},
          {'scheduled_for': '2026-10-17T24:00:00Z'},
        ];
        for (final fields in malformed) {
          adapter.data = [
            {..._record(), ...fields},
          ];
          await expectLater(
            repository.getAppointments(),
            throwsA(
              isA<AppointmentsException>().having(
                (e) => e.cause,
                'cause',
                isA<FormatException>(),
              ),
            ),
          );
        }
        for (final data in <Object?>[
          {},
          [false],
          [_record(), _record()],
        ]) {
          adapter.data = data;
          await expectLater(
            repository.getAppointments(),
            throwsA(isA<AppointmentsException>()),
          );
        }
      },
    );

    test(
      'preserves authorization errors and uncertain mutation results',
      () async {
        adapter.httpStatus = 401;
        await expectLater(
          repository.getAppointments(),
          throwsA(
            isA<AppointmentsException>().having(
              (e) => e.statusCode,
              'code',
              401,
            ),
          ),
        );
        adapter.httpStatus = 200;
        adapter.envelopeStatus = 403;
        await expectLater(
          repository.getAppointments(),
          throwsA(
            isA<AppointmentsException>().having(
              (e) => e.statusCode,
              'code',
              403,
            ),
          ),
        );
        adapter.envelopeStatus = 200;
        adapter.data = _record(id: 'wrong', status: 'cancelled');
        await expectLater(
          repository.updateStatus(
            appointmentId: 'appointment',
            status: AppointmentStatus.cancelled,
          ),
          throwsA(
            isA<AppointmentsException>().having(
              (e) => e.mayHaveSucceeded,
              'uncertain',
              isTrue,
            ),
          ),
        );
        adapter.httpStatus = 500;
        await expectLater(
          repository.updateStatus(
            appointmentId: 'appointment',
            status: AppointmentStatus.cancelled,
          ),
          throwsA(
            isA<AppointmentsException>().having(
              (e) => e.mayHaveSucceeded,
              'uncertain',
              isTrue,
            ),
          ),
        );
      },
    );
  });

  test(
    'use case enriches by ID and tolerates unavailable doctor details',
    () async {
      final repository = _Repository()
        ..records = [
          testAppointment(),
          testAppointment(id: 'other', doctorId: 'missing'),
        ];
      final doctors = _Doctors();
      final usecase = GetPatientAppointments(
        appointmentsRepository: repository,
        doctorsRepository: doctors,
      );
      final result = await usecase();
      expect(result.appointments.first.doctor!.id, 'emily');
      expect(result.appointments.last.doctor, isNull);
      expect(result.doctorDetailsUnavailable, isTrue);
      doctors.error = const DoctorsException('Offline');
      expect((await usecase()).appointments, hasLength(2));
      repository.records = [];
      final calls = doctors.calls;
      expect((await usecase()).appointments, isEmpty);
      expect(doctors.calls, calls);
      repository.error = const AppointmentsException('Offline');
      await expectLater(usecase(), throwsA(isA<AppointmentsException>()));
      expect(doctors.calls, calls);
    },
  );

  ProviderContainer containerFor(
    _Repository repository, {
    _Doctors? doctors,
    AppointmentRole role = AppointmentRole.patient,
  }) {
    final container = ProviderContainer.test(
      overrides: [
        appointmentRoleProvider.overrideWith((ref) async => role),
        appointmentsRepositoryProvider.overrideWithValue(repository),
        doctorsRepositoryProvider.overrideWithValue(doctors ?? _Doctors()),
        authSessionProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    container.listen(appointmentsControllerProvider, (_, _) {});
    return container;
  }

  test(
    'patient controller blocks cancellation and completion requests',
    () async {
      final repository = _Repository()..records = [testAppointment()];
      final container = containerFor(repository);
      final controller = container.read(
        appointmentsControllerProvider.notifier,
      );
      await controller.load();
      await controller.cancelAppointment('requested');
      await controller.completeAppointment('requested');
      expect(repository.updates, 0);
      expect(
        container
            .read(appointmentsControllerProvider)
            .appointments
            .single
            .appointment
            .status,
        AppointmentStatus.requested,
      );
    },
  );

  for (final type in AppointmentType.values) {
    test(
      'doctor controller completes ${type.value} and moves it to Completed',
      () async {
        final repository = TestAppointmentsRepository();
        repository.records.clear();
        repository.records.add(testAppointment(type: type));
        final container = ProviderContainer.test(
          overrides: [
            appointmentRoleProvider.overrideWith(
              (ref) async => AppointmentRole.doctor,
            ),
            appointmentsRepositoryProvider.overrideWithValue(repository),
            doctorsRepositoryProvider.overrideWithValue(_Doctors()),
            authSessionProvider.overrideWith((ref) => const Stream.empty()),
          ],
        );
        container.listen(appointmentsControllerProvider, (_, _) {});
        final controller = container.read(
          appointmentsControllerProvider.notifier,
        );
        await controller.load();
        await controller.completeAppointment('requested');
        expect(
          container.read(appointmentsControllerProvider).visibleAppointments,
          isEmpty,
        );
        controller.selectFilter(AppointmentsFilter.completed);
        final completed = container
            .read(appointmentsControllerProvider)
            .visibleAppointments
            .single
            .appointment;
        expect(completed.status, AppointmentStatus.completed);
        expect(completed.type, type);
        await controller.completeAppointment('requested');
        expect(
          container.read(appointmentsControllerProvider).updateErrors,
          isEmpty,
        );
      },
    );
  }

  test('account profile determines the appointment query role', () async {
    for (final role in ['patient', 'doctor']) {
      final container = ProviderContainer.test(
        overrides: [
          profileRepositoryProvider.overrideWithValue(_Profiles(role)),
          authSessionProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      expect((await container.read(appointmentRoleProvider.future)).name, role);
    }
  });

  test(
    'doctor load skips doctor directory and preserves patient details on cancellation',
    () async {
      final patient = AppointmentModel.fromJson(
        _record()..['patient'] = {'uid': 'patient', 'display_name': 'Jane Doe'},
      );
      final repository = _Repository()..records = [patient];
      final doctors = _Doctors()..error = const DoctorsException('Offline');
      final container = ProviderContainer.test(
        overrides: [
          appointmentRoleProvider.overrideWith(
            (ref) async => AppointmentRole.doctor,
          ),
          appointmentsRepositoryProvider.overrideWithValue(repository),
          doctorsRepositoryProvider.overrideWithValue(doctors),
          authSessionProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      container.listen(appointmentsControllerProvider, (_, _) {});
      final controller = container.read(
        appointmentsControllerProvider.notifier,
      );
      await controller.load();
      expect(repository.lastRole, AppointmentRole.doctor);
      expect(
        container.read(appointmentsControllerProvider).role,
        AppointmentRole.doctor,
      );
      expect(doctors.calls, 0);
      expect(
        container.read(appointmentsControllerProvider).doctorDetailsUnavailable,
        isFalse,
      );
      await controller.cancelAppointment('appointment');
      expect(
        container
            .read(appointmentsControllerProvider)
            .appointments
            .single
            .appointment
            .patient!
            .name,
        'Jane Doe',
      );
    },
  );

  test(
    'controller handles loading, retries and ordered status filters',
    () async {
      final repository = _Repository()
        ..pendingLoad = Completer<List<Appointment>>();
      final container = containerFor(repository);
      final controller = container.read(
        appointmentsControllerProvider.notifier,
      );
      final first = controller.load();
      await controller.load();
      await container.pump();
      expect(repository.loads, 1);
      expect(container.read(appointmentsControllerProvider).isLoading, isTrue);
      repository.pendingLoad!.completeError(
        const AppointmentsException('Try again'),
      );
      await first;
      expect(
        container.read(appointmentsControllerProvider).errorMessage,
        'Try again',
      );
      repository.pendingLoad = null;
      repository.records = [
        testAppointment(id: 'later', scheduledFor: DateTime.utc(2031)),
        testAppointment(
          id: 'earlier',
          scheduledFor: DateTime.utc(2030),
          status: AppointmentStatus.confirmed,
        ),
        testAppointment(id: 'done', status: AppointmentStatus.completed),
      ];
      await controller.load();
      expect(
        container.read(appointmentsControllerProvider).errorMessage,
        isNull,
      );
      expect(
        container
            .read(appointmentsControllerProvider)
            .visibleAppointments
            .map((e) => e.appointment.id),
        ['earlier', 'later'],
      );
      controller.selectFilter(AppointmentsFilter.completed);
      expect(
        container
            .read(appointmentsControllerProvider)
            .visibleAppointments
            .single
            .appointment
            .id,
        'done',
      );
    },
  );

  test(
    'cancellation waits for server, prevents duplicates and preserves records on failure',
    () async {
      final repository = _Repository()
        ..records = [testAppointment()]
        ..pendingUpdate = Completer<Appointment>();
      final container = containerFor(repository, role: AppointmentRole.doctor);
      final controller = container.read(
        appointmentsControllerProvider.notifier,
      );
      await controller.load();
      final cancel = controller.cancelAppointment('requested');
      await controller.cancelAppointment('requested');
      await controller.load(refresh: true);
      expect(repository.updates, 1);
      expect(repository.loads, 1);
      expect(
        container.read(appointmentsControllerProvider).updatingIds,
        contains('requested'),
      );
      expect(
        container
            .read(appointmentsControllerProvider)
            .appointments
            .single
            .appointment
            .status,
        AppointmentStatus.requested,
      );
      repository.pendingUpdate!.completeError(
        const AppointmentsException('Not permitted'),
      );
      await cancel;
      expect(
        container
            .read(appointmentsControllerProvider)
            .updateErrors['requested'],
        'Not permitted',
      );
      expect(
        container.read(appointmentsControllerProvider).visibleAppointments,
        hasLength(1),
      );
      repository.pendingUpdate = null;
      await controller.cancelAppointment('requested');
      expect(
        container.read(appointmentsControllerProvider).visibleAppointments,
        isEmpty,
      );
      controller.selectFilter(AppointmentsFilter.cancelled);
      expect(
        container
            .read(appointmentsControllerProvider)
            .visibleAppointments
            .single
            .appointment
            .status,
        AppointmentStatus.cancelled,
      );
      expect(
        container.read(appointmentsControllerProvider).updateErrors,
        isEmpty,
      );
    },
  );

  test(
    'uncertain cancellation requires refresh before another attempt',
    () async {
      final repository = _Repository()
        ..records = [testAppointment()]
        ..updateError = const AppointmentsException(
          'Refresh first',
          mayHaveSucceeded: true,
        );
      final container = containerFor(repository, role: AppointmentRole.doctor);
      final controller = container.read(
        appointmentsControllerProvider.notifier,
      );
      await controller.load();
      await controller.cancelAppointment('requested');
      await controller.cancelAppointment('requested');
      expect(repository.updates, 1);
      expect(
        container.read(appointmentsControllerProvider).uncertainIds,
        contains('requested'),
      );
      await controller.load(refresh: true);
      repository.updateError = null;
      await controller.cancelAppointment('requested');
      expect(repository.updates, 2);
    },
  );

  test(
    'account changes clear data and ignore an in-flight previous-account load',
    () async {
      final sessions = StreamController<AuthUser?>();
      addTearDown(sessions.close);
      final repository = _Repository();
      final container = ProviderContainer.test(
        overrides: [
          appointmentRoleProvider.overrideWith(
            (ref) async => AppointmentRole.patient,
          ),
          appointmentsRepositoryProvider.overrideWithValue(repository),
          doctorsRepositoryProvider.overrideWithValue(_Doctors()),
          authSessionProvider.overrideWith((ref) => sessions.stream),
        ],
      );
      container.listen(appointmentsControllerProvider, (_, _) {});
      sessions.add(const AuthUser(uid: 'first'));
      await container.pump();
      repository.pendingLoad = Completer<List<Appointment>>();
      final load = container
          .read(appointmentsControllerProvider.notifier)
          .load(refresh: true);
      sessions.add(null);
      await container.pump();
      repository.pendingLoad!.complete([testAppointment()]);
      await load;
      expect(
        container.read(appointmentsControllerProvider).appointments,
        isEmpty,
      );
      expect(
        container.read(appointmentsControllerProvider).errorMessage,
        contains('Sign in'),
      );
    },
  );

  test('in-flight cancellation cannot repopulate state after logout', () async {
    final sessions = StreamController<AuthUser?>();
    addTearDown(sessions.close);
    final repository = _Repository()
      ..records = [testAppointment()]
      ..pendingUpdate = Completer<Appointment>();
    final container = ProviderContainer.test(
      overrides: [
        appointmentRoleProvider.overrideWith(
          (ref) async => AppointmentRole.doctor,
        ),
        appointmentsRepositoryProvider.overrideWithValue(repository),
        doctorsRepositoryProvider.overrideWithValue(_Doctors()),
        authSessionProvider.overrideWith((ref) => sessions.stream),
      ],
    );
    container.listen(appointmentsControllerProvider, (_, _) {});
    sessions.add(const AuthUser(uid: 'first'));
    await container.pump();
    final cancel = container
        .read(appointmentsControllerProvider.notifier)
        .cancelAppointment('requested');
    sessions.add(null);
    await container.pump();
    repository.pendingUpdate!.complete(
      testAppointment(status: AppointmentStatus.cancelled),
    );
    await cancel;
    expect(
      container.read(appointmentsControllerProvider).appointments,
      isEmpty,
    );
  });

  testWidgets(
    'doctor cards show patient contact details and patient cards omit them',
    (tester) async {
      final appointment = AppointmentModel.fromJson(
        _record()
          ..['patient_name'] = 'Jane Doe'
          ..['patient'] = {
            'uid': 'patient',
            'display_name': 'Jane Doe',
            'email': 'jane@example.com',
            'phone_number': '+8801712345678',
          },
      );
      for (final role in AppointmentRole.values) {
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(role),
            overrides: [
              appointmentRoleProvider.overrideWith((ref) async => role),
              appointmentsRepositoryProvider.overrideWithValue(
                _Repository()..records = [appointment],
              ),
              doctorsRepositoryProvider.overrideWithValue(_Doctors()),
              authSessionProvider.overrideWith((ref) => const Stream.empty()),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const MyAppointmentsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Jane Doe'),
          role == AppointmentRole.doctor ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Email: jane@example.com'),
          role == AppointmentRole.doctor ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Phone: +8801712345678'),
          role == AppointmentRole.doctor ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Dr. Emily Carter'),
          role == AppointmentRole.patient ? findsOneWidget : findsNothing,
        );
      }
    },
  );

  testWidgets(
    'doctor confirms completion and moves server record into Completed',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        appointmentsTestScope(
          MaterialApp(
            theme: AppTheme.light,
            home: const MyAppointmentsScreen(),
          ),
          role: AppointmentRole.doctor,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PatientAppointmentCard), findsNWidgets(3));
      expect(find.text('Requested'), findsNWidgets(2));
      expect(find.text('Confirmed'), findsOneWidget);
      await tester.tap(find.text('Mark as completed').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep appointment'));
      await tester.pumpAndSettle();
      expect(find.byType(PatientAppointmentCard), findsNWidgets(3));
      await tester.tap(find.text('Mark as completed').first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Mark as completed'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PatientAppointmentCard), findsNWidgets(2));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsNWidgets(3));
      expect(find.text('Mark as completed'), findsNothing);
    },
  );

  testWidgets(
    'failed fetch offers retry and empty server data has no fabricated bookings',
    (tester) async {
      final repository = _Repository()
        ..error = const AppointmentsException('Load failed');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appointmentRoleProvider.overrideWith(
              (ref) async => AppointmentRole.patient,
            ),
            appointmentsRepositoryProvider.overrideWithValue(repository),
            doctorsRepositoryProvider.overrideWithValue(_Doctors()),
            authSessionProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MyAppointmentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Load failed'), findsOneWidget);
      expect(find.byType(PatientAppointmentCard), findsNothing);
      repository.error = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No upcoming appointments.'), findsOneWidget);
      expect(find.byType(PatientAppointmentCard), findsNothing);
    },
  );
}

class _Repository implements AppointmentsRepository {
  List<Appointment> records = [];
  Object? error;
  Object? updateError;
  Completer<List<Appointment>>? pendingLoad;
  Completer<Appointment>? pendingUpdate;
  int loads = 0;
  int updates = 0;
  AppointmentRole? lastRole;
  @override
  Future<List<Appointment>> getAppointments({
    AppointmentRole role = AppointmentRole.patient,
  }) async {
    loads++;
    lastRole = role;
    if (error != null) throw error!;
    return pendingLoad?.future ?? records;
  }

  @override
  Future<Appointment> updateStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) async {
    updates++;
    if (updateError != null) throw updateError!;
    return pendingUpdate?.future ??
        testAppointment(id: appointmentId, status: status);
  }
}

class _Profiles implements ProfileRepository {
  _Profiles(this.role);
  final String role;

  @override
  Future<UserProfile> getProfile() async => UserProfile(role: role);

  @override
  Future<UserProfile> updateProfile(ProfileUpdate update) =>
      throw UnimplementedError();
}

class _Doctors implements DoctorsRepository {
  int calls = 0;
  Object? error;
  @override
  Future<List<Doctor>> getDoctors() async {
    calls++;
    if (error != null) throw error!;
    return [Doctor(id: 'emily', name: 'Dr. Emily Carter')];
  }
}

class _Adapter implements HttpClientAdapter {
  Object? data = [];
  int httpStatus = 200;
  int envelopeStatus = 200;
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'status': envelopeStatus, 'msg': 'Success', 'data': data}),
      httpStatus,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
