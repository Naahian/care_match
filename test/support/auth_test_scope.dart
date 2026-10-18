import 'package:care_match/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'dart:async';

import 'package:care_match/core/providers.dart';
import 'package:care_match/core/services/snackbar_service.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/domain/entities/doctor_registration_details.dart';
import 'package:care_match/features/auth/domain/repositories/auth_repository.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget authTestScope(
  Widget child, {
  FakeAuthRepository? repository,
  DoctorsRepository? doctorsRepository,
}) => ProviderScope(
  overrides: [
    if (doctorsRepository != null)
      doctorsRepositoryProvider.overrideWithValue(doctorsRepository),
    authRepositoryProvider.overrideWithValue(
      repository ?? FakeAuthRepository(),
    ),
    snackbarProvider.overrideWithValue(SilentSnackbar()),
  ],
  child: child,
);

class FakeAuthRepository implements AuthRepository {
  @override
  AuthUser? currentUser;
  @override
  Stream<AuthUser?> get authStateChanges => const Stream.empty();
  Object? error;
  Object? phoneError;
  Completer<AuthUser>? pendingSignIn;
  Completer<void>? pendingPasswordReset;
  int signInCalls = 0;
  int signUpCalls = 0;
  DoctorRegistrationDetails? doctorDetails;
  int verificationEmailCalls = 0;
  bool emailVerified = true;
  int phoneRequests = 0;
  int linkCalls = 0;
  String? email;
  String? password;
  String? phoneNumber;
  String? name;
  String? resetEmail;
  PhoneCodeSent? sendCode;
  bool automaticallySendCode = true;

  void _check() {
    if (error != null) throw error!;
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    this.email = email;
    this.password = password;
    _check();
    currentUser = pendingSignIn != null
        ? await pendingSignIn!.future
        : AuthUser(
            uid: 'email-user',
            email: email.trim(),
            emailVerified: emailVerified,
          );
    return currentUser!;
  }

  @override
  Future<void> createPatient({
    required String email,
    required String password,
    required String displayName,
  }) async {
    signUpCalls++;
    _check();
    this.email = email;
    this.password = password;
    name = displayName;
  }

  @override
  Future<void> createDoctor({
    required String email,
    required String password,
    required String displayName,
    required DoctorRegistrationDetails details,
  }) async {
    doctorDetails = details;
    await createPatient(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<AuthUser> updateDisplayName(String name) async {
    _check();
    this.name = name;
    currentUser = AuthUser(
      uid: currentUser!.uid,
      email: currentUser!.email,
      displayName: name,
    );
    return currentUser!;
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
    phoneRequests++;
    this.phoneNumber = phoneNumber;
    if (phoneError != null) throw phoneError!;
    sendCode = codeSent;
    if (automaticallySendCode) codeSent('id-$phoneRequests', 42);
  }

  @override
  Future<AuthUser> linkWithCredential(AuthCredential credential) async {
    linkCalls++;
    _check();
    currentUser = AuthUser(
      uid: currentUser!.uid,
      email: currentUser!.email,
      displayName: currentUser!.displayName,
      phoneNumber: phoneNumber,
    );
    return currentUser!;
  }

  @override
  Future<AuthUser> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    _check();
    currentUser = AuthUser(uid: 'phone-user', phoneNumber: phoneNumber);
    return currentUser!;
  }

  @override
  Future<void> sendEmailVerification() async {
    _check();
    verificationEmailCalls++;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    _check();
    resetEmail = email;
    await pendingPasswordReset?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SilentSnackbar implements SnackbarNotifier {
  @override
  void success(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {}
  @override
  void failed(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {}
  @override
  void info(String message, {Duration duration = const Duration(seconds: 4)}) {}
}
