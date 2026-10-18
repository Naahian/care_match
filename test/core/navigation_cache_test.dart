import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import 'package:care_match/features/appointments/domain/entities/appointment.dart';
import 'package:care_match/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:care_match/features/appointments/presentation/controllers/appointments_controller.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:care_match/features/doctors/presentation/controllers/doctors_controller.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'package:care_match/features/home/domain/entities/featured_doctor.dart';
import 'package:care_match/features/home/domain/repositories/home_repository.dart';
import 'package:care_match/features/home/presentation/controllers/home_controller.dart';
import 'package:care_match/features/home/providers.dart';
import 'package:care_match/features/profile/domain/entities/user_profile.dart';
import 'package:care_match/features/profile/domain/repositories/profile_repository.dart';
import 'package:care_match/features/profile/presentation/controllers/profile_controller.dart';
import 'package:care_match/features/profile/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  void checkCache<T>(
    String name,
    ProviderListenable<T> provider,
    Future<void> Function(ProviderContainer, bool) load,
  ) {
    test(
      '$name survives leaving the screen and refreshes only on request',
      () async {
        final repository = _Repository();
        final container = ProviderContainer.test(
          overrides: [
            appointmentsRepositoryProvider.overrideWithValue(repository),
            doctorsRepositoryProvider.overrideWithValue(repository),
            homeRepositoryProvider.overrideWithValue(repository),
            profileRepositoryProvider.overrideWithValue(repository),
            authSessionProvider.overrideWith((ref) => const Stream.empty()),
          ],
        );
        final subscription = container.listen(provider, (_, _) {});
        await load(container, false);
        final cached = container.read(provider);
        expect(repository.calls[name], 1);
        subscription.close();
        // Simulate a route being removed, including Riverpod's disposal window.
        await container.pump();
        final nextVisit = container.listen(provider, (_, _) {});
        await load(container, false);
        expect(identical(container.read(provider), cached), isTrue);
        expect(repository.calls[name], 1);
        await load(container, true);
        expect(repository.calls[name], 2);
        expect(identical(container.read(provider), cached), isFalse);
        nextVisit.close();
      },
    );
  }

  checkCache(
    'home',
    homeControllerProvider,
    (container, refresh) => container
        .read(homeControllerProvider.notifier)
        .loadDoctors(refresh: refresh),
  );
  checkCache(
    'doctors',
    doctorsControllerProvider,
    (container, refresh) => container
        .read(doctorsControllerProvider.notifier)
        .load(refresh: refresh),
  );
  checkCache(
    'appointments',
    appointmentsControllerProvider,
    (container, refresh) => container
        .read(appointmentsControllerProvider.notifier)
        .load(refresh: refresh),
  );
  checkCache(
    'profile',
    profileControllerProvider,
    (container, refresh) => container
        .read(profileControllerProvider.notifier)
        .load(refresh: refresh),
  );

  test(
    'private caches clear after logout even without mounted screens',
    () async {
      final sessions = StreamController<AuthUser?>();
      addTearDown(sessions.close);
      final repository = _Repository();
      final container = ProviderContainer.test(
        overrides: [
          appointmentsRepositoryProvider.overrideWithValue(repository),
          doctorsRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(repository),
          authSessionProvider.overrideWith((ref) => sessions.stream),
        ],
      );
      final profileSubscription = container.listen(
        profileControllerProvider,
        (_, _) {},
      );
      final appointmentsSubscription = container.listen(
        appointmentsControllerProvider,
        (_, _) {},
      );
      sessions.add(const AuthUser(uid: 'first'));
      await Future<void>.delayed(Duration.zero);
      await container.pump();
      expect(container.read(profileControllerProvider).profile, isNotNull);
      expect(container.read(appointmentsControllerProvider).hasLoaded, isTrue);
      profileSubscription.close();
      appointmentsSubscription.close();
      await container.pump();
      sessions.add(null);
      await Future<void>.delayed(Duration.zero);
      await container.pump();
      expect(container.read(profileControllerProvider).profile, isNull);
      expect(container.read(appointmentsControllerProvider).hasLoaded, isFalse);
      sessions.add(const AuthUser(uid: 'second'));
      await Future<void>.delayed(Duration.zero);
      await container.pump();
      expect(repository.calls['profile'], 2);
      expect(repository.calls['appointments'], 2);
    },
  );

  testWidgets(
    'Find a Doctor reuses cached results on reentry and refreshes on swipe',
    (tester) async {
      final repository = _Repository();
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
          child: Sizer(
            builder: (_, _, _) => MaterialApp(
              theme: AppTheme.light,
              home: ValueListenableBuilder<bool>(
                valueListenable: visible,
                builder: (_, show, _) =>
                    show ? const FindDoctorScreen() : const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.calls['doctors'], 1);
      visible.value = false;
      await tester.pumpAndSettle();
      visible.value = true;
      await tester.pumpAndSettle();
      expect(repository.calls['doctors'], 1);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(repository.calls['doctors'], 2);
      expect(find.text('Doctor 2'), findsOneWidget);
      repository.failDoctors = true;
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(find.text('Refresh failed'), findsOneWidget);
      expect(find.text('Doctor 2'), findsOneWidget);
    },
  );

  test('a failed refresh retains the last successful doctor result', () async {
    final repository = _Repository();
    final container = ProviderContainer.test(
      overrides: [doctorsRepositoryProvider.overrideWithValue(repository)],
    );
    final controller = container.read(doctorsControllerProvider.notifier);
    await controller.load();
    final cached = container.read(doctorsControllerProvider).doctors;
    repository.failDoctors = true;
    await controller.load(refresh: true);
    expect(container.read(doctorsControllerProvider).doctors, same(cached));
    expect(container.read(doctorsControllerProvider).errorMessage, isNotNull);
    await controller.load();
    expect(repository.calls['doctors'], 2);
  });
}

class _Repository
    implements
        HomeRepository,
        DoctorsRepository,
        AppointmentsRepository,
        ProfileRepository {
  final Map<String, int> calls = {};
  bool failDoctors = false;
  void _count(String name) =>
      calls.update(name, (value) => value + 1, ifAbsent: () => 1);

  @override
  Future<List<FeaturedDoctor>> getFeaturedDoctors() async {
    _count('home');
    // An empty successful response is cached too.
    return [];
  }

  @override
  Future<List<Doctor>> getDoctors() async {
    _count('doctors');
    if (failDoctors) throw const DoctorsException('Refresh failed');
    return [Doctor(id: 'doctor', name: 'Doctor ${calls['doctors']}')];
  }

  @override
  Future<List<Appointment>> getAppointments() async {
    _count('appointments');
    return [];
  }

  @override
  Future<UserProfile> getProfile() async {
    _count('profile');
    return UserProfile(displayName: 'Patient ${calls['profile']}');
  }

  @override
  Future<Appointment> updateStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) => throw UnimplementedError();
}
