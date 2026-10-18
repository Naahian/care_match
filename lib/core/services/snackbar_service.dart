import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../constants/constants.dart';
import '../theme/theme_extensions.dart';

/// The application instance, connected to MaterialApp.scaffoldMessengerKey.
final snackbar = SnackbarService();

/// Controllers can depend on this interface and use a fake in tests.
abstract interface class SnackbarNotifier {
  void success(
    String message, {
    Duration duration = const Duration(seconds: 4),
  });
  void failed(String message, {Duration duration = const Duration(seconds: 4)});
  void info(String message, {Duration duration = const Duration(seconds: 4)});
}

class SnackbarService implements SnackbarNotifier {
  SnackbarService({GlobalKey<ScaffoldMessengerState>? messengerKey})
    : messengerKey = messengerKey ?? GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldMessengerState> messengerKey;

  @override
  void success(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => _show(message, _SnackbarType.success, duration);

  @override
  void failed(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => _show(message, _SnackbarType.failed, duration);

  @override
  void info(String message, {Duration duration = const Duration(seconds: 4)}) =>
      _show(message, _SnackbarType.info, duration);

  /// Calls during build are deferred. Calls without a mounted messenger are
  /// ignored; attach [messengerKey] to the app before showing notifications.
  void _show(String message, _SnackbarType type, Duration duration) {
    if (message.trim().isEmpty) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show(message, type, duration);
      });
      return;
    }

    final messenger = messengerKey.currentState;
    if (messenger == null || !messenger.mounted) return;

    final theme = Theme.of(messenger.context);
    final extras =
        theme.extension<AppExtras>() ??
        AppExtras.forBrightness(theme.brightness);
    final (background, foreground, icon) = switch (type) {
      _SnackbarType.success => (
        extras.successContainer,
        extras.onSuccessContainer,
        Icons.check_circle_outline_rounded,
      ),
      _SnackbarType.failed => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
        Icons.error_outline_rounded,
      ),
      _SnackbarType.info => (
        extras.infoContainer,
        extras.onInfoContainer,
        Icons.info_outline_rounded,
      ),
    };

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: background,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
        content: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SnackbarType { success, failed, info }
