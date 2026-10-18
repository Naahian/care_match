import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/doctor_registration_details.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_user_model.dart';

/// Uses Firebase for authentication and secure storage for profile snapshots.
/// Cache writes happen after authentication; a storage failure does not undo
/// Firebase sign-in. Auth streams never depend on storage availability.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  AuthUserModel? get currentUser => _remote.currentUser;

  @override
  Stream<AuthUserModel?> get authStateChanges => _remote.authStateChanges;

  @override
  Stream<AuthUserModel?> get idTokenChanges => _remote.idTokenChanges;

  /// A cached profile cannot establish a session or belong to a different user.
  @override
  Future<AuthUserModel?> getCachedUser() async {
    final user = await _local.getCachedUser();
    if (user != null && user.uid != currentUser?.uid) {
      await _local.clearUser();
      return null;
    }
    return user;
  }

  @override
  Future<void> createPatient({
    required String email,
    required String password,
    required String displayName,
  }) => _remote.createPatient(
    email: email,
    password: password,
    displayName: displayName,
  );

  @override
  Future<void> createDoctor({
    required String email,
    required String password,
    required String displayName,
    required DoctorRegistrationDetails details,
  }) => _remote.createDoctor(
    email: email,
    password: password,
    displayName: displayName,
    details: details,
  );

  @override
  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _cacheResult(
    _remote.signInWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<AuthUserModel> signInWithCredential(AuthCredential credential) =>
      _cacheResult(_remote.signInWithCredential(credential));

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) => _remote.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: verificationCompleted,
    verificationFailed: verificationFailed,
    codeSent: codeSent,
    codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    timeout: timeout,
    forceResendingToken: forceResendingToken,
  );

  @override
  Future<ConfirmationResult> signInWithPhoneNumber({
    required String phoneNumber,
    RecaptchaVerifier? recaptchaVerifier,
  }) => _remote.signInWithPhoneNumber(
    phoneNumber: phoneNumber,
    recaptchaVerifier: recaptchaVerifier,
  );

  @override
  Future<AuthUserModel> confirmPhoneNumber({
    required ConfirmationResult confirmationResult,
    required String smsCode,
  }) => _cacheResult(
    _remote.confirmPhoneNumber(
      confirmationResult: confirmationResult,
      smsCode: smsCode,
    ),
  );

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _remote.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() => _remote.sendEmailVerification();

  @override
  Future<AuthUserModel?> reloadUser() async {
    final user = await _remote.reloadUser();
    if (user == null) {
      await _local.clearUser();
    } else {
      await _local.cacheUser(user);
    }
    return user;
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _remote.getIdToken(forceRefresh: forceRefresh);

  @override
  Future<AuthUserModel> updateDisplayName(String name) =>
      _cacheResult(_remote.updateDisplayName(name));

  @override
  Future<AuthUserModel> linkWithCredential(AuthCredential credential) =>
      _cacheResult(_remote.linkWithCredential(credential));

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber) =>
      _remote.linkWithPhoneNumber(phoneNumber);

  @override
  Future<void> signOut() async {
    await _remote.signOut();
    await _local.clearUser();
  }

  Future<AuthUserModel> _cacheResult(Future<AuthUserModel> result) async {
    final user = await result;
    await _local.cacheUser(user);
    return user;
  }
}
