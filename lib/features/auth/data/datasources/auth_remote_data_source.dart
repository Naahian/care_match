import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../domain/entities/doctor_registration_details.dart';
import '../../domain/entities/registration_exception.dart';
import '../models/auth_user_model.dart';
import '../models/registration_request_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required this.authService, required this.readDio});

  final FirebaseAuthService authService;
  // Firebase login/session operations do not require backend configuration.
  final Dio Function() readDio;

  AuthUserModel? get currentUser => _mapUser(authService.currentUser);

  Stream<AuthUserModel?> get authStateChanges =>
      authService.authStateChanges.map(_mapUser);

  Stream<AuthUserModel?> get idTokenChanges =>
      authService.idTokenChanges.map(_mapUser);

  Future<void> createPatient({
    required String email,
    required String password,
    required String displayName,
  }) => _register(
    ApiEndpoints.createPatient,
    RegistrationRequestModel(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  Future<void> createDoctor({
    required String email,
    required String password,
    required String displayName,
    required DoctorRegistrationDetails details,
  }) => _register(
    ApiEndpoints.createDoctor,
    RegistrationRequestModel(
      email: email,
      password: password,
      displayName: displayName,
      doctorDetails: details,
    ),
  );

  Future<void> _register(
    String endpoint,
    RegistrationRequestModel request,
  ) async {
    try {
      final response = await readDio().post<String>(
        endpoint,
        data: request.toJson(),
        options: Options(
          extra: {AuthInterceptor.requiresAuth: false},
          // Decode successful envelopes explicitly so malformed error pages
          // retain their HTTP status for registration error mapping.
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );
      _debugRegistrationResponse(response, request.password);
      ApiResponse.fromJson(jsonDecode(response.data ?? ''));
    } on DioException catch (error) {
      _debugRegistrationResponse(
        error.response,
        request.password,
        error: error,
      );
      throw _registrationError(error, request.password);
    } on ApiResponseException catch (error) {
      throw _registrationFailure(error.statusCode);
    } on FormatException {
      throw const RegistrationException(
        'The registration response was invalid.',
      );
    }
  }

  static void _debugRegistrationResponse(
    Response<dynamic>? response,
    String password, {
    DioException? error,
  }) {
    if (!kDebugMode) return;
    String redact(Object? value) {
      final text = value?.toString() ?? '<empty>';
      return password.isEmpty ? text : text.replaceAll(password, '[redacted]');
    }

    Object? sanitize(Object? value) {
      if (value is Map) {
        return value.map(
          (key, item) => MapEntry(
            key.toString(),
            RegExp(
                  r'password|token|authorization|secret',
                  caseSensitive: false,
                ).hasMatch(key.toString())
                ? '[redacted]'
                : sanitize(item),
          ),
        );
      }
      if (value is List) return value.map(sanitize).toList();
      return value;
    }

    Object? body = response?.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } on FormatException {
        // Keep non-JSON responses visible (e.g. redirects or server errors).
      }
    }
    final printableBody = body is Map || body is List
        ? jsonEncode(sanitize(body))
        : body;
    debugPrint(
      '[Registration] POST ${redact(response?.requestOptions.uri ?? error?.requestOptions.uri)}',
    );
    debugPrint(
      '[Registration] Status: ${response?.statusCode ?? '<no response>'}',
    );
    if (response?.headers.value('location') case final String location) {
      debugPrint('[Registration] Redirect: ${redact(location)}');
    }
    debugPrint('[Registration] Response: ${redact(printableBody)}');
    if (error != null) {
      debugPrint(
        '[Registration] Dio error: ${error.type.name}: ${redact(error.message)}',
      );
      if (response == null) {
        debugPrint('[Registration] Cause: ${redact(error.error)}');
      }
    }
  }

  static RegistrationException _registrationError(
    DioException error,
    String password,
  ) {
    final status = error.response?.statusCode;
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const RegistrationException(
        'Check your internet connection and try again.',
      );
    }
    // Never expose input, ctx, or raw responses in user-facing errors.
    dynamic body = error.response?.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } on FormatException {
        body = null;
      }
    }
    if (body is Map && body['data'] is Map) {
      body = body['data'];
    }
    if (status != null &&
        status >= 400 &&
        status < 500 &&
        body is Map &&
        body['detail'] is List) {
      final messages = <String>[];
      for (final detail in body['detail'] as List) {
        if (detail is! Map ||
            detail['loc'] is! List ||
            detail['msg'] is! String) {
          continue;
        }
        final fields = (detail['loc'] as List)
            .whereType<String>()
            .where((field) => field != 'body')
            .toList();
        if (fields.contains('password')) {
          messages.add('Password does not meet the requirements.');
        } else {
          final field = fields.isEmpty
              ? 'Account'
              : fields.join(' ').replaceAll('_', ' ');
          messages.add('$field: ${detail['msg']}');
        }
      }
      if (messages.isNotEmpty) {
        var message = messages.toSet().join('\n');
        if (password.isNotEmpty) {
          message = message.replaceAll(password, '[redacted]');
        }
        return RegistrationException(message, statusCode: status);
      }
    }
    return _registrationFailure(status);
  }

  static RegistrationException _registrationFailure(int? status) =>
      RegistrationException(switch (status) {
        409 => 'An account already uses this email address.',
        429 => 'Too many attempts. Please try again later.',
        _ => 'Could not create your account. Please try again.',
      }, statusCode: status);

  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => _userFromCredential(
    await authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  Future<AuthUserModel> signInWithCredential(AuthCredential credential) async =>
      _userFromCredential(await authService.signInWithCredential(credential));

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) => authService.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: verificationCompleted,
    verificationFailed: verificationFailed,
    codeSent: codeSent,
    codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    timeout: timeout,
    forceResendingToken: forceResendingToken,
  );

  Future<ConfirmationResult> signInWithPhoneNumber({
    required String phoneNumber,
    RecaptchaVerifier? recaptchaVerifier,
  }) => authService.signInWithPhoneNumber(
    phoneNumber: phoneNumber,
    recaptchaVerifier: recaptchaVerifier,
  );

  Future<AuthUserModel> confirmPhoneNumber({
    required ConfirmationResult confirmationResult,
    required String smsCode,
  }) async =>
      _userFromCredential(await confirmationResult.confirm(smsCode.trim()));

  Future<void> sendPasswordResetEmail({required String email}) =>
      authService.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() => authService.sendEmailVerification();

  Future<AuthUserModel?> reloadUser() async {
    await authService.reloadUser();
    return currentUser;
  }

  Future<String?> getIdToken({bool forceRefresh = false}) =>
      authService.getIdToken(forceRefresh: forceRefresh);

  Future<AuthUserModel> updateDisplayName(String name) async {
    await authService.updateDisplayName(name);
    await authService.reloadUser();
    final user = currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');
    return user;
  }

  Future<AuthUserModel> linkWithCredential(AuthCredential credential) async =>
      _userFromCredential(await authService.linkWithCredential(credential));

  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber) =>
      authService.linkWithPhoneNumber(phoneNumber);

  Future<void> signOut() => authService.signOut();

  static AuthUserModel? _mapUser(User? user) =>
      user == null ? null : AuthUserModel.fromFirebaseUser(user);

  static AuthUserModel _userFromCredential(UserCredential credential) {
    final user = _mapUser(credential.user);
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Authentication did not return a user.',
      );
    }
    return user;
  }
}
