import 'package:dio/dio.dart';

typedef AccessTokenReader = Future<String?> Function();

/// Adds the current bearer token to API requests, without retaining a token.
/// Set Options(extra: {AuthInterceptor.requiresAuth: false}) for public APIs.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.apiOrigin,
    required this.readAccessToken,
    this.dio,
    this.refreshAccessToken,
    this.onSessionExpired,
    this.sessionId,
  });

  static const requiresAuth = 'requiresAuth';

  final String? Function()? sessionId;
  static const _account = 'authAccount';
  final Dio? dio;
  final AccessTokenReader? refreshAccessToken;
  final Future<void> Function()? onSessionExpired;
  Future<String?>? _refreshing;
  static const _retried = 'authRetried';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final error = err;
    final options = error.requestOptions;
    if (error.response?.statusCode != 401 ||
        options.extra[requiresAuth] == false ||
        refreshAccessToken == null ||
        dio == null) {
      handler.next(error);
      return;
    }
    try {
      if (sessionId != null && options.extra[_account] != sessionId!()) {
        handler.next(error);
        return;
      }
      if (options.extra[_retried] == true) {
        await onSessionExpired?.call();
        handler.next(error);
        return;
      }
      // Concurrent failures share a refresh; late failures reuse the new token.
      if (sessionId != null && options.extra[_account] != sessionId!()) {
        handler.next(error);
        return;
      }
      final current = await readAccessToken();
      String? token = current;
      if (current == null ||
          options.headers['Authorization'] == 'Bearer $current') {
        final refresh = _refreshing ??= refreshAccessToken!();
        try {
          token = await refresh;
        } finally {
          if (identical(_refreshing, refresh)) _refreshing = null;
        }
      }
      if (token == null || token.trim().isEmpty) {
        await onSessionExpired?.call();
        handler.next(error);
        return;
      }
      if (sessionId != null && options.extra[_account] != sessionId!()) {
        handler.next(error);
        return;
      }
      final body = options.data;
      if (body is Stream) {
        handler.next(error);
        return;
      }
      final retry = options.copyWith(
        data: body is FormData ? body.clone() : body,
        extra: {...options.extra, _retried: true},
      );
      handler.resolve(await dio!.fetch<Object?>(retry));
    } on DioException catch (failure) {
      handler.next(failure);
    } catch (failure, stackTrace) {
      handler.next(
        DioException(
          requestOptions: options,
          error: failure,
          stackTrace: stackTrace,
          message: 'Could not renew the session.',
        ),
      );
    }
  }

  final Uri apiOrigin;
  final AccessTokenReader readAccessToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (options.uri.origin != apiOrigin.origin) {
        throw StateError('API requests must use the configured API origin.');
      }

      // Always replace stale or manually supplied authorization headers.
      options.headers.removeWhere(
        (key, _) => key.toLowerCase() == 'authorization',
      );
      if (options.extra[requiresAuth] == false) {
        handler.next(options);
        return;
      }

      final account = sessionId?.call();
      final token = (await readAccessToken())?.trim();
      if (sessionId != null && sessionId!() != account) {
        throw StateError('The signed-in account changed.');
      }
      options.extra[_account] = account;
      if (token == null || token.isEmpty) {
        throw StateError('Sign in before making an authenticated API request.');
      }
      options.headers['Authorization'] = 'Bearer $token';
      options.followRedirects = false;
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          message: 'Could not authorize the API request.',
        ),
      );
    }
  }
}
