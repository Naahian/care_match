import '../../../core/services/storage_service.dart';
import '../domain/app_notification.dart';
import '../domain/notifications_repository.dart';

class LocalNotificationsRepository implements NotificationsRepository {
  LocalNotificationsRepository(this.storage);
  final StorageService storage;
  String _key(String uid) => 'notifications.v1.$uid';
  @override
  Future<List<AppNotification>> load(String userId) async {
    final map = await storage.readMap(key: _key(userId));
    if (map == null) return const [];
    final values = map['items'];
    if (values is! List) {
      throw const FormatException('Invalid notifications data.');
    }
    return List.unmodifiable(
      values.map((e) {
        if (e is! Map<String, dynamic>) {
          throw const FormatException('Invalid notification.');
        }
        return AppNotification.fromJson(e);
      }),
    );
  }

  @override
  Future<void> save(String userId, List<AppNotification> notifications) =>
      storage.writeMap(
        key: _key(userId),
        value: {'items': notifications.map((n) => n.toJson()).toList()},
      );
  @override
  Future<void> clear(String userId) => storage.delete(key: _key(userId));
}
