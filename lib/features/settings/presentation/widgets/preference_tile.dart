import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class PreferenceTile extends StatelessWidget {
  const PreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBackground,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBackground;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accessory =
        trailing ??
        Icon(Icons.chevron_right_rounded, color: scheme.primary, size: 22);
    final stackAccessory = MediaQuery.textScalerOf(context).scale(14) > 18;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground ?? scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? scheme.primary, size: 25),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0,
                    ),
                  ),
                  if (stackAccessory && trailing != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    accessory,
                  ],
                ],
              ),
            ),
            if (!stackAccessory || trailing == null) ...[
              const SizedBox(width: AppSpacing.sm),
              accessory,
            ],
          ],
        ),
      ),
    );
  }
}
