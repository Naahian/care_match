import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers.dart' show authSessionProvider;
import '../../domain/app_notification.dart';
import '../../providers.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.loading = false,
    this.error,
  });
  final List<AppNotification> items;
  final bool loading;
  final String? error;
  int get unseenCount => items.where((n) => !n.seen).length;
}

class NotificationsController extends Notifier<NotificationsState> {
  String? _uid;
  Timer? _timer;
  int _revision = 0;
  @override
  NotificationsState build() {
    final session = ref.watch(authSessionProvider);
    final uid = session.asData?.value?.uid;
    _uid = uid;
    final revision = ++_revision;
    _timer?.cancel();
    ref.onDispose(() {
      _revision++;
      _timer?.cancel();
    });
    if (uid != null) {
      Future.microtask(() {
        if (ref.mounted && revision == _revision) load();
      });
    }
    return const NotificationsState();
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null || state.loading) return;
    final rev = ++_revision;
    state = NotificationsState(items: state.items, loading: true);
    try {
      final items = await ref.read(notificationsRepositoryProvider).load(uid);
      if (!ref.mounted || rev != _revision || uid != _uid) return;
      state = NotificationsState(items: items);
      _schedule();
    } catch (_) {
      if (ref.mounted && rev == _revision) {
        state = NotificationsState(
          items: state.items,
          error: 'Could not load notifications.',
        );
      }
    }
  }

  Future<void> add({
    required NotificationType type,
    required String title,
    required String message,
    String? appointmentId,
    DateTime? remindAt,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final item = AppNotification(
      id: '${DateTime.now().microsecondsSinceEpoch}-${type.name}',
      type: type,
      title: title,
      message: message,
      createdAt: DateTime.now(),
      appointmentId: appointmentId,
      remindAt: remindAt,
    );
    final items = List<AppNotification>.unmodifiable([item, ...state.items]);
    state = NotificationsState(items: items, error: state.error);
    await _persist(uid, items);
    _schedule();
  }

  Future<void> cancelReminder(String appointmentId) async {
    final uid = _uid;
    if (uid == null) return;
    final items = List<AppNotification>.unmodifiable(
      state.items.where(
        (n) =>
            !(n.type == NotificationType.appointmentCreated &&
                n.appointmentId == appointmentId),
      ),
    );
    state = NotificationsState(items: items);
    await _persist(uid, items);
    _schedule();
  }

  Future<void> markAllSeen() async {
    final uid = _uid;
    if (uid == null || state.unseenCount == 0) return;
    final items = List<AppNotification>.unmodifiable(
      state.items.map((n) => n.copyWith(seen: true)),
    );
    state = NotificationsState(items: items);
    await _persist(uid, items);
  }

  Future<void> clearAll() async {
    final uid = _uid;
    if (uid == null) return;
    state = const NotificationsState();
    await ref.read(notificationsRepositoryProvider).clear(uid);
    _schedule();
  }

  Future<void> _persist(String uid, List<AppNotification> items) async {
    try {
      await ref.read(notificationsRepositoryProvider).save(uid, items);
    } catch (_) {
      if (ref.mounted) {
        state = NotificationsState(
          items: items,
          error: 'Could not save notifications locally.',
        );
      }
    }
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    final pending = state.items
        .where(
          (n) =>
              n.type == NotificationType.appointmentCreated &&
              n.remindAt != null &&
              n.remindAt!.isAfter(now),
        )
        .toList();
    if (pending.isEmpty) return;
    final next = pending
        .map((n) => n.remindAt!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    _timer = Timer(next.difference(now), () => _fireReminders());
  }

  Future<void> _fireReminders() async {
    final due = state.items
        .where(
          (n) =>
              n.type == NotificationType.appointmentCreated &&
              n.remindAt != null &&
              !n.remindAt!.isAfter(DateTime.now()),
        )
        .toList();
    for (final n in due) {
      final exists = state.items.any(
        (x) =>
            x.type == NotificationType.appointmentReminder &&
            x.appointmentId == n.appointmentId,
      );
      if (!exists) {
        await add(
          type: NotificationType.appointmentReminder,
          title: 'Appointment reminder',
          message: n.message,
          appointmentId: n.appointmentId,
        );
      }
    }
    _schedule();
  }
}
