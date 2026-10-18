import 'package:firebase_auth/firebase_auth.dart';

/// Firebase authentication operations shared by the auth feature.
///
/// Initialize Firebase before creating this service. An injected [FirebaseAuth]
/// can target a secondary app or be replaced in tests. FirebaseAuthException
/// errors are preserved so callers can handle their codes in the UI.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(
    email: email.trim(),
    password: password,
  );

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  /// Signs in with an already obtained phone or social provider credential.
  Future<UserCredential> signInWithCredential(AuthCredential credential) =>
      _auth.signInWithCredential(credential);

  Future<void> sendPasswordResetEmail({required String email}) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> sendEmailVerification() =>
      _requireUser().sendEmailVerification();

  /// Refreshes the cached user, including their email verification status.
  Future<void> reloadUser() => _requireUser().reload();

  /// Returns null when signed out. Firebase manages token storage and renewal.
  Future<String?> getIdToken({bool forceRefresh = false}) async =>
      currentUser?.getIdToken(forceRefresh);

  /// Starts native phone verification using an E.164 number (e.g. +88017...).
  ///
  /// [verificationCompleted] provides the automatically verified credential;
  /// the caller must pass it to [signInWithCredential] to complete sign-in.
  /// Keep the verification ID from [codeSent] for [signInWithSmsCode]. Resending
  /// may use the returned resend token on supported platforms (Android).
  /// Web callers should use [signInWithPhoneNumber] instead.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) => _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber.trim(),
    verificationCompleted: verificationCompleted,
    verificationFailed: verificationFailed,
    codeSent: codeSent,
    codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    timeout: timeout,
    forceResendingToken: forceResendingToken,
  );

  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) => signInWithCredential(
    PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    ),
  );

  /// Starts web phone verification. Call `result.confirm(smsCode)` to sign in.
  Future<ConfirmationResult> signInWithPhoneNumber({
    required String phoneNumber,
    RecaptchaVerifier? recaptchaVerifier,
  }) => _auth.signInWithPhoneNumber(phoneNumber.trim(), recaptchaVerifier);

  Future<UserCredential> linkWithCredential(AuthCredential credential) =>
      _requireUser().linkWithCredential(credential);

  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber) =>
      _requireUser().linkWithPhoneNumber(phoneNumber.trim());

  Future<void> updateDisplayName(String name) =>
      _requireUser().updateDisplayName(name.trim());

  Future<void> signOut() => _auth.signOut();

  User _requireUser() {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Sign in before performing this operation.',
      );
    }
    return user;
  }
}
