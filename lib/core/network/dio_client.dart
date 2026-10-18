import 'package:dio/dio.dart';

import '../constants/constants.dart';
import 'interceptors/auth_interceptor.dart';

class ApiConfigurationException extends ArgumentError {
  ApiConfigurationException()
    : super('Set API_BASE_URL to an absolute HTTP(S) backend URL.');
}

/// Creates the shared API client. Feature data sources can inject [Dio] and use
/// its typed get/post/put/patch/delete methods, Options, and CancelToken APIs.
/// HTTP and transport failures are preserved as DioException for callers.
Dio createDioClient({
  required String baseUrl,
  required AccessTokenReader readAccessToken,
  HttpClientAdapter? adapter,
}) {
  final uri = Uri.tryParse(baseUrl);
  if (uri == null ||
      !uri.hasAuthority ||
      uri.host.isEmpty ||
      (uri.scheme != 'https' && uri.scheme != 'http') ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw ApiConfigurationException();
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConstants.requestTimeout,
      sendTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      headers: {'Accept': 'application/json'},
      // Let callers handle redirects without forwarding credentials elsewhere.
      followRedirects: false,
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(apiOrigin: uri, readAccessToken: readAccessToken),
  );
  return dio;
}
