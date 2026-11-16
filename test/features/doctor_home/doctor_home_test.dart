import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/home/domain/repositories/home_repository.dart';
import 'package:care_match/features/home/domain/entities/featured_doctor.dart';
import 'package:care_match/features/home/providers.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/appointments/domain/entities/appointment.dart';
import 'package:care_match/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/doctor_home/domain/get_doctor_overview.dart';
import 'package:care_match/features/doctor_home/presentation/controllers/doctor_home_controller.dart';
import 'package:care_match/features/doctor_home/presentation/screens/doctor_home_screen.dart';
import 'package:care_match/features/doctor_home/providers.dart';
import 'package:care_match/features/home/presentation/home_screen.dart';
import 'package:care_match/features/home/presentation/role_home_screen.dart';
import 'package:care_match/features/profile/data/models/user_profile_model.dart';
import 'package:care_match/features/profile/domain/entities/user_profile.dart';
import 'package:care_match/features/profile/domain/repositories/profile_repository.dart';
import 'package:care_match/features/profile/providers.dart';
import 'package:care_match/shared/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final now = DateTime(2026, 11, 2, 9);
Appointment appointment(
  String id,
  DateTime date, {
  AppointmentStatus status = AppointmentStatus.confirmed,
  AppointmentType type = AppointmentType.video,
  String name = 'Nadia Rahman',
}) => Appointment(
  id: id,
  doctorId: 'doctor',
  patientId: 'patient-$id',
  scheduledFor: date,
  status: status,
  reason: 'Follow-up visit',
  patientName: name,
  type: type,
);

class _Profile implements ProfileRepository {
  _Profile({this.role = 'doctor'});
  final String role;
  @override
  Future<UserProfile> getProfile() async =>
      UserProfile(role: role, totalEarnings: 24500);
  @override
  Future<UserProfile> updateProfile(ProfileUpdate update) async => getProfile();
}

class _Appointments implements AppointmentsRepository {
  bool fail = false;
  Completer<List<Appointment>>? pending;
  AppointmentRole? requestedRole;
  List<Appointment> records = [
    appointment('one', DateTime(2026, 11, 2, 10, 30)),
    appointment(
      'two',
      DateTime(2026, 11, 2, 11, 15),
      type: AppointmentType.inPerson,
      name: 'Arif Hasan',
    ),
    appointment('future', DateTime(2026, 11, 3, 10)),
    appointment(
      'cancelled',
      DateTime(2026, 11, 2, 12),
      status: AppointmentStatus.cancelled,
    ),
    appointment(
      'done',
      DateTime(2026, 11, 1, 12),
      status: AppointmentStatus.completed,
    ),
  ];
  @override
  Future<List<Appointment>> getAppointments({
    AppointmentRole role = AppointmentRole.patient,
  }) async {
    requestedRole = role;
    if (fail) throw const AppointmentsException('Please retry.');
    return pending == null ? records : pending!.future;
  }

  @override
  Future<Appointment> updateStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) => throw UnimplementedError();
}

