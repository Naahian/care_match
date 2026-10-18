import 'package:dio/dio.dart';

typedef AccessTokenReader = Future<String?> Function();

/// Adds the current bearer token to API requests, without retaining a token.
/// Set Options(extra: {AuthInterceptor.requiresAuth: false}) for public APIs.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.apiOrigin, required this.readAccessToken});

  static const requiresAuth = 'requiresAuth';

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

      final token = (await readAccessToken())?.trim();
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
