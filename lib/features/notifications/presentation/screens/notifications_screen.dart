import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      if (!mounted) return;
      final controller = ref.read(notificationsControllerProvider.notifier);
      await controller.load();
      if (mounted) await controller.markAllSeen();
    });
  }

  @override
  void dispose() {
    ref.read(notificationsControllerProvider.notifier).markAllSeen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: theme.textTheme.titleLarge),
        actions: [
          if (state.items.isNotEmpty)
            TextButton.icon(
              onPressed: controller.clearAll,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete all'),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: state.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                ? const Center(child: Text('No notifications yet'))
                : ListView.separated(
                    padding: AppSpacing.page,
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => NotificationTile(
                      notification: state.items[index],
                      isUnread: !state.items[index].seen,
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(current: 2),
    );
  }
}
