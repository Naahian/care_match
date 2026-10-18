import 'dart:convert';

import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/auth/domain/entities/doctor_registration_details.dart';
import 'package:care_match/features/auth/domain/entities/registration_exception.dart';
import 'package:dio/dio.dart';
import 'package:care_match/core/services/firebase_auth_service.dart';
import 'package:care_match/core/services/storage_service.dart';
import 'package:care_match/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:care_match/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:care_match/features/auth/data/models/auth_user_model.dart';
import 'package:care_match/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeFirebaseAuth firebase;
  late StorageService storage;
  late AuthRepositoryImpl repository;
  late Dio dio;
  late _RegistrationAdapter adapter;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    firebase = _FakeFirebaseAuth();
    storage = StorageService();
    adapter = _RegistrationAdapter();
    dio = createDioClient(
      baseUrl: 'https://api.example.com',
      readAccessToken: () async =>
          throw StateError('Registration must be public'),
      adapter: adapter,
    );
    addTearDown(() => dio.close(force: true));
    repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(
        authService: FirebaseAuthService(auth: firebase),
        readDio: () => dio,
      ),
      localDataSource: AuthLocalDataSource(storage: storage),
    );
  });

  test(
    'email sign-in caches the Firebase profile without credentials',
    () async {
      final user = await repository.signInWithEmailAndPassword(
        email: ' patient@example.com ',
        password: ' secret ',
      );
      expect(user.uid, 'patient-1');
      expect(user.email, 'patient@example.com');
      expect(firebase.email, 'patient@example.com');
      expect(firebase.password, ' secret ');
      expect((await repository.getCachedUser())?.uid, user.uid);
      final cached = await storage.readMap(
        key: AuthLocalDataSource.userCacheKey,
      );
      expect(cached, user.toJson());
      expect(cached!.containsKey('password'), isFalse);
      expect(cached.containsKey('token'), isFalse);
    },
  );

  test(
    'patient registration uses the public API without Firebase or caching',
    () async {
      for (final status in [200, 201, 202]) {
        adapter.status = status;
        adapter.body = jsonEncode({
          'status': status,
          'msg': 'Account created',
          'data': null,
        });
        await repository.createPatient(
          email: ' patient@example.com ',
          password: ' secret ',
          displayName: ' Patient ',
        );
        final request = adapter.requests.last;
        expect(request.method, 'POST');
        expect(request.path, '/users/patient');
        expect(request.data, {
          'email': 'patient@example.com',
          'password': ' secret ',
          'display_name': 'Patient',
        });
        expect(request.headers.containsKey('Authorization'), isFalse);
      }
      expect(firebase.email, isNull);
      expect(firebase.user, isNull);
      expect(
        await storage.containsKey(key: AuthLocalDataSource.userCacheKey),
        isFalse,
      );
    },
  );

  test(
    'registration rejects failed or malformed envelopes on HTTP success',
    () async {
      adapter.status = 200;
      adapter.body = jsonEncode({
        'status': 409,
        'msg': 'Conflict',
        'data': null,
      });
      await expectLater(
        repository.createPatient(
          email: 'patient@example.com',
          password: 'secret',
          displayName: 'Patient',
        ),
        throwsA(
          isA<RegistrationException>().having(
            (e) => e.statusCode,
            'status',
            409,
          ),
        ),
      );
      adapter.body = '{}';
      await expectLater(
        repository.createPatient(
          email: 'patient@example.com',
          password: 'secret',
          displayName: 'Patient',
        ),
        throwsA(isA<RegistrationException>()),
      );
    },
  );

  test(
    'doctor registration serializes every nested field to its API name',
    () async {
      await repository.createDoctor(
        email: 'doctor@example.com',
        password: 'secret',
        displayName: 'Doctor',
        details: DoctorRegistrationDetails(
          phone: '+8801700000000',
          clinics: const [
            DoctorClinic(name: 'Clinic A', location: 'Dhaka'),
            DoctorClinic(name: 'Clinic B', location: 'Sylhet'),
          ],
          specialties: ['Cardiology'],
          degrees: ['MBBS', 'MD'],
          timeAvailable: const [
            DoctorTimeRange(start: '09:00:00', end: '17:00:00'),
          ],
          daysAvailable: ['Monday'],
        ),
      );
      final request = adapter.requests.single;
      expect(request.path, '/users/doctor');
      expect(request.data, {
        'email': 'doctor@example.com',
        'password': 'secret',
        'display_name': 'Doctor',
        'phone': '+8801700000000',
        'clinics': [
          {'name': 'Clinic A', 'location': 'Dhaka'},
          {'name': 'Clinic B', 'location': 'Sylhet'},
        ],
        'specialties': ['Cardiology'],
        'degrees': ['MBBS', 'MD'],
        'time_available': [
          {'start': '09:00:00', 'end': '17:00:00'},
        ],
        'days_available': ['Monday'],
      });
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(firebase.email, isNull);
    },
  );

  test(
    'validation errors expose field messages and omit sensitive input/context',
    () async {
      adapter.status = 422;
      adapter.body = jsonEncode({
        'status': 422,
        'msg': 'Validation failed',
        'data': {
          'detail': [
            {
              'loc': ['body', 'email'],
              'msg': 'Invalid email address',
              'input': 'private-input',
              'ctx': {'private': 'secret'},
            },
            {
              'loc': ['body', 'password'],
              'msg': 'Rejected secret',
              'input': 'secret',
            },
          ],
        },
      });
      await expectLater(
        repository.createPatient(
          email: 'invalid',
          password: 'secret',
          displayName: 'Patient',
        ),
        throwsA(
          isA<RegistrationException>()
              .having((error) => error.statusCode, 'status', 422)
              .having(
                (error) => error.message,
                'message',
                'email: Invalid email address\nPassword does not meet the requirements.',
              ),
        ),
      );
      expect(firebase.user, isNull);
      expect(await repository.getCachedUser(), isNull);
    },
  );

  test('non-validation server failures do not leak raw error bodies', () async {
    for (final status in [302, 400, 401, 409, 429, 500]) {
      adapter.status = status;
      adapter.body = 'private server details';
      await expectLater(
        repository.createPatient(
          email: 'a@b.com',
          password: 'secret',
          displayName: 'Patient',
        ),
        throwsA(
          isA<RegistrationException>()
              .having((error) => error.statusCode, 'status', status)
              .having(
                (error) => error.message,
                'message',
                isNot(contains('private')),
              ),
        ),
      );
    }
  });

  test(
    'failed sign-in preserves the Firebase error and existing cache',
    () async {
      final error = FirebaseAuthException(code: 'invalid-credential');
      firebase.error = error;
      await storage.writeMap(
        key: AuthLocalDataSource.userCacheKey,
        value: {'uid': 'old'},
      );
      await expectLater(
        repository.signInWithEmailAndPassword(
          email: 'a@b.com',
          password: 'bad',
        ),
        throwsA(same(error)),
      );
      expect(await storage.readMap(key: AuthLocalDataSource.userCacheKey), {
        'uid': 'old',
      });
    },
  );

  test('automatic phone credentials can be signed in and cached', () async {
    final credential = PhoneAuthProvider.credential(
      verificationId: 'verification-id',
      smsCode: '123456',
    );
    await repository.signInWithCredential(credential);
    expect(firebase.credential, same(credential));
    expect((await repository.getCachedUser())?.uid, 'patient-1');
  });

  test(
    'web phone confirmation caches the user after confirming the code',
    () async {
      final confirmation = _FakeConfirmationResult(firebase);
      await repository.confirmPhoneNumber(
        confirmationResult: confirmation,
        smsCode: ' 123456 ',
      );
      expect(confirmation.smsCode, '123456');
      expect((await repository.getCachedUser())?.uid, 'patient-1');
    },
  );

  test(
    'cache never establishes a session or exposes a different user',
    () async {
      for (final currentUser in [null, _FakeUser(uid: 'different-user')]) {
        firebase.user = currentUser;
        await storage.writeMap(
          key: AuthLocalDataSource.userCacheKey,
          value: {'uid': 'old'},
        );
        expect(await repository.getCachedUser(), isNull);
        expect(
          await storage.containsKey(key: AuthLocalDataSource.userCacheKey),
          isFalse,
        );
      }
    },
  );

  test('malformed cached profiles are discarded', () async {
    for (final value in [
      'broken-json',
      '[]',
      '{}',
      '{"uid":123}',
      '{"uid":"a","emailVerified":"yes"}',
    ]) {
      await storage.writeString(
        key: AuthLocalDataSource.userCacheKey,
        value: value,
      );
      expect(await repository.getCachedUser(), isNull);
      expect(
        await storage.containsKey(key: AuthLocalDataSource.userCacheKey),
        isFalse,
      );
    }
  });

  test('sign-out deletes only the auth profile', () async {
    await repository.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'secret',
    );
    await storage.writeString(key: 'preferences', value: 'keep');
    await repository.signOut();
    expect(repository.currentUser, isNull);
    expect(
      await storage.readMap(key: AuthLocalDataSource.userCacheKey),
      isNull,
    );
    expect(await storage.readString(key: 'preferences'), 'keep');
  });

  test('failed Firebase sign-out keeps the active user and cache', () async {
    await repository.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'secret',
    );
    final error = FirebaseAuthException(code: 'network-request-failed');
    firebase.error = error;
    await expectLater(repository.signOut(), throwsA(same(error)));
    expect(repository.currentUser?.uid, 'patient-1');
    expect((await repository.getCachedUser())?.uid, 'patient-1');
  });

  test('auth streams map Firebase users and signed-out events', () async {
    expect(await repository.authStateChanges.first, isNull);
    await repository.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'secret',
    );
    expect((await repository.authStateChanges.first)?.uid, 'patient-1');
    expect((await repository.idTokenChanges.first)?.uid, 'patient-1');
  });

  test(
    'reload refreshes the profile and verification status in storage',
    () async {
      firebase.user = _FakeUser();
      final user = await repository.reloadUser();
      expect(user!.emailVerified, isTrue);
      expect((await repository.getCachedUser())?.emailVerified, isTrue);
    },
  );

  test('token reads use Firebase and forward forced refresh', () async {
    expect(await repository.getIdToken(), isNull);
    firebase.user = _FakeUser();
    expect(await repository.getIdToken(forceRefresh: true), 'fresh-token');
    expect(firebase.user!.forceRefresh, isTrue);
    expect(
      await storage.containsKey(key: AuthLocalDataSource.userCacheKey),
      isFalse,
    );
  });

  test('storage errors propagate without undoing Firebase sign-in', () async {
    final error = PlatformException(code: 'storage-unavailable');
    repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(
        authService: FirebaseAuthService(auth: firebase),
        readDio: () => dio,
      ),
      localDataSource: AuthLocalDataSource(storage: _FailingStorage(error)),
    );
    await expectLater(
      repository.signInWithEmailAndPassword(
        email: 'a@b.com',
        password: 'secret',
      ),
      throwsA(same(error)),
    );
    expect(repository.currentUser?.uid, 'patient-1');
  });

  test('a credential without a user fails without caching', () async {
    firebase.returnMissingUser = true;
    await expectLater(
      repository.signInWithEmailAndPassword(
        email: 'a@b.com',
        password: 'secret',
      ),
      throwsA(
        isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'missing-user',
        ),
      ),
    );
    expect(
      await storage.containsKey(key: AuthLocalDataSource.userCacheKey),
      isFalse,
    );
  });

  test('user model JSON round-trip preserves all profile fields', () {
    const model = AuthUserModel(
      uid: 'patient-1',
      email: 'a@b.com',
      phoneNumber: '+8801700000000',
      displayName: 'Patient',
      photoUrl: 'https://example.com/photo.jpg',
      emailVerified: true,
      isAnonymous: false,
    );
    expect(AuthUserModel.fromJson(model.toJson()).toJson(), model.toJson());
  });

  test(
    'phone linking preserves the email account and updates its cache',
    () async {
      await repository.signInWithEmailAndPassword(
        email: 'patient@example.com',
        password: 'secret',
      );
      final credential = PhoneAuthProvider.credential(
        verificationId: 'id',
        smsCode: '123456',
      );
      final originalUid = repository.currentUser!.uid;
      final user = await repository.linkWithCredential(credential);
      expect(user.uid, originalUid);
      expect(user.email, 'patient@example.com');
      expect(firebase.user!.linkedCredential, same(credential));
      expect((await repository.getCachedUser())!.uid, originalUid);
    },
  );

  test('display name updates are refreshed and cached', () async {
    await repository.signInWithEmailAndPassword(
      email: 'patient@example.com',
      password: 'secret',
    );
    final user = await repository.updateDisplayName(' Test Patient ');
    expect(user.displayName, 'Test Patient');
    expect((await repository.getCachedUser())!.displayName, 'Test Patient');
  });
}

