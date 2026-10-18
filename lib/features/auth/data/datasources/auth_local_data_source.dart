import '../../../../core/services/storage_service.dart';
import '../models/auth_user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({required this.storage});

  final StorageService storage;
  static const userCacheKey = 'auth.user.v1';

  Future<void> cacheUser(AuthUserModel user) =>
      storage.writeMap(key: userCacheKey, value: user.toJson());

  /// Discards malformed profile snapshots. Platform storage errors propagate.
  Future<AuthUserModel?> getCachedUser() async {
    try {
      final json = await storage.readMap(key: userCacheKey);
      return json == null ? null : AuthUserModel.fromJson(json);
    } on FormatException {
      await clearUser();
      return null;
    }
  }

  Future<void> clearUser() => storage.delete(key: userCacheKey);
}
