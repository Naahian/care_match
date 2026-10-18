import 'package:firebase_auth/firebase_auth.dart';

import '../entities/auth_user.dart';
import '../entities/doctor_registration_details.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
  Stream<AuthUser?> get idTokenChanges;
  Future<AuthUser?> getCachedUser();

  /// The backend creates the account. Registration does not start a session.
  Future<void> createPatient({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> createDoctor({
    required String email,
    required String password,
    required String displayName,
    required DoctorRegistrationDetails details,
  });
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<AuthUser> updateDisplayName(String name);
  Future<AuthUser> linkWithCredential(AuthCredential credential);
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber);
  Future<AuthUser> signInWithCredential(AuthCredential credential);

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  });
  Future<ConfirmationResult> signInWithPhoneNumber({
    required String phoneNumber,
    RecaptchaVerifier? recaptchaVerifier,
  });
  Future<AuthUser> confirmPhoneNumber({
    required ConfirmationResult confirmationResult,
    required String smsCode,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> sendEmailVerification();
  Future<AuthUser?> reloadUser();
  Future<String?> getIdToken({bool forceRefresh = false});
  Future<void> signOut();
}
