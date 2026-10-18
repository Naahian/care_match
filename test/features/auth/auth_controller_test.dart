import 'dart:async';

import 'package:care_match/core/providers.dart';
import 'package:care_match/core/services/snackbar_service.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/domain/entities/doctor_registration_details.dart';
import 'package:care_match/features/auth/domain/entities/registration_exception.dart';
import 'package:care_match/features/auth/domain/repositories/auth_repository.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = AuthUser(
    uid: 'patient-1',
    email: 'patient@example.com',
    emailVerified: true,
  );
  late _FakeRepository repository;
  late _FakeSnackbar snackbar;
  late ProviderContainer container;
  late AuthController controller;

  setUp(() {
    repository = _FakeRepository();
    snackbar = _FakeSnackbar();
    container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        snackbarProvider.overrideWithValue(snackbar),
      ],
    );
    container.listen(authControllerProvider, (_, _) {});
    controller = container.read(authControllerProvider.notifier);
    addTearDown(repository.events.close);
  });

  AuthState state() => container.read(authControllerProvider);

  test('initial state is signed out and nullable fields can be cleared', () {
    expect(state().isAuthenticated, isFalse);
    expect(state().isLoading, isFalse);
    final populated = const AuthState(
      user: user,
      errorMessage: 'error',
      verificationId: 'id',
    );
    final cleared = populated.copyWith(
      user: null,
      errorMessage: null,
      verificationId: null,
    );
    expect(cleared.user, isNull);
    expect(cleared.errorMessage, isNull);
    expect(cleared.verificationId, isNull);
    expect(populated.copyWith().user, same(user));
  });

  test(
    'sign-in exposes progress and successful user with snackbar feedback',
    () async {
      repository.pendingSignIn = Completer<AuthUser>();
      final pending = controller.signIn(
        email: 'patient@example.com',
        password: 'secret',
      );
      expect(state().pendingAction, AuthAction.signIn);
      repository.pendingSignIn!.complete(user);
      expect(await pending, isTrue);
      expect(state().user, same(user));
      expect(state().isLoading, isFalse);
      expect(snackbar.successes, ['Logged in successfully.']);
    },
  );

  test(
    'duplicate requests do not call the repository or emit feedback',
    () async {
      repository.pendingSignIn = Completer<AuthUser>();
      final pending = controller.signIn(email: 'a@b.com', password: 'secret');
      expect(
        await controller.signIn(email: 'a@b.com', password: 'secret'),
        isFalse,
      );
      expect(repository.signInCalls, 1);
      repository.pendingSignIn!.complete(user);
      await pending;
      expect(snackbar.successes, hasLength(1));
    },
  );

  test(
    'Firebase errors become safe UI messages and the next attempt clears them',
    () async {
      repository.error = FirebaseAuthException(
        code: 'invalid-credential',
        message: 'private details',
      );
      expect(
        await controller.signIn(email: 'a@b.com', password: 'bad'),
        isFalse,
      );
      expect(state().errorMessage, 'The email or password is incorrect.');
      expect(snackbar.failures, [state().errorMessage]);
      expect(state().isLoading, isFalse);
      repository.error = null;
      expect(
        await controller.signIn(email: 'a@b.com', password: 'secret'),
        isTrue,
      );
      expect(state().errorMessage, isNull);
    },
  );

  test(
    'sign-up, reset password, and email verification use repository actions',
    () async {
      expect(
        await controller.signUp(
          email: 'a@b.com',
          password: 'secret',
          displayName: 'Patient',
        ),
        isTrue,
      );
      expect(state().isAuthenticated, isFalse);
      expect(repository.currentUser, isNull);
      expect(await controller.resetPassword(email: 'a@b.com'), isTrue);
      expect(repository.resetEmail, 'a@b.com');
      expect(await controller.sendEmailVerification(), isTrue);
      expect(repository.verificationEmailCalls, 1);
      expect(snackbar.infos, hasLength(2));
    },
  );

  test('unverified email sign-in sends a link and ends the session', () async {
    repository.pendingSignIn = Completer<AuthUser>()
      ..complete(const AuthUser(uid: 'unverified', email: 'a@b.com'));
    expect(
      await controller.signIn(email: 'a@b.com', password: 'secret'),
      isFalse,
    );
    expect(state().isAuthenticated, isFalse);
    expect(repository.currentUser, isNull);
    expect(repository.verificationEmailCalls, 1);
    expect(state().errorMessage, contains('Verify your email'));
  });

  test(
    'backend registration failure is shown without starting a session',
    () async {
      repository.error = const RegistrationException(
        'email: Invalid address',
        statusCode: 422,
      );
      expect(
        await controller.signUp(
          email: 'a@b.com',
          password: 'secret',
          displayName: 'Patient',
        ),
        isFalse,
      );
      expect(repository.currentUser, isNull);
      expect(state().isAuthenticated, isFalse);
      expect(snackbar.successes, isEmpty);
      expect(state().errorMessage, 'email: Invalid address');
      expect(repository.verificationEmailCalls, 0);
    },
  );

  test(
    'session events update user without invoking auth actions or snackbars',
    () async {
      repository.events.add(user);
      await container.pump();
      expect(state().user, same(user));
      repository.events.add(null);
      await container.pump();
      expect(state().user, isNull);
      expect(repository.signInCalls, 0);
      expect(snackbar.successes, isEmpty);
    },
  );

  test('refresh and sign-out update session state', () async {
    repository.currentUser = user;
    expect(await controller.refreshUser(), isTrue);
    expect(state().user, same(user));
    expect(await controller.signOut(), isTrue);
    expect(state().user, isNull);
    expect(state().phoneNumber, isNull);
    expect(snackbar.successes, ['Logged out successfully.']);
  });

  test('storage failure keeps the actual Firebase session visible', () async {
    repository.error = PlatformException(code: 'storage-unavailable');
    repository.userOnFailure = user;
    expect(
      await controller.signIn(email: 'a@b.com', password: 'secret'),
      isFalse,
    );
    expect(state().user, same(user));
    expect(
      state().errorMessage,
      'Could not update saved account data. Please try again.',
    );
    expect(snackbar.successes, isEmpty);
  });

  test(
    'native OTP waits for callback, stores verification ID, and resends with token',
    () async {
      expect(
        await controller.requestPhoneCode(phoneNumber: '+8801700000000'),
        isTrue,
      );
      expect(state().isLoading, isTrue);
      repository.codeSent!('verification-id', 42);
      expect(state().codeSent, isTrue);
      expect(state().isLoading, isFalse);
      expect(state().verificationId, 'verification-id');
      expect(await controller.resendPhoneCode(), isTrue);
      expect(repository.resendToken, 42);
      repository.codeSent!('new-id', 43);
      expect(state().verificationId, 'new-id');
    },
  );

  test(
    'manual OTP confirmation clears verification state after signing in',
    () async {
      await controller.requestPhoneCode(phoneNumber: '+8801700000000');
      repository.codeSent!('verification-id', 42);
      expect(await controller.verifySmsCode('123456'), isTrue);
      expect(repository.submittedId, 'verification-id');
      expect(repository.submittedCode, '123456');
      expect(state().isAuthenticated, isTrue);
      expect(state().verificationId, isNull);
      expect(state().codeSent, isFalse);
      expect(snackbar.successes, ['Phone number verified.']);
    },
  );

  test(
    'automatic verification signs in using the received credential',
    () async {
      await controller.requestPhoneCode(phoneNumber: '+8801700000000');
      final credential = PhoneAuthProvider.credential(
        verificationId: 'id',
        smsCode: '123456',
      );
      repository.completed!(credential);
      await container.pump();
      expect(repository.credential, same(credential));
      expect(state().isAuthenticated, isTrue);
      expect(state().isLoading, isFalse);
      expect(snackbar.successes, ['Logged in successfully.']);
    },
  );

  test('verification errors stop progress and show feedback', () async {
    await controller.requestPhoneCode(phoneNumber: '+8801700000000');
    repository.failed!(FirebaseAuthException(code: 'invalid-phone-number'));
    expect(state().isLoading, isFalse);
    expect(
      state().errorMessage,
      'Enter a valid phone number with its country code.',
    );
    expect(snackbar.failures, hasLength(1));
  });

  test('changing number ignores stale phone callbacks', () async {
    await controller.requestPhoneCode(phoneNumber: '+8801700000000');
    final staleCodeSent = repository.codeSent!;
    final staleCompleted = repository.completed!;
    controller.clearPhoneVerification();
    await controller.requestPhoneCode(phoneNumber: '+8801800000000');
    staleCodeSent('old-id', 1);
    staleCompleted(
      PhoneAuthProvider.credential(verificationId: 'old-id', smsCode: '123456'),
    );
    expect(state().verificationId, isNull);
    expect(state().phoneNumber, '+8801800000000');
    expect(repository.credential, isNull);
    repository.codeSent!('new-id', 2);
    expect(state().verificationId, 'new-id');
  });

  test('phone callbacks arriving after failure are ignored', () async {
    await controller.requestPhoneCode(phoneNumber: '+8801700000000');
    repository.failed!(FirebaseAuthException(code: 'invalid-phone-number'));
    repository.codeSent!('late-id', 1);
    expect(state().verificationId, isNull);
    expect(state().codeSent, isFalse);
    expect(snackbar.infos, isEmpty);
    expect(snackbar.failures, hasLength(1));
  });

  test('provider rebuild ignores the previous dependency completion', () async {
    repository.pendingSignIn = Completer<AuthUser>();
    final pending = controller.signIn(email: 'a@b.com', password: 'secret');
    container.invalidate(authControllerProvider);
    container.read(authControllerProvider);
    repository.pendingSignIn!.complete(user);
    expect(await pending, isFalse);
    expect(state().isLoading, isFalse);
    expect(snackbar.successes, isEmpty);
    expect(snackbar.failures, isEmpty);
  });

  test(
    'late completion after disposal does not update state or notify',
    () async {
      repository.pendingSignIn = Completer<AuthUser>();
      final pending = controller.signIn(email: 'a@b.com', password: 'secret');
      container.dispose();
      repository.pendingSignIn!.complete(user);
      expect(await pending, isFalse);
      expect(snackbar.successes, isEmpty);
      expect(snackbar.failures, isEmpty);
    },
  );

  test('SMS submission requires a verification request', () async {
    expect(await controller.verifySmsCode('123456'), isFalse);
    expect(state().errorMessage, 'Request a verification code first.');
    expect(repository.submittedCode, isNull);
  });
}

