import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class PortalProfileTile extends StatelessWidget {
  const PortalProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: AppSpacing.card,
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, color: scheme.primary),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          subtitle: Text(description, style: theme.textTheme.bodySmall),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
