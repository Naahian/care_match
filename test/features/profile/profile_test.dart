import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:care_match/features/profile/domain/entities/user_profile.dart';
import 'package:care_match/features/profile/domain/repositories/profile_repository.dart';
import 'package:care_match/features/profile/presentation/controllers/profile_controller.dart';
import 'package:care_match/features/profile/presentation/controllers/profile_state.dart';
import 'package:care_match/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:care_match/features/profile/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _Adapter adapter;
  late Dio dio;
  late ProfileRepositoryImpl repository;

  setUp(() {
    adapter = _Adapter();
    dio = createDioClient(
      baseUrl: 'https://example.com/api/v1',
      readAccessToken: () async => 'test-token',
      adapter: adapter,
    );
    repository = ProfileRepositoryImpl(dio: dio);
  });
  tearDown(() => dio.close());

  test('loads the authenticated profile and maps backend fields', () async {
    adapter.body = {
      'status': 200,
      'msg': 'Success',
      'data': {
        'display_name': ' Jane Doe ',
        'email': 'jane@example.com',
        'date_of_birth': '1996-03-14',
        'gender': 'Female',
        'blood_group': 'O+',
        'preferred_language': 'English',
        'photo_url': 'https://example.com/avatar.png',
      },
    };
    final profile = await repository.getProfile();
    expect(adapter.request!.uri.path, '/api/v1/users/me');
    expect(adapter.request!.headers['Authorization'], 'Bearer test-token');
    expect(profile.displayName, 'Jane Doe');
    expect(profile.email, 'jane@example.com');
    expect(profile.dateOfBirth, DateTime(1996, 3, 14));
    expect(profile.gender, 'Female');
    expect(profile.bloodGroup, 'O+');
    expect(profile.preferredLanguage, 'English');
    expect(profile.photoUrl, 'https://example.com/avatar.png');
  });

  test(
    'missing or invalid fields remain unknown without invented values',
    () async {
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': {
          'display_name': ' ',
          'email': 42,
          'date_of_birth': '1996-02-31',
          'photo_url': 'invalid',
        },
      };
      final profile = await repository.getProfile();
      expect(ProfileState.display(profile.displayName), 'unknown');
      expect(ProfileState.display(profile.email), 'unknown');
      expect(profile.photoUrl, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(
        ProfileState(profile: profile).ageLabel(DateTime(2026)),
        'unknown',
      );
    },
  );

  test(
    'malformed responses and HTTP failures propagate domain failures',
    () async {
      adapter.body = ['invalid'];
      await expectLater(
        repository.getProfile(),
        throwsA(isA<ProfileException>()),
      );
      adapter.status = 401;
      await expectLater(
        repository.getProfile(),
        throwsA(
          isA<ProfileException>().having((e) => e.statusCode, 'status', 401),
        ),
      );
    },
  );

  test('API failure inside HTTP success preserves the domain status', () async {
    adapter.body = {'status': 401, 'msg': 'Unauthorized', 'data': null};
    await expectLater(
      repository.getProfile(),
      throwsA(
        isA<ProfileException>().having((e) => e.statusCode, 'status', 401),
      ),
    );
    adapter.body = {'status': 200, 'msg': 'Success', 'data': []};
    await expectLater(
      repository.getProfile(),
      throwsA(isA<ProfileException>()),
    );
  });

  test('age accounts for birthdays and rejects future dates', () {
    final state = ProfileState(
      profile: UserProfile(dateOfBirth: DateTime(2000, 3, 14)),
    );
    expect(state.ageLabel(DateTime(2026, 3, 13)), '25 years old');
    expect(state.ageLabel(DateTime(2026, 3, 14)), '26 years old');
    expect(state.ageLabel(DateTime(1999)), 'unknown');
  });

  test('controller handles failure, retry and duplicate requests', () async {
    final fake = _Repository();
    final container = ProviderContainer.test(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fake),
        authSessionProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    container.listen(profileControllerProvider, (_, _) {});
    final controller = container.read(profileControllerProvider.notifier);
    final request = controller.load();
    await controller.load();
    expect(fake.calls, 1);
    expect(container.read(profileControllerProvider).isLoading, isTrue);
    fake.result.completeError(const ProfileException('Please retry.'));
    await request;
    expect(
      container.read(profileControllerProvider).errorMessage,
      'Please retry.',
    );
    fake.result = Completer<UserProfile>();
    final retry = controller.load();
    fake.result.complete(const UserProfile(displayName: 'Jane'));
    await retry;
    expect(
      container.read(profileControllerProvider).profile!.displayName,
      'Jane',
    );
    expect(container.read(profileControllerProvider).errorMessage, isNull);
  });

  test('sign-out clears the profile and ignores an older request', () async {
    final session = StreamController<AuthUser?>();
    addTearDown(session.close);
    final fake = _Repository();
    final container = ProviderContainer.test(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fake),
        authSessionProvider.overrideWith((ref) => session.stream),
      ],
    );
    container.listen(profileControllerProvider, (_, _) {});
    session.add(const AuthUser(uid: 'first'));
    await Future<void>.delayed(Duration.zero);
    expect(fake.calls, 1);
    session.add(null);
    await Future<void>.delayed(Duration.zero);
    fake.result.complete(const UserProfile(displayName: 'Old user'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(profileControllerProvider).profile, isNull);
    expect(container.read(profileControllerProvider).isLoading, isFalse);
  });

  testWidgets('screen displays loaded values and unknown missing details', (
    tester,
  ) async {
    final fake = _Repository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fake),
          authSessionProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: MyProfileScreen()),
      ),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    fake.result.complete(
      const UserProfile(displayName: 'Jane Doe', email: 'jane@example.com'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('unknown'), findsWidgets);
    expect(find.text('Sarah Johnson'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}

class _Repository implements ProfileRepository {
  Completer<UserProfile> result = Completer<UserProfile>();
  int calls = 0;

  @override
  Future<UserProfile> getProfile() {
    calls++;
    return result.future;
  }
}

class _Adapter implements HttpClientAdapter {
  Object? body = <String, dynamic>{};
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
