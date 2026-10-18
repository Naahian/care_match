import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/constants.dart';
import 'network/dio_client.dart';
import 'network/interceptors/auth_interceptor.dart';
import 'services/firebase_auth_service.dart';
import 'services/snackbar_service.dart';
import 'services/storage_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);
final snackbarProvider = Provider<SnackbarNotifier>((ref) => snackbar);

final apiBaseUrlProvider = Provider<String>((ref) => ApiEndpoints.baseUrl);

/// Override this callback when a backend uses a different bearer-token source.
final accessTokenReaderProvider = Provider<AccessTokenReader>((ref) {
  final auth = ref.watch(firebaseAuthServiceProvider);
  return () => auth.getIdToken();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = createDioClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    readAccessToken: ref.watch(accessTokenReaderProvider),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});
