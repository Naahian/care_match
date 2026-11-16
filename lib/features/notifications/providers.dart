import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'data/local_notifications_repository.dart';
import 'domain/notifications_repository.dart';
import 'presentation/controllers/notifications_controller.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => LocalNotificationsRepository(ref.watch(storageServiceProvider)),
);
final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
