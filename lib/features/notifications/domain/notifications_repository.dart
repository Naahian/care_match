import 'app_notification.dart';

abstract interface class NotificationsRepository {
  Future<List<AppNotification>> load(String userId);
  Future<void> save(String userId, List<AppNotification> notifications);
  Future<void> clear(String userId);
}