class _FakeRepository implements AuthRepository {
  final events = StreamController<AuthUser?>.broadcast();
  @override
  AuthUser? currentUser;
  Object? error;
  AuthUser? userOnFailure;
  Completer<AuthUser>? pendingSignIn;
  int signInCalls = 0;
  String? resetEmail;
  int verificationEmailCalls = 0;
  Object? verificationError;
  PhoneCodeSent? codeSent;
  PhoneVerificationCompleted? completed;
  PhoneVerificationFailed? failed;
  int? resendToken;
  String? submittedId;
  String? submittedCode;
  AuthCredential? credential;

  @override
  Stream<AuthUser?> get authStateChanges => events.stream;

  void _throwIfNeeded() {
    if (error != null) {
      currentUser = userOnFailure ?? currentUser;
      throw error!;
    }
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    _throwIfNeeded();
    final user = pendingSignIn == null
        ? const AuthUser(
            uid: 'patient-1',
            email: 'patient@example.com',
            emailVerified: true,
          )
        : await pendingSignIn!.future;
    currentUser = user;
    return user;
  }

  @override
  Future<void> createPatient({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _throwIfNeeded();
  }

  @override
  Future<void> createDoctor({
    required String email,
    required String password,
    required String displayName,
    required DoctorRegistrationDetails details,
  }) async {
    _throwIfNeeded();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    _throwIfNeeded();
    resetEmail = email;
  }

  @override
  Future<void> sendEmailVerification() async {
    _throwIfNeeded();
    if (verificationError != null) throw verificationError!;
    verificationEmailCalls++;
  }

  @override
  Future<AuthUser?> reloadUser() async {
    _throwIfNeeded();
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    _throwIfNeeded();
    currentUser = null;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) async {
    _throwIfNeeded();
    this.codeSent = codeSent;
    completed = verificationCompleted;
    failed = verificationFailed;
    resendToken = forceResendingToken;
  }

  @override
  Future<AuthUser> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    submittedId = verificationId;
    submittedCode = smsCode;
    return signInWithEmailAndPassword(email: '', password: '');
  }

  @override
  Future<AuthUser> signInWithCredential(AuthCredential credential) {
    this.credential = credential;
    return signInWithEmailAndPassword(email: '', password: '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSnackbar implements SnackbarNotifier {
  final successes = <String>[];
  final failures = <String>[];
  final infos = <String>[];
  @override
  void success(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => successes.add(message);
  @override
  void failed(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => failures.add(message);
  @override
  void info(String message, {Duration duration = const Duration(seconds: 4)}) =>
      infos.add(message);
}