Widget _scope(
  Widget child,
  _Appointments appointments, {
  String role = 'doctor',
}) => ProviderScope(
  overrides: [
    profileRepositoryProvider.overrideWithValue(_Profile(role: role)),
    homeRepositoryProvider.overrideWithValue(_Home()),
    appointmentsRepositoryProvider.overrideWithValue(appointments),
    doctorHomeClockProvider.overrideWithValue(() => now),
    authSessionProvider.overrideWith((ref) => const Stream.empty()),
  ],
  child: MaterialApp(theme: AppTheme.light, home: child),
);

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    if (const bool.fromEnvironment('CAPTURE_DOCTOR_HOME')) {
      const fonts =
          '/home/nahian-dev/Dev Modules/flutter/bin/cache/artifacts/material_fonts';
      for (final family in [
        'Inter',
        'Inter_400',
        'Inter_regular',
        'Inter_600',
        'Inter_700',
      ]) {
        final loader = FontLoader(family)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await File('$fonts/Roboto-Regular.ttf').readAsBytes(),
              ),
            ),
          );
        await loader.load();
      }
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              await File('$fonts/MaterialIcons-Regular.otf').readAsBytes(),
            ),
          ),
        );
      await icons.load();
    }
  });
  test('maps earnings, leaving unavailable earnings unknown', () {
    expect(
      UserProfileModel.fromJson({'total_earnings': 24500}).totalEarnings,
      24500,
    );
    expect(UserProfileModel.fromJson({'total_earnings': 0}).totalEarnings, 0);
    expect(UserProfileModel.fromJson({}).totalEarnings, isNull);
  });
  test(
    'combines doctor profile and appointments, counts dates and excludes cancelled',
    () async {
      final repository = _Appointments();
      final result = await GetDoctorOverview(
        profiles: _Profile(),
        appointments: repository,
        now: () => now,
      )();
      expect(repository.requestedRole, AppointmentRole.doctor);
      expect(result.upcomingCount, 3);
      expect(result.today.map((a) => a.id), ['one', 'two']);
      expect(result.inPersonTodayCount, 1);
      expect(result.profile.totalEarnings, 24500);
    },
  );
  test('patient accounts cannot load doctor appointments', () async {
    final repository = _Appointments();
    await expectLater(
      GetDoctorOverview(
        profiles: _Profile(role: 'patient'),
        appointments: repository,
        now: () => now,
      )(),
      throwsA(isA<AppointmentsException>()),
    );
    expect(repository.requestedRole, isNull);
  });
  test('controller preserves data on a failed refresh and retries', () async {
    final repository = _Appointments();
    final container = ProviderContainer.test(
      overrides: [
        profileRepositoryProvider.overrideWithValue(_Profile()),
        appointmentsRepositoryProvider.overrideWithValue(repository),
        doctorHomeClockProvider.overrideWithValue(() => now),
        authSessionProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    container.listen(doctorHomeControllerProvider, (_, _) {});
    final controller = container.read(doctorHomeControllerProvider.notifier);
    await controller.load();
    expect(container.read(doctorHomeControllerProvider).overview, isNotNull);
    repository.fail = true;
    await controller.load();
    expect(container.read(doctorHomeControllerProvider).error, 'Please retry.');
    expect(container.read(doctorHomeControllerProvider).overview, isNotNull);
    repository.fail = false;
    await controller.load();
    expect(container.read(doctorHomeControllerProvider).error, isNull);
  });
  test('account changes discard an in-flight dashboard response', () async {
    final sessions = StreamController<AuthUser?>();
    addTearDown(sessions.close);
    final repository = _Appointments()
      ..pending = Completer<List<Appointment>>();
    final container = ProviderContainer.test(
      overrides: [
        profileRepositoryProvider.overrideWithValue(_Profile()),
        appointmentsRepositoryProvider.overrideWithValue(repository),
        authSessionProvider.overrideWith((ref) => sessions.stream),
      ],
    );
    container.listen(doctorHomeControllerProvider, (_, _) {});
    sessions.add(const AuthUser(uid: 'doctor'));
    await Future<void>.delayed(Duration.zero);
    final controller = container.read(doctorHomeControllerProvider.notifier);
    final loading = controller.load();
    await Future<void>.delayed(Duration.zero);
    await controller.load();
    sessions.add(null);
    await Future<void>.delayed(Duration.zero);
    repository.pending!.complete(repository.records);
    await loading;
    expect(container.read(doctorHomeControllerProvider).overview, isNull);
  });

  testWidgets('patient role keeps the existing home and four navigation tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scope(const RoleHomeScreen(), _Appointments(), role: 'patient'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(DoctorHomeScreen), findsNothing);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });

  testWidgets(
    'dashboard shows load failure and retries without invented counts',
    (tester) async {
      final repository = _Appointments()..fail = true;
      await tester.pumpWidget(_scope(const DoctorHomeScreen(), repository));
      await tester.pumpAndSettle();
      expect(find.text('Please retry.'), findsOneWidget);
      expect(find.text('৳24,500'), findsNothing);
      repository.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('৳24,500'), findsOneWidget);
    },
  );

  testWidgets(
    'doctor role shows dashboard, patient names, details and three tabs',
    (tester) async {
      tester.view.physicalSize = const Size(420, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        _scope(
          RepaintBoundary(key: key, child: const RoleHomeScreen()),
          _Appointments(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DoctorHomeScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('৳24,500'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      if (const bool.fromEnvironment('CAPTURE_DOCTOR_HOME')) {
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/images/carematch_logo.png'),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/care-match-doctor-home.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nadia Rahman'));
      await tester.pumpAndSettle();
      expect(find.text('Appointment details'), findsOneWidget);
      expect(find.text('Reason : Follow-up visit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    testWidgets('dashboard fits $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _scope(
          MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(1.5),
            ),
            child: const DoctorHomeScreen(),
          ),
          _Appointments(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Arif Hasan'), 200);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('patient navigation keeps Doctors tab', (tester) async {
    await tester.pumpWidget(
      _scope(
        const Scaffold(bottomNavigationBar: BottomNavBar(current: 2)),
        _Appointments(),
        role: 'patient',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
  });
}

class _Home implements HomeRepository {
  @override
  Future<List<FeaturedDoctor>> getFeaturedDoctors() async => [];
}
