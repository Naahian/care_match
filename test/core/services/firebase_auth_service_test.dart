import 'package:care_match/core/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeFirebaseAuth auth;
  late FirebaseAuthService service;

  setUp(() {
    auth = _FakeFirebaseAuth();
    service = FirebaseAuthService(auth: auth);
  });

  test('trims the email while preserving password whitespace', () async {
    await service.signInWithEmailAndPassword(
      email: ' patient@example.com ',
      password: ' secret ',
    );
    expect(auth.email, 'patient@example.com');
    expect(auth.password, ' secret ');
  });

  test('preserves Firebase errors for UI handling', () async {
    final error = FirebaseAuthException(code: 'invalid-credential');
    auth.signInError = error;
    await expectLater(
      service.signInWithEmailAndPassword(email: 'a@b.com', password: 'secret'),
      throwsA(same(error)),
    );
  });

  test(
    'signed-out token lookup is null and user actions fail explicitly',
    () async {
      expect(await service.getIdToken(), isNull);
      expect(
        service.sendEmailVerification,
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'no-current-user',
          ),
        ),
      );
    },
  );

  test('SMS sign-in combines the verification ID and trimmed code', () async {
    await service.signInWithSmsCode(
      verificationId: 'verification-id',
      smsCode: ' 123456 ',
    );
    final credential = auth.credential! as PhoneAuthCredential;
    expect(credential.verificationId, 'verification-id');
    expect(credential.smsCode, '123456');
  });
}

class _FakeFirebaseAuth implements FirebaseAuth {
  String? email;
  String? password;
  AuthCredential? credential;
  FirebaseAuthException? signInError;

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    this.email = email;
    this.password = password;
    if (signInError != null) throw signInError!;
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    this.credential = credential;
    return _FakeUserCredential();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
