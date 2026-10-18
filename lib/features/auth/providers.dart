import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;

import '../../core/providers.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/entities/auth_user.dart';
import 'domain/entities/registration_exception.dart';
import 'domain/repositories/auth_repository.dart';

export 'presentation/controllers/auth_controller.dart';
export 'presentation/controllers/auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(
    authService: ref.watch(firebaseAuthServiceProvider),
    readDio: () {
      try {
        return ref.read(dioProvider);
      } on ProviderException catch (error) {
        if (error.exception is ApiConfigurationException) {
          throw const RegistrationException(
            'Configure API_BASE_URL with your backend URL before creating an account.',
          );
        }
        rethrow;
      }
    },
  ),
);
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(storage: ref.watch(storageServiceProvider)),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  ),
);
final authSessionProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);
