import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:care_match/features/profile/domain/entities/profile_photo.dart';
import 'package:care_match/features/profile/domain/repositories/profile_photo_picker.dart';

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
import 'package:care_match/features/profile/presentation/screens/set_up_profile_screen.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  final photo = ProfilePhoto(
    bytes: base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGNgYPgPAAEDAQAIicLsAAAAAElFTkSuQmCC',
    ),
    filename: 'avatar.png',
  );

  test('sends photo bytes as multipart without a client photo URL', () async {
    adapter.body = {
      'status': 200,
      'msg': 'Success',
      'data': {'photo_url': 'https://project.supabase.co/photo.jpg'},
    };
    final result = await repository.updateProfile(
      ProfileUpdate(
        displayName: 'Jane',
        phoneNumber: '',
        photo: photo,
        dateOfBirth: DateTime(1996, 3, 14),
      ),
    );
    expect(adapter.request!.contentType, startsWith('multipart/form-data'));
    final body = adapter.request!.data as FormData;
    expect(Map.fromEntries(body.fields), {
      'display_name': 'Jane',
      'phone_number': '',
      'remove_photo': 'false',
      'date_of_birth': '1996-03-14',
      'gender': '',
      'blood_group': '',
    });
    expect(body.files.single.key, 'photo');
    expect(body.files.single.value.filename, 'avatar.png');
    expect(body.files.single.value.length, photo.bytes.length);
    expect(
      latin1.decode(adapter.sentBody!),
      contains(latin1.decode(photo.bytes)),
    );
    expect(result.photoUrl, 'https://project.supabase.co/photo.jpg');
  });

  test(
    'editing text without a selected photo preserves the existing image',
    () async {
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': {'photo_url': 'https://example.com/avatar.png'},
      };
      await repository.updateProfile(
        const ProfileUpdate(displayName: 'Jane', phoneNumber: ''),
      );
      final form = adapter.request!.data as FormData;
      final body = Map.fromEntries(form.fields);
      expect(form.files, isEmpty);
      expect(body.containsKey('photo'), isFalse);
      expect(body.containsKey('photo_url'), isFalse);
      expect(body['remove_photo'], 'false');
    },
  );

  testWidgets('photo picker previews selected bytes and sends them on save', (
    tester,
  ) async {
    final fake = _Repository()
      ..result.complete(const UserProfile(displayName: 'Jane'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fake),
          profilePhotoPickerProvider.overrideWithValue(_PhotoPicker(photo)),
          authSessionProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: SetUpProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Profile photo URL'), findsNothing);
    await tester.ensureVisible(find.text('Choose photo'));
    await tester.tap(find.text('Choose photo'));
    await tester.pumpAndSettle();
    expect(tester.widget<Image>(find.byType(Image)).image, isA<MemoryImage>());
    await tester.ensureVisible(find.text('Save Edits'));
    await tester.tap(find.text('Save Edits'));
    await tester.pump();
    expect(fake.update!.photo, same(photo));
    expect(fake.update!.removePhoto, isFalse);
    fake.saved.completeError(const ProfileException('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.ensureVisible(find.text('Remove photo'));
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();
    fake.saved = Completer<UserProfile>();
    await tester.ensureVisible(find.text('Save Edits'));
    await tester.tap(find.text('Save Edits'));
    await tester.pump();
    expect(fake.update!.photo, isNull);
    expect(fake.update!.removePhoto, isTrue);
    fake.saved.completeError(const ProfileException('Try again'));
    await tester.pumpAndSettle();
  });

  testWidgets('cancelling photo selection leaves the current image unchanged', (
    tester,
  ) async {
    final fake = _Repository()
      ..result.complete(const UserProfile(displayName: 'Jane'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fake),
          profilePhotoPickerProvider.overrideWithValue(_PhotoPicker(null)),
          authSessionProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: SetUpProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Choose photo'));
    await tester.tap(find.text('Choose photo'));
    await tester.pumpAndSettle();
    expect(find.text('Remove photo'), findsNothing);
    await tester.ensureVisible(find.text('Save Edits'));
    await tester.tap(find.text('Save Edits'));
    await tester.pump();
    expect(fake.update!.photo, isNull);
    expect(fake.update!.removePhoto, isFalse);
    fake.saved.completeError(const ProfileException('Try again'));
    await tester.pumpAndSettle();
  });

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
    'updates supported fields with PATCH and explicitly clears empty values',
    () async {
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': {
          'display_name': 'New name',
          'phone_number': '+8801712345678',
          'photo_url': null,
        },
      };
      final profile = await repository.updateProfile(
        const ProfileUpdate(
          displayName: ' New name ',
          phoneNumber: ' +8801712345678 ',
          removePhoto: true,
        ),
      );
      expect(adapter.request!.method, 'PATCH');
      expect(adapter.request!.uri.path, '/api/v1/users/me');
      expect(adapter.request!.headers['Authorization'], 'Bearer test-token');
      expect(Map.fromEntries((adapter.request!.data as FormData).fields), {
        'display_name': 'New name',
        'phone_number': '+8801712345678',
        'remove_photo': 'true',
        'date_of_birth': '',
        'gender': '',
        'blood_group': '',
      });
      expect(profile.displayName, 'New name');
      expect(profile.phoneNumber, '+8801712345678');
      expect(profile.photoUrl, isNull);
    },
  );

  test(
    'saves personal details using a date without timezone conversion',
    () async {
      adapter.body = {
        'status': 200,
        'msg': 'Success',
        'data': {
          'date_of_birth': '1996-03-14',
          'gender': 'Female',
          'blood_group': 'O+',
        },
      };
      final profile = await repository.updateProfile(
        ProfileUpdate(
          displayName: 'Jane',
          phoneNumber: '',
          dateOfBirth: DateTime.utc(1996, 3, 14),
          gender: ' Female ',
          bloodGroup: ' O+ ',
        ),
      );
      expect(Map.fromEntries((adapter.request!.data as FormData).fields), {
        'display_name': 'Jane',
        'phone_number': '',
        'remove_photo': 'false',
        'date_of_birth': '1996-03-14',
        'gender': 'Female',
        'blood_group': 'O+',
      });
      expect(profile.dateOfBirth, DateTime(1996, 3, 14));
      expect(profile.gender, 'Female');
      expect(profile.bloodGroup, 'O+');
    },
  );

  test('invalid profile edits never reach the network', () async {
    for (final update in [
      ProfileUpdate(
        displayName: '',
        phoneNumber: '',
        dateOfBirth: DateTime.now().add(const Duration(days: 1)),
      ),
      ProfileUpdate(displayName: 'x' * 129, phoneNumber: ''),
      const ProfileUpdate(displayName: '', phoneNumber: '01712345678'),
      ProfileUpdate(
        displayName: '',
        phoneNumber: '',
        photo: ProfilePhoto(bytes: Uint8List(0), filename: 'empty.jpg'),
      ),
    ]) {
      await expectLater(
        Future.sync(() => repository.updateProfile(update)),
        throwsA(isA<ProfileException>()),
      );
    }
    expect(adapter.request, isNull);
  });

  test('profile update failures preserve their cause and status', () async {
    adapter.status = 422;
    await expectLater(
      repository.updateProfile(
        const ProfileUpdate(displayName: 'Jane', phoneNumber: ''),
      ),
      throwsA(
        isA<ProfileException>()
            .having((error) => error.statusCode, 'status', 422)
            .having((error) => error.cause, 'cause', isA<DioException>()),
      ),
    );
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

  test(
    'save prevents duplicate requests, retains the profile on failure and retries',
    () async {
      final fake = _Repository();
      final container = ProviderContainer.test(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fake),
          authSessionProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      container.listen(profileControllerProvider, (_, _) {});
      final controller = container.read(profileControllerProvider.notifier);
      fake.result.complete(const UserProfile(displayName: 'Before'));
      await controller.load();
      const update = ProfileUpdate(displayName: 'After', phoneNumber: '');
      final saving = controller.save(update);
      expect(container.read(profileControllerProvider).isSaving, isTrue);
      expect(await controller.save(update), isFalse);
      await controller.load(refresh: true);
      expect(fake.calls, 1);
      expect(fake.saves, 1);
      fake.saved.completeError(const ProfileException('Try again'));
      expect(await saving, isFalse);
      expect(
        container.read(profileControllerProvider).profile!.displayName,
        'Before',
      );
      expect(container.read(profileControllerProvider).saveError, 'Try again');
      fake.saved = Completer<UserProfile>();
      final retry = controller.save(update);
      fake.saved.complete(const UserProfile(displayName: 'After'));
      expect(await retry, isTrue);
      expect(
        container.read(profileControllerProvider).profile!.displayName,
        'After',
      );
      expect(container.read(profileControllerProvider).saveError, isNull);
      expect(container.read(profileControllerProvider).isSaving, isFalse);
    },
  );

  test('sign-out clears an in-flight save and ignores its result', () async {
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
    fake.result.complete(const UserProfile(displayName: 'Before'));
    await Future<void>.delayed(Duration.zero);
    final saving = container
        .read(profileControllerProvider.notifier)
        .save(const ProfileUpdate(displayName: 'After', phoneNumber: ''));
    session.add(null);
    await Future<void>.delayed(Duration.zero);
    fake.saved.complete(const UserProfile(displayName: 'After'));
    expect(await saving, isFalse);
    expect(container.read(profileControllerProvider).profile, isNull);
    expect(container.read(profileControllerProvider).isSaving, isFalse);
  });

  testWidgets(
    'edit prefills values, preserves failed edits and updates the profile after retry',
    (tester) async {
      final fake = _Repository();
      fake.result.complete(
        UserProfile(
          displayName: 'Jane',
          phoneNumber: '+8801712345678',
          dateOfBirth: DateTime(1996, 3, 14),
          gender: 'Female',
          bloodGroup: 'O+',
        ),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: AppRoutes.home,
            builder: (_, _) => const MyProfileScreen(),
          ),
          GoRoute(
            path: '/edit',
            name: AppRoutes.setUpProfile,
            builder: (_, _) => const SetUpProfileScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(fake),
            authSessionProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit profile'));
      await tester.pumpAndSettle();
      expect(find.text('Jane'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        '+8801712345678',
      );
      await tester.enterText(find.byType(TextFormField).first, 'Updated Jane');
      expect(find.text('1996-03-14'), findsOneWidget);
      final birthField = find.byType(TextFormField).at(2);
      await tester.ensureVisible(birthField);
      await tester.tap(birthField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('1996-03-15'), findsOneWidget);
      final genderField = find.byType(DropdownButtonFormField<String>).at(0);
      await tester.ensureVisible(genderField);
      await tester.tap(genderField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();
      final bloodField = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.ensureVisible(bloodField);
      await tester.tap(bloodField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('AB-').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save Edits'));
      await tester.tap(find.text('Save Edits'));
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      fake.saved.completeError(const ProfileException('Please retry'));
      await tester.pumpAndSettle();
      expect(find.text('Please retry'), findsOneWidget);
      expect(find.text('Updated Jane'), findsOneWidget);
      expect(find.byType(SetUpProfileScreen), findsOneWidget);
      fake.saved = Completer<UserProfile>();
      await tester.ensureVisible(find.text('Save Edits'));
      await tester.tap(find.text('Save Edits'));
      await tester.pump();
      expect(fake.update!.displayName, 'Updated Jane');
      expect(fake.update!.dateOfBirth, DateTime(1996, 3, 15));
      expect(fake.update!.gender, 'Male');
      expect(fake.update!.bloodGroup, 'AB-');
      fake.saved.complete(
        UserProfile(
          displayName: 'Updated Jane',
          dateOfBirth: fake.update!.dateOfBirth,
          gender: fake.update!.gender,
          bloodGroup: fake.update!.bloodGroup,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SetUpProfileScreen), findsNothing);
      expect(find.text('Updated Jane'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('AB-'), findsOneWidget);
      // Initial profile load, navigation role lookup, and role refresh after save.
      expect(fake.calls, 3);
    },
  );

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
  int saves = 0;
  ProfileUpdate? update;
  Completer<UserProfile> saved = Completer<UserProfile>();

  @override
  Future<UserProfile> updateProfile(ProfileUpdate update) {
    saves++;
    this.update = update;
    return saved.future;
  }

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
  Uint8List? sentBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (requestStream != null) {
      final bytes = BytesBuilder();
      await for (final chunk in requestStream) {
        bytes.add(chunk);
      }
      sentBody = bytes.takeBytes();
    }
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

class _PhotoPicker implements ProfilePhotoPicker {
  const _PhotoPicker(this.photo);
  final ProfilePhoto? photo;
  @override
  Future<ProfilePhoto?> pickPhoto() async => photo;
}
