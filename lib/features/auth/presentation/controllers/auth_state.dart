import '../../domain/entities/auth_user.dart';

enum AuthAction {
  signIn,
  signUp,
  sendCode,
  verifyCode,
  resetPassword,
  verifyEmail,
  refreshUser,
  signOut,
}

const _unchanged = Object();

class AuthState {
  const AuthState({
    this.user,
    this.pendingAction,
    this.errorMessage,
    this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.codeSent = false,
  });

  final AuthUser? user;
  final AuthAction? pendingAction;
  final String? errorMessage;
  final String? phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final bool codeSent;

  bool get isLoading => pendingAction != null;
  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Object? user = _unchanged,
    Object? pendingAction = _unchanged,
    Object? errorMessage = _unchanged,
    Object? phoneNumber = _unchanged,
    Object? verificationId = _unchanged,
    Object? resendToken = _unchanged,
    bool? codeSent,
  }) => AuthState(
    user: identical(user, _unchanged) ? this.user : user as AuthUser?,
    pendingAction: identical(pendingAction, _unchanged)
        ? this.pendingAction
        : pendingAction as AuthAction?,
    errorMessage: identical(errorMessage, _unchanged)
        ? this.errorMessage
        : errorMessage as String?,
    phoneNumber: identical(phoneNumber, _unchanged)
        ? this.phoneNumber
        : phoneNumber as String?,
    verificationId: identical(verificationId, _unchanged)
        ? this.verificationId
        : verificationId as String?,
    resendToken: identical(resendToken, _unchanged)
        ? this.resendToken
        : resendToken as int?,
    codeSent: codeSent ?? this.codeSent,
  );
}