class _RegistrationAdapter implements HttpClientAdapter {
  int status = 201;
  String body = '{"status":201,"msg":"Account created","data":null}';
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeUser? user;
  FirebaseAuthException? error;
  AuthCredential? credential;
  String? email;
  String? password;
  bool returnMissingUser = false;

  @override
  User? get currentUser => user;
  @override
  Stream<User?> authStateChanges() => Stream.value(user);
  @override
  Stream<User?> idTokenChanges() => Stream.value(user);

  UserCredential _authenticate() {
    if (error != null) throw error!;
    user = returnMissingUser ? null : _FakeUser();
    return _FakeUserCredential(user);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    this.email = email;
    this.password = password;
    return _authenticate();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    this.credential = credential;
    return _authenticate();
  }

  @override
  Future<void> signOut() async {
    if (error != null) throw error!;
    user = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser({this.uid = 'patient-1'});
  @override
  final String uid;
  @override
  String? get email => 'patient@example.com';
  @override
  String? get phoneNumber => '+8801700000000';
  @override
  String? displayName = 'Patient';
  AuthCredential? linkedCredential;
  @override
  Future<void> updateDisplayName(String? name) async {
    displayName = name;
  }

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    linkedCredential = credential;
    return _FakeUserCredential(this);
  }

  @override
  String? get photoURL => null;
  @override
  bool emailVerified = false;
  @override
  bool get isAnonymous => false;
  bool? forceRefresh;
  @override
  Future<void> reload() async {
    emailVerified = true;
  }

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    this.forceRefresh = forceRefresh;
    return 'fresh-token';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  _FakeUserCredential(this.user);
  @override
  final User? user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConfirmationResult implements ConfirmationResult {
  _FakeConfirmationResult(this.firebase);
  final _FakeFirebaseAuth firebase;
  String? smsCode;
  @override
  Future<UserCredential> confirm(String verificationCode) async {
    smsCode = verificationCode;
    return firebase._authenticate();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingStorage extends StorageService {
  _FailingStorage(this.error);
  final PlatformException error;
  @override
  Future<void> writeMap({
    required String key,
    required Map<String, dynamic> value,
  }) async => throw error;
}
