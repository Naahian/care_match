import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/constants.dart';
import '../../features/auth/providers.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: AppSpacing.card,
        leading: CircleAvatar(
          backgroundColor: scheme.errorContainer,
          foregroundColor: scheme.error,
          child: const Icon(Icons.logout_rounded),
        ),
        title: Text(
          'Log out',
          style: theme.textTheme.titleSmall?.copyWith(color: scheme.error),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: scheme.error),
        onTap: () async {
          final succeeded = await ProviderScope.containerOf(
            context,
            listen: false,
          ).read(authControllerProvider.notifier).signOut();
          if (succeeded && context.mounted) context.goNamed(AppRoutes.login);
        },
      ),
    );
  }
}
