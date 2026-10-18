import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/doctor_registration_details.dart';
import '../../domain/entities/registration_exception.dart';
import '../../providers.dart' show authRepositoryProvider, authSessionProvider;
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Auth actions return false on failure, a duplicate request, or disposal.
/// Widgets decide navigation after success; this controller owns no UI context.
class AuthController extends Notifier<AuthState> {
  late AuthRepository _repository;
  ConfirmationResult? _webConfirmation;
  bool _linkPhoneToCurrentUser = false;
  int _revision = 0;
  int _phoneAttempt = 0;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _webConfirmation = null;
    ref.onDispose(() {
      _revision++;
      _phoneAttempt++;
    });
    ref.listen(authSessionProvider, (_, next) {
      if (!ref.mounted) return;
      next.whenData((user) {
        state = state.copyWith(user: user);
      });
      if (next.hasError) {
        final message = _errorMessage(next.error!);
        state = state.copyWith(errorMessage: message);
      }
    });
    return AuthState(user: _repository.currentUser);
  }

  Future<bool> signIn({required String email, required String password}) =>
      _run(
        AuthAction.signIn,
        () async {
          final user = await _repository.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (!user.emailVerified) {
            try {
              await _repository.sendEmailVerification();
            } finally {
              await _repository.signOut();
            }
            throw FirebaseAuthException(code: 'email-not-verified');
          }
          return state.copyWith(user: user);
        },
        success: 'Logged in successfully.',
        clearPhone: true,
      );

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    DoctorRegistrationDetails? doctorDetails,
  }) => _run(
    AuthAction.signUp,
    () async {
      if (doctorDetails == null) {
        await _repository.createPatient(
          email: email,
          password: password,
          displayName: displayName,
        );
      } else {
        await _repository.createDoctor(
          email: email,
          password: password,
          displayName: displayName,
          details: doctorDetails,
        );
      }
      return state;
    },
    success: 'Account created. Log in to continue.',
    clearPhone: true,
  );

  Future<bool> signInWithCredential(AuthCredential credential) => _run(
    AuthAction.signIn,
    () async {
      final user = await _repository.signInWithCredential(credential);
      return state.copyWith(user: user);
    },
    success: 'Logged in successfully.',
    clearPhone: true,
  );

  Future<bool> updateDisplayName(String name) =>
      _run(AuthAction.refreshUser, () async {
        final user = await _repository.updateDisplayName(name);
        return state.copyWith(user: user);
      });

  Future<bool> _completePhoneCredential(AuthCredential credential) =>
      _linkPhoneToCurrentUser
      ? _run(
          AuthAction.verifyCode,
          () async {
            final user = await _repository.linkWithCredential(credential);
            return state.copyWith(user: user);
          },
          success: 'Phone number verified.',
          clearPhone: true,
        )
      : signInWithCredential(credential);

  Future<bool> resetPassword({required String email}) => _run(
    AuthAction.resetPassword,
    () async {
      await _repository.sendPasswordResetEmail(email: email);
      return state;
    },
    info: 'If an account exists, a password reset email has been sent.',
  );

  Future<bool> sendEmailVerification() =>
      _run(AuthAction.verifyEmail, () async {
        await _repository.sendEmailVerification();
        return state;
      }, info: 'Check your email for the verification link.');

  Future<bool> refreshUser() => _run(AuthAction.refreshUser, () async {
    final user = await _repository.reloadUser();
    return state.copyWith(user: user);
  });

  Future<bool> signOut() => _run(
    AuthAction.signOut,
    () async {
      await _repository.signOut();
      return const AuthState();
    },
    success: 'Logged out successfully.',
    clearPhone: true,
  );

  /// Native completion happens through callbacks; true means the request was
  /// accepted. Watch codeSent or isAuthenticated before navigating.
  Future<bool> requestPhoneCode({
    required String phoneNumber,
    bool resend = false,
    bool linkToCurrentUser = false,
  }) async {
    if (!ref.mounted || state.isLoading) return false;
    final token = resend && phoneNumber.trim() == state.phoneNumber
        ? state.resendToken
        : null;
    _linkPhoneToCurrentUser = linkToCurrentUser;
    final attempt = ++_phoneAttempt;
    final revision = ++_revision;
    var automaticCompletion = false;
    _webConfirmation = null;
    state = state.copyWith(
      pendingAction: AuthAction.sendCode,
      errorMessage: null,
      phoneNumber: phoneNumber.trim(),
      verificationId: null,
      resendToken: null,
      codeSent: false,
    );
    bool active() =>
        ref.mounted && attempt == _phoneAttempt && revision == _revision;
    try {
      if (kIsWeb) {
        final result = linkToCurrentUser
            ? await _repository.linkWithPhoneNumber(phoneNumber)
            : await _repository.signInWithPhoneNumber(phoneNumber: phoneNumber);
        if (!active()) return false;
        _webConfirmation = result;
        state = state.copyWith(pendingAction: null, codeSent: true);
        ref.read(snackbarProvider).info('Verification code sent.');
      } else {
        await _repository.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          forceResendingToken: token,
          verificationCompleted: (credential) {
            if (!active() ||
                (state.isLoading &&
                    state.pendingAction != AuthAction.sendCode)) {
              return;
            }
            automaticCompletion = true;
            state = state.copyWith(pendingAction: null);
            unawaited(_completePhoneCredential(credential));
          },
          verificationFailed: (error) {
            if (active()) _fail(error);
          },
          codeSent: (id, token) {
            if (!active()) return;
            state = state.copyWith(
              pendingAction: null,
              verificationId: id,
              resendToken: token,
              codeSent: true,
            );
            ref.read(snackbarProvider).info('Verification code sent.');
          },
          codeAutoRetrievalTimeout: (id) {
            if (!active()) return;
            state = state.copyWith(pendingAction: null, verificationId: id);
          },
        );
      }
      return ref.mounted &&
          (automaticCompletion || (active() && state.errorMessage == null));
    } catch (error) {
      if (active()) _fail(error);
      return false;
    }
  }

  Future<bool> resendPhoneCode() {
    final phone = state.phoneNumber;
    if (phone == null) return Future.value(false);
    return requestPhoneCode(
      phoneNumber: phone,
      resend: true,
      linkToCurrentUser: _linkPhoneToCurrentUser,
    );
  }

  Future<bool> verifySmsCode(String smsCode) {
    if (!ref.mounted || state.isLoading) return Future.value(false);
    final confirmation = _webConfirmation;
    final id = state.verificationId;
    if (confirmation == null && id == null) {
      _fail(StateError('Request a verification code first.'));
      return Future.value(false);
    }
    return _run(
      AuthAction.verifyCode,
      () async {
        final user = confirmation != null
            ? await _repository.confirmPhoneNumber(
                confirmationResult: confirmation,
                smsCode: smsCode,
              )
            : await _repository.linkWithCredential(
                PhoneAuthProvider.credential(
                  verificationId: id!,
                  smsCode: smsCode.trim(),
                ),
              );
        return state.copyWith(user: user);
      },
      success: 'Phone number verified.',
      clearPhone: true,
    );
  }

  /// Ends the current UI verification attempt; SDK requests cannot be cancelled.
  void clearPhoneVerification() {
    if (!ref.mounted) return;
    // Avoid hiding progress for an in-flight sign-in or other auth action.
    if (state.isLoading && state.pendingAction != AuthAction.sendCode) return;
    _revision++;
    _phoneAttempt++;
    _webConfirmation = null;
    state = state.copyWith(
      pendingAction: null,
      errorMessage: null,
      phoneNumber: null,
      verificationId: null,
      resendToken: null,
      codeSent: false,
    );
  }

  Future<bool> _run(
    AuthAction action,
    Future<AuthState> Function() operation, {
    String? success,
    String? info,
    bool clearPhone = false,
  }) async {
    if (!ref.mounted || state.isLoading) return false;
    final revision = ++_revision;
    state = state.copyWith(pendingAction: action, errorMessage: null);
    try {
      final result = await operation();
      if (!ref.mounted || revision != _revision) return false;
      state = result.copyWith(pendingAction: null, errorMessage: null);
      if (clearPhone) clearPhoneVerification();
      if (success != null) ref.read(snackbarProvider).success(success);
      if (info != null) ref.read(snackbarProvider).info(info);
      return true;
    } catch (error) {
      if (ref.mounted && revision == _revision) _fail(error);
      return false;
    }
  }

  void _fail(Object error) {
    _revision++;
    _phoneAttempt++;
    final message = _errorMessage(error);
    state = state.copyWith(
      user: _repository.currentUser,
      pendingAction: null,
      errorMessage: message,
    );
    ref.read(snackbarProvider).failed(message);
  }

  static String _errorMessage(Object error) {
    if (error is RegistrationException) return error.message;
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'The email or password is incorrect.',
        'email-not-verified' =>
          'Verify your email before signing in. Check your inbox for a new verification link.',
        'invalid-email' => 'Enter a valid email address.',
        'email-already-in-use' => 'An account already uses this email address.',
        'credential-already-in-use' =>
          'This phone number belongs to another account.',
        'provider-already-linked' =>
          'A phone number is already linked to this account.',
        'weak-password' => 'Choose a stronger password.',
        'user-disabled' => 'This account has been disabled.',
        'invalid-phone-number' =>
          'Enter a valid phone number with its country code.',
        'invalid-verification-code' => 'The verification code is incorrect.',
        'session-expired' || 'invalid-verification-id' =>
          'The verification code expired. Request another code.',
        'too-many-requests' ||
        'quota-exceeded' => 'Too many attempts. Please try again later.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        'no-current-user' => 'Please log in to continue.',
        'operation-not-allowed' =>
          'This sign-in method is currently unavailable.',
        _ => 'Authentication failed. Please try again.',
      };
    }
    if (error is PlatformException) {
      return 'Could not update saved account data. Please try again.';
    }
    if (error is StateError &&
        error.message == 'Request a verification code first.') {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
